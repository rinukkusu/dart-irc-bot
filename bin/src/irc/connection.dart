part of irc_bot;

class IrcConnection {
  Socket _socket;

  String _host;
  int _port;
  String _username = "dartbot";
  String _realname = "Insane Bot";
  String _password;
  String _commandChar = "_";

  StreamController<IrcMessage> _rawController = new StreamController();
  StreamController<IrcMessage> _pongController = new StreamController();
  StreamController<IrcMessage> _noticeController = new StreamController();
  StreamController<IrcMessage> _messageController = new StreamController();
  StreamController<IrcCommand> _commandController = new StreamController();
  StreamController<IrcMessage> _inviteController = new StreamController();
  Stream<IrcMessage> rawMessages;
  Stream<IrcMessage> pongs;
  Stream<IrcMessage> notices;
  Stream<IrcMessage> messages;
  Stream<IrcCommand> commands;
  Stream<IrcMessage> invites;

  Map<String, IrcPluginBase> _plugins = new Map<String, IrcPluginBase>();
  Map<String, Function> _commands = new Map<String, Function>();
  List<String> _channels = new List<String>();

  IrcConnection(String host, [int port = 6667]) {
    rawMessages = _rawController.stream.asBroadcastStream();
    pongs = _pongController.stream.asBroadcastStream();
    notices = _noticeController.stream.asBroadcastStream();
    messages = _messageController.stream.asBroadcastStream();
    commands = _commandController.stream.asBroadcastStream();
    invites = _inviteController.stream.asBroadcastStream();

    _registerCorePlugins();

    _host = host;
    _port = port;
  }

  String withUsername(String username) => _username = username;
  String withRealname(String realname) => _realname = realname;
  String withPassword(String password) => _password = password;
  String withCommandChar(String commandChar) => _commandChar = commandChar;

  Future<Null> connect() async {
    _socket = await Socket.connect(_host, _port);
    _socket.listen(_onData);

    stdin.listen((data) {
      String input = new String.fromCharCodes(data);
      _sendRaw(input);
    });

    _authenticate();
    _joinChannels();
  }

  void _joinChannels() {
    rawMessages.firstWhere((message) {
      if (message.type == MessageType.RPL_WELCOME) {
        _channels.forEach(_joinChannel);

        return true;
      }
    });
  }

  void _joinChannel(String channel) {
    if (!channel.startsWith("#")) channel = "#${channel}";
    _sendRaw("JOIN ${channel}");
  }

  void addChannel(String channel) {
    _channels.add(channel);
  }

  void addCommand(String command, Function function) {
    _commands.putIfAbsent(command, () => function);
  }

  void _registerCorePlugins() {
    var mirror = currentMirrorSystem()
        .libraries
        .values
        .firstWhere((x) => x.simpleName == new Symbol("irc_bot"));

    mirror.declarations.values.forEach((declaration) {
      var classMirror = declaration as ClassMirror;
      if (classMirror.superinterfaces.any(
          (interface) => interface.simpleName == new Symbol("IrcPluginBase"))) {
        var pluginName = MirrorSystem.getName(declaration.simpleName);
        var instance = classMirror.newInstance(new Symbol(""), []);
        registerPlugin(pluginName, instance.reflectee);
      }
    });
  }

  void registerPlugin(String name, IrcPluginBase plugin) {
    print("Registering ${name} ...");
    _plugins.putIfAbsent(name, () => plugin);
    plugin.register(this);

    // register commands
    var pluginReflection = reflect(plugin);
    pluginReflection.type.instanceMembers.forEach((symbol, methodMirror) {
      if (methodMirror.metadata
          .any((meta) => meta.type.simpleName == new Symbol("Command"))) {
        var commandName = (methodMirror.metadata.first.reflectee as Command).name;
        addCommand(
            commandName,
            (command) => pluginReflection
                .invoke(methodMirror.simpleName, [command]));
      }
    });
  }

  void _sendRaw(String message) {
    _socket.add("${message}\r\n".codeUnits);
    print("<< ${message}");
  }

  void sendMessage(String target, String message) {
    _sendRaw("PRIVMSG ${target} :${message}");
  }

  void _authenticate() {
    _sendRaw("NICK ${_username}");
    _sendRaw("USER ${_username} 0 * :${_realname}");
  }

  void _onData(List<int> data) {
    String messageRaw = new String.fromCharCodes(data);
    var messages = messageRaw.replaceAll("\r", "").split("\n");

    messages.forEach((message) {
      if (message.trim().isNotEmpty) {
        print(">> ${message}");

        var ircMessage = new IrcMessage.fromRawMessage(message);
        if (ircMessage != null) {
          _handleMessage(ircMessage);
        }
      }
    });
  }

  bool _isCommand(IrcMessage message) {
    return message.message.startsWith(new RegExp("${_commandChar}\\w"));
  }

  void _handleMessage(IrcMessage message) {
    _rawController.add(message);

    switch (message.type) {
      case MessageType.PING:
        _sendRaw("PONG :${message.message}");
        break;

      case MessageType.PONG:
        _pongController.add(message);
        break;

      case MessageType.NOTICE:
        _noticeController.add(message);
        break;

      case MessageType.PRIVMSG:
        _messageController.add(message);
        if (_isCommand(message))
          _commandController.add(new IrcCommand.fromIrcMessage(message));
        break;

      case MessageType.INVITE:
        _inviteController.add(message);
        break;

      default:
        break;
    }
  }
}
