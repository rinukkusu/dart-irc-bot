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

  UserContainer _userContainer = new UserContainer();

  Map<String, IrcPluginBase> _plugins = new Map<String, IrcPluginBase>();
  Map<Command, Function> _commands = new Map<Command, Function>();
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

    /*stdin.listen((data) {
      String input = new String.fromCharCodes(data);
      _sendRaw(input);
    });*/

    _authenticate();
    _joinChannels();
  }

  void _joinChannels() {
    rawMessages.firstWhere((message) {
      if (message.type == MessageType.RPL_WELCOME) {
        _channels.forEach(_joinChannel);

        return true;
      }
      return false;
    });
  }

  void _joinChannel(String channel) {
    if (!channel.startsWith("#")) channel = "#${channel}";
    _sendRaw("JOIN ${channel}");
  }

  void _partChannel(String channel) {
    if (!channel.startsWith("#")) channel = "#${channel}";
    _sendRaw("PART ${channel}");
  }

  void addChannel(String channel) {
    _channels.add(channel);
  }

  void addCommand(Command command, Function function) {
    _commands.putIfAbsent(command, () => function);
  }

  void addOwner(String name) {
    _userContainer.addUser(name, UserLevel.OWNER);
  }

  void ignoreUser(String name) {
    _userContainer.addUser(name, UserLevel.IGNORED);
  }

  void resetUser(String name) {
    _userContainer.addUser(name, UserLevel.DEFAULT);
  }

  void _registerCorePlugins() {
    var mirror = currentMirrorSystem()
        .libraries
        .values
        .firstWhere((x) => x.simpleName == new Symbol("irc_bot"));

    mirror.declarations.values.forEach((declaration) {
      if (declaration is ClassMirror) {
        if (declaration.superclass.simpleName == new Symbol("IrcPluginBase")) {
          var pluginName = MirrorSystem.getName(declaration.simpleName);
          var instance = declaration.newInstance(new Symbol(""), <dynamic>[]);
          registerPlugin(pluginName, instance.reflectee as IrcPluginBase);
        }
      }
    });
  }

  void registerPlugin(String name, IrcPluginBase plugin) {
    print("Registering ${name} ...");
    _plugins.putIfAbsent(name, () => plugin);
    plugin._registerPlugin(this);

    // register commands
    var pluginReflection = reflect(plugin);
    pluginReflection.type.instanceMembers.forEach((symbol, methodMirror) {
      if (methodMirror.metadata
          .any((meta) => meta.type.simpleName == new Symbol("Command"))) {
        addCommand(
            methodMirror.metadata.first.reflectee as Command,
            (IrcCommand command) => pluginReflection
                .invoke(methodMirror.simpleName, <dynamic>[command]));
      }
    });
  }

  void _sendRaw(String message) {
    _socket.add(UTF8.encode("${message}\r\n"));
    print("<< ${message}");
  }

  void sendMessage(String target, String message) {
    _sendRaw("PRIVMSG ${target} :${message}");
  }

  void sendNotice(String target, String message) {
    _sendRaw("NOTICE ${target} :${message}");
  }

  void _authenticate() {
    _sendRaw("NICK ${_username}");
    _sendRaw("USER ${_username} 0 * :${_realname}");
  }

  void _onData(List<int> data) {
    String messageRaw = UTF8.decode(data, allowMalformed: true);
    var messages = messageRaw.replaceAll("\r", "").split("\n");

    messages.forEach((message) {
      if (message.trim().isNotEmpty) {
        print(">> ${message}");

        var ircMessage = new IrcMessage.fromRawMessage(message);
        if (ircMessage != null) {
          ircMessage.sender.userLevel =
              _userContainer.getLevel(ircMessage.sender.username);

          runZoned(() => _handleMessage(ircMessage),
              onError: (Exception error, StackTrace stacktrace) {
            sendMessage(ircMessage.returnTo, "[Unhandled]: $error");
          });
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
