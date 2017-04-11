part of irc_bot;

class RandomReplyPlugin extends IrcPluginBase {
  static RegExp _saveTrigger = new RegExp(r"([Ww]eil\s.*)");
  static RegExp _replyTrigger = new RegExp(r"[Ww](arum|ieso).*\?");

  JsonConfig _config;
  List<String> _replies = new List();
  Random _rand = new Random();

  @override
  Future<Null> register() async {
    _config = await JsonConfig.fromPath("random_answer.json");
    _replies = _config.get("Replies", <String>[]) as List<String>;

    if (_replies.isEmpty) {
      _replies.add("weil das halt so ist ...");
      _config.set("Replies", _replies);
      await _config.save();
    }

    _server.messages.listen(onMessage);
  }

  void onMessage(IrcMessage message) {
    var saveMatch = _saveTrigger.firstMatch(message.message);
    if (saveMatch != null) {
      var newReply = saveMatch.group(1);
      _replies.add(newReply);
      _config.save();
    } else {
      var replyMatch = _replyTrigger.firstMatch(message.message);
      if (replyMatch != null) {
        var i = _replies.length > 1 ? _rand.nextInt(_replies.length - 1) : 0;
        var reply = _replies[i];
        _server.sendMessage(message.returnTo, reply);
      }
    }
  }
}
