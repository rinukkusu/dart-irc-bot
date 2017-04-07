part of irc_bot;

class InvitePlugin implements IrcPluginBase {
  IrcConnection _server;

  @override
  void register(IrcConnection server) {
    _server = server;
    _server.invites.listen(onInvite);
  }

  void onInvite(IrcMessage message) {
    _server._joinChannel(message.message);
  }
}
