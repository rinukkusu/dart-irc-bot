part of irc_bot;

class InvitePlugin extends IrcPluginBase {
  @override
  void register() {
    _server.invites.listen(onInvite);
  }

  void onInvite(IrcMessage message) {
    _server._joinChannel(message.message);
  }
}
