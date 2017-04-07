part of irc_bot;

class EchoPlugin extends IrcPluginBase {
  @override
  void register() {}

  @Command("echo")
  void onEcho(IrcCommand message) {
    _server.sendMessage(
        message.originalMessage.returnTo, message.rawArgumentString);
  }
}
