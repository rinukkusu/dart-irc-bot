part of irc_bot;

class GoogleTranslatePlugin extends IrcPluginBase {
  String _targetLanguage;
  TranslateApi _api;

  @override
  Future<Null> register() async {
    JsonConfig config = await JsonConfig.fromPath("google.json");

    config.failOnMissingKey(["ApiToken"]);

    var apiToken = config.get("ApiToken", "") as String;
    _targetLanguage = config.get("TargetLanguage", "en") as String;
    await config.save();

    var client = clientViaApiKey(apiToken);
    _api = new TranslateApi(client);
  }

  @Command(
      "gtranslate", const ["text"], UserLevel.DEFAULT, const ["gtrans"], true)
  bool onSearch(IrcCommand command) {
    var text = command.rawArgumentString;

    _api.translations.list([text], _targetLanguage).then((data) {
      if (data.translations != null) {
        var sourceLanguage = data.translations[0].detectedSourceLanguage;
        var translatedText = data.translations[0].translatedText;

        _server.sendMessage(command.originalMessage.returnTo,
            "[$sourceLanguage->$_targetLanguage]: $translatedText");
      } else {
        _server.sendMessage(command.originalMessage.returnTo,
            "${command.originalMessage.sender.username}: No results.");
      }
    });

    return true;
  }
}
