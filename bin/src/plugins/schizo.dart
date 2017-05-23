part of irc_bot;

class SchizoConversation {
  IrcConnection server;
  String channel;
  SchizoBot bot_1;
  SchizoBot bot_2;
  bool _stopTalking = false;
  Random _rng = new Random();
  int get _randomTiming => _rng.nextInt(15) + 5;

  SchizoConversation(String apiToken, this.server, this.channel,
      {String name_1: "A", String name_2: "B"}) {
    bot_1 = new SchizoBot(apiToken, name_1);
    bot_2 = new SchizoBot(apiToken, name_2);
  }

  void startTalk([String message = ""]) {
    talk(bot_1, bot_2, message);
  }

  void stopTalk() {
    _stopTalking = true;
  }

  void talk(SchizoBot sender, SchizoBot target, String message) {
    if (_stopTalking) return;

    server.sendMessage(channel, "${sender.name}: $message");

    target.think(message).then((thought) {
      new Timer(new Duration(seconds: _randomTiming),
          () => talk(target, sender, thought));
    });
  }
}

class SchizoBot {
  String name;
  Cleverbot _cleverbot;

  SchizoBot(String apiToken, this.name) {
    _cleverbot = new Cleverbot(apiToken);
  }

  Future<String> think(String message) {
    return _cleverbot.think(message);
  }
}

class SchizoPlugin extends IrcPluginBase {
  String _apiToken;
  List<SchizoConversation> _conversations = new List();

  @override
  Future<Null> register() async {
    var config = await JsonConfig.fromPath("cleverbot.json");
    config.failOnMissingKey(["ApiToken"]);
    _apiToken = config.get("ApiToken", "") as String;
  }

  SchizoConversation getConversation(String channel) {
    return _conversations.firstWhere((c) => c.channel == channel,
        orElse: () => null);
  }

  @Command(
      "schizo_start", const ["?message"], UserLevel.DEFAULT, const [], true)
  bool onStart(IrcCommand command) {
    var channel = command.originalMessage.returnTo;
    SchizoConversation conversation = getConversation(channel);

    if (conversation != null) return false; // TODO: send error

    conversation = new SchizoConversation(_apiToken, _server, channel);
    conversation.startTalk(command.rawArgumentString);

    return true;
  }

  @Command("schizo_stop")
  bool onStop(IrcCommand command) {
    var channel = command.originalMessage.returnTo;
    SchizoConversation conversation = getConversation(channel);

    if (conversation == null) return false; // TODO: send error

    conversation.stopTalk();

    return true;
  }
}
