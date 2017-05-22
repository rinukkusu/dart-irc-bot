part of irc_bot;

class FortunePlugin extends IrcPluginBase {
  Fortune _fortune;

  @override
  void register() {
    _fortune = new FortuneFromData();
  }

  @Command("fortune")
  FutureOr<bool> onFortune(IrcCommand command) async {
    var fortune = await _fortune.next();
    _server.sendMessage(command.originalMessage.returnTo, fortune);

    return true;
  }
}
