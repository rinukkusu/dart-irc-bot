part of irc_bot;

class FortunePlugin extends IrcPluginBase {
  Fortune _fortune;

  @override
  void register() {
    _fortune = new FortuneFromData();
  }

  @Command("fortune")
  bool onFortune(IrcCommand command) {
    var fortune = _fortune.next();
    _server.sendMessage(command.originalMessage.returnTo, fortune.toString());

    return true;
  }
}
