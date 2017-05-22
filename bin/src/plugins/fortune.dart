part of irc_bot;

class FortunePlugin extends IrcPluginBase {
  Fortune _fortune;
  Map<String, DateTime> _fortuneMap;

  @override
  void register() {
    _fortune = new FortuneFromData();
    _fortuneMap = new Map();
  }

  @Command("fortune")
  bool onFortune(IrcCommand command) {
    var username = command.originalMessage.sender.username;

    if (eglibleForFortune(username)) {
      var fortune = _fortune.next();
      _server.sendMessage(command.originalMessage.returnTo, fortune.toString());
    } else {
      _server.sendNotice(username, "COME BACK ONE DAY!");
    }

    return true;
  }

  bool eglibleForFortune(String name) {
    if (!_fortuneMap.containsKey(name)) return true;

    var diff = new DateTime.now().difference(_fortuneMap[name]).abs();
    if (diff >= new Duration(days: 1)) return true;

    return false;
  }
}
