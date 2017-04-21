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
      if (msg.codeUnitAt(i) >= 65 && msg.codeUnitAt(i) <= 90)
        upperCount++;
    }

    if (upperCount / msg.replaceAll(r"\s", "").length > 0.8) {
      _server.sendMessage(message.returnTo, "REALTALK");
    }
  }
}