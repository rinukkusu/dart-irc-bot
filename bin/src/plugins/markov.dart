part of irc_bot;

class MarkovPlugin extends IrcPluginBase {
  String _configKey;
  JsonConfig _config;
  Map<String, List<String>> _channelMap = new Map();
  Map<String, List<String>> _newMessages = new Map();
  Map<String, dynamic> _chainMap = new Map();

  @override
  Future<Null> register() async {
    _configKey = _server._host;

    _config = await JsonConfig.fromPath("rss_reader.json");
    var map = _config.get(_configKey);

    if (map == null) {} else {
      _channelMap.forEach((channel, messages) {
        var chain = new Stream<String>.fromIterable(messages)
            .pipe(new MarkovChainGenerator(2));
        _chainMap[channel] = chain;
      });
    }
  }

  //@Command("markov",)
}
