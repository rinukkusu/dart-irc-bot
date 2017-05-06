part of irc_bot;

class PingPlugin extends IrcPluginBase {
  Map<int, IrcMessage> _pingMap = new Map<int, IrcMessage>();
  DateTime _lastPing = new DateTime.now();
  int PING_TIMEOUT = 2;

  @override
  void register() {
    _server.pongs.listen(onPong);
  }

  @Command("ping")
  bool onPing(IrcCommand message) {
    var now = new DateTime.now();
    var diff = now.difference(_lastPing);

    if (diff > new Duration(seconds: PING_TIMEOUT)) {
      _lastPing = now;
      var timestamp = now.microsecondsSinceEpoch;
      _pingMap.putIfAbsent(timestamp, () => message.originalMessage);

      _server._sendRaw("PING :${timestamp}");
    } else {
      var secondsUntil = PING_TIMEOUT - diff.inSeconds;
      
      _server.sendNotice(message.originalMessage.sender.username,
          _T(Messages.PING_NOT_ALLOWED, <String>[secondsUntil.toString()]));
    }

    return true;
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
