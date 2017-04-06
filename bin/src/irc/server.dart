part of irc_bot;

class IrcServer {
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
  Stream<IrcMessage> rawMessages;
  Stream<IrcMessage> pongs;
  Stream<IrcMessage> notices;
  Stream<IrcMessage> messages;
  Stream<IrcCommand> commands;

  List<IrcPluginBase> _plugins = new List<IrcPluginBase>();
  List<String> _channels = new List<String>();

  IrcServer(String host, [int port = 6667]) {
    rawMessages = _rawController.stream.asBroadcastStream();
    pongs = _pongController.stream.asBroadcastStream();
    notices = _noticeController.stream.asBroadcastStream();
    messages = _messageController.stream.asBroadcastStream();
    commands = _commandController.stream.asBroadcastStream();

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
        _channels.forEach((channel) {
          if (!channel.startsWith("#")) channel = "#${channel}";
          _sendRaw("JOIN ${channel}");
        });

        return true;
      }
    });
  }

  void addChannel(String channel) {
    _channels.add(channel);
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
        print(
            "Registering ${MirrorSystem.getName(declaration.simpleName)} ...");
        var instance = classMirror.newInstance(new Symbol(""), []);
        instance.invoke(new Symbol("register"), [this]);
      }
    });
  }

  void registerPlugin(IrcPluginBase plugin) {
    _plugins.add(plugin);
    plugin.register(this);
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

      default:
        break;
    }
  }
}
