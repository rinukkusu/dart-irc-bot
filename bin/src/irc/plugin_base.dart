part of irc_bot;

abstract class IrcPluginBase {
  IrcConnection _server;
  dynamic register();

  void _registerPlugin(IrcConnection server) {
    _server = server;

    dynamic result = register();
    if (result is Future<Null>) {
      Future.wait<Null>([result]);
    }
  }
}
