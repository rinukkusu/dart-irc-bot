part of irc_bot;

class CleverbotPlugin extends IrcPluginBase {
  JsonConfig _config;
  Map<String, Cleverbot> _cleverbotMap = new Map();
  String _apiToken;
  RegExp _trigger;

  @override
  Future<Null> register() async {
    _config = await JsonConfig.fromPath("cleverbot.json");
    _config.failOnMissingKey(["ApiToken"]);
    _apiToken = _config.get("ApiToken", "") as String;

    _trigger = new RegExp("^${_server._username}\\W\\s?(.*)");
    _server.messages.listen(onMessage);
  }

  Cleverbot _getCleverbot(String channel) {
    if (_cleverbotMap.containsKey(channel)) {
      return _cleverbotMap[channel];
    }

    var cleverbot = new Cleverbot(_apiToken);
    _cleverbotMap[channel] = cleverbot;

    return cleverbot;
  }

  void onMessage(IrcMessage message) {
    var match = _trigger.firstMatch(message.message);
    if (match != null) {
      _getCleverbot(message.returnTo)
          .think(match.group(1))
          .then<Null>((cleverMessage) {
        _server.sendMessage(message.returnTo, cleverMessage);
      }).catchError((Exception error) {
        _server.sendMessage(message.returnTo, error.toString());
      });
    }
  }
}
