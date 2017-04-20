part of irc_bot;

class MarkovPlugin extends IrcPluginBase {
  String _configKey;
  JsonConfig _config;
  Map<String, List<String>> _messageMap = new Map();
  Map<String, List<String>> _newMessages = new Map();
  Map<String, MarkovChain<String>> _chainMap = new Map();

  @override
  Future<Null> register() async {
    _configKey = _server._host;

    _config = await JsonConfig.fromPath("markov.json");
    _messageMap = _config.get(_configKey);

    if (_messageMap == null) {
      await _save();
    }

    _regenerateChains();

    _server.messages.listen(onMessage);

    new Timer.periodic(new Duration(seconds: 10), (t) => _updateNewMessages());
  }

  void onMessage(IrcMessage message) {
    if (_server._isCommand(message)) return;
    var channel = message.returnTo;

    if (!_newMessages.containsKey(channel))
      _newMessages[channel] = new List<String>();

    _newMessages[channel].add(message.message);
  }

  Future<Null> _updateNewMessages() async {
    if (_newMessages.length > 0) {
      _newMessages.forEach((channel, messages) {
        if (!_messageMap.containsKey(channel))
          _messageMap[channel] = new List<String>();

        _messageMap[channel].addAll(messages);
      });

      _newMessages.clear();

      _regenerateChains();
      await _save();
    }
  }

  Future<Null> _save() async {
    _config.set(_configKey, _messageMap);
    await _config.save();
  }

  void _regenerateChains() {
    _chainMap.clear();

    _messageMap.forEach((channel, messages) {
      var chain = new MarkovChain<String>(2);
      messages.forEach((m) {
        chain.add(_tokenize(m));
      });
      _chainMap[channel] = chain;
    });
  }

  Iterable<String> _tokenize(String message) {
    return message.split(" ")..removeWhere((x) => x.isEmpty);
  }

  Future<MarkovChain> _tryGetChain(String channel) async {
    if (!_chainMap.containsKey(channel))
      _chainMap[channel] = new MarkovChain<String>(2);

    await _save();

    return _chainMap[channel];
  }

  @Command("markov", const ["?input"], UserLevel.DEFAULT, const ["m"], true)
  bool onMarkov(IrcCommand command) {
    var channel = command.originalMessage.returnTo;

    _tryGetChain(channel).then((chain) {
      var tokens = _tokenize(command.rawArgumentString);
      var generated = chain.chain(tokens).toList();

      _server.sendMessage(
          channel, "${command.rawArgumentString} ${generated.join(" ")}");
    });

    return true;
  }
}
