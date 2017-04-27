part of irc_bot;

class GoogleSearchPlugin extends IrcPluginBase {
  static String _baseUrl = "https://www.googleapis.com/customsearch/v1";
  String _getUrl(String search) =>
      "${_baseUrl}?key=${_apiToken}&cx=${_customSearchId}&q=${Uri.encodeQueryComponent(search)}";

  String _apiToken;
  String _customSearchId;

  @override
  Future<Null> register() async {
    JsonConfig config = await JsonConfig.fromPath("google.json");

    config.failOnMissingKey(["ApiToken", "CustomSearchId"]);

    _apiToken = config.get("ApiToken", "") as String;
    _customSearchId = config.get("CustomSearchId", "") as String;
  }

  @Command(
      "google", const ["search text"], UserLevel.DEFAULT, const ["g"], true)
  bool onSearch(IrcCommand command) {
    var search = command.rawArgumentString;

    new http.Client()
      ..get(_getUrl(search)).then<Null>((response) {
        var bytes = response.bodyBytes;
        var string = UTF8.decode(bytes);
        var obj = JSON.decode(string) as Map<String, dynamic>;

        if (obj["items"] != null) {
          var item = obj["items"][0] as Map<String, dynamic>;

          var title = item["title"] as String;
          var url = item["link"] as String;

          GoogleUrlShortenerPlugin.shortenUrl(url).then<Null>((shortenedUrl) {
            _server.sendMessage(
                command.originalMessage.returnTo, "${title} - ${shortenedUrl}");
          });
        } else {
          _server.sendMessage(command.originalMessage.returnTo,
              "${command.originalMessage.sender.username}: No results.");
        }
      });

    return true;
  }
}
