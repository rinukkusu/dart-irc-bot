part of irc_bot;

class GoogleUrlShortenerPlugin extends IrcPluginBase {
  static UrlshortenerApi _api;

  @override
  Future<Null> register() async {
    JsonConfig config = await JsonConfig.fromPath("google.json");
    config.failOnMissingKey(["ApiToken"]);
    var apiToken = config.get("ApiToken", "") as String;

    var client = clientViaApiKey(apiToken);
    _api = new UrlshortenerApi(client);
  }

  @Command("gshort", const ["url"])
  bool onGoogleShort(IrcCommand command) {
    shortenUrl(command.arguments.first).then<Null>((url) {
      _server.sendMessage(command.originalMessage.returnTo,
          "${command.originalMessage.sender.username}: ${url}");
    });

    return true;
  }

  static Future<String> shortenUrl(String url) async {
    var shortenedUrl = await _api.url.insert(new Url.fromJson(<String, String>{"longUrl": url}));

    return shortenedUrl.id;
  }
}
