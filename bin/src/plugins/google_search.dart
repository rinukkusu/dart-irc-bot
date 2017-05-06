part of irc_bot;

class GoogleSearchPlugin extends IrcPluginBase {
  String _customSearchId;
  CustomsearchApi _api;

  @override
  Future<Null> register() async {
    JsonConfig config = await JsonConfig.fromPath("google.json");

    config.failOnMissingKey(["ApiToken", "CustomSearchId"]);

    var apiToken = config.get("ApiToken", "") as String;
    _customSearchId = config.get("CustomSearchId", "") as String;

    var client = clientViaApiKey(apiToken);
    _api = new CustomsearchApi(client);
  }

  @Command(
      "google", const ["search text"], UserLevel.DEFAULT, const ["g"], true)
  bool onSearch(IrcCommand command) {
    var search = command.rawArgumentString;

    _api.cse.list(search, cx: _customSearchId).then((data) {
      if (data.items != null) {
          var item = data.items[0];

          var title = item.title;
          var url = item.link;

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
