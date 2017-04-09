part of irc_bot;

class InvitePlugin extends IrcPluginBase {
  @override
  void register() {
    _server.invites.listen(onInvite);
  }

  bool onInvite(IrcMessage message) {
    _server._joinChannel(message.message);

    return true;
  }
}
