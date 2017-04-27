part of irc_bot;

class GoogleUrlShortenerPlugin extends IrcPluginBase {
  static String _baseUrl = "https://www.googleapis.com/urlshortener/v1/url";
  static String _getUrl() => "${_baseUrl}?key=${_apiToken}";
  static String _apiToken;

  @override
  Future<Null> register() async {
    JsonConfig config = await JsonConfig.fromPath("google.json");
    config.failOnMissingKey(["ApiToken"]);
    _apiToken = config.get("ApiToken", "") as String;
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
    var client = new http.Client();
    var request = JSON.encode({"longUrl": url});
    var response = await client.post(_getUrl(),
        headers: {"Content-Type": "application/json"}, body: request);

    var bytes = response.bodyBytes;
    var json = UTF8.decode(bytes);
    var obj = JSON.decode(json) as Map<String, String>;

    var shortenedUrl = obj["id"];

    return shortenedUrl;
  }
}
