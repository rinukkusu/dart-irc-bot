part of irc_bot;

class RealtalkPlugin extends IrcPluginBase {
  @override
  void register() {
    _server.messages.listen(onCapslock);
  }

  bool onCapslock(IrcMessage message) {
    var msg = message.message;
    var upperCount = 0;

    for (int i = 0; i < msg.length; i++) {
      if (msg[i].toUpperCase() == msg[i] && msg[i].toLowerCase() != msg[i]) upperCount++;
    }

    if (upperCount / msg.replaceAll(new RegExp(r"\s"), "").length > 0.8) {
      _server.sendMessage(message.returnTo, "REALTALK");
    }

    return true;
  }
}
