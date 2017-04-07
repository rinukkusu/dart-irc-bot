part of irc_bot;

class EchoPlugin implements IrcPluginBase {
  IrcConnection _server;

  @override
  void register(IrcConnection server) {
    _server = server;
  }

  @Command("echo")
  void onEcho(IrcCommand message) {
    _server.sendMessage(
        message.originalMessage.returnTo, message.rawArgumentString);
  }
}
