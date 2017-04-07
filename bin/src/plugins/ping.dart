part of irc_bot;

class PingPlugin extends IrcPluginBase {
  Map<int, IrcMessage> _pingMap = new Map<int, IrcMessage>();

  @override
  void register() {
    _server.pongs.listen(onPong);
  }

  @Command("ping")
  void onPing(IrcCommand message) {
    var timestamp = new DateTime.now().microsecondsSinceEpoch;
    _pingMap.putIfAbsent(timestamp, () => message.originalMessage);

    _server._sendRaw("PING :${timestamp}");
  }

  void onPong(IrcMessage message) {
    var timestamp = new DateTime.now().microsecondsSinceEpoch;
    var oldTimestamp = int.parse(message.message);

    var diff = (timestamp - oldTimestamp) / 1000;

    var originalMessage = _pingMap.remove(oldTimestamp);

    _server.sendMessage(originalMessage.returnTo,
        "${originalMessage.sender.username}: ${diff}ms");
  }
}
