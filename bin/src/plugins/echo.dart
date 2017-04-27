part of irc_bot;

class EchoPlugin extends IrcPluginBase {
  @override
  void register() {}

  @Command("echo", const ["some words"], UserLevel.DEFAULT, const [], true)
  bool onEcho(IrcCommand message) {
    _server.sendMessage(
        message.originalMessage.returnTo, message.rawArgumentString);

    return true;
  }
}
