part of irc_bot;

abstract class IrcPluginBase {
  IrcConnection _server;
  void register();

  void _registerPlugin(IrcConnection server) {
    _server = server;

    register();
  }
}
