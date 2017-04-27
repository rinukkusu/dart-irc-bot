part of irc_bot;

class GoogleMapsResult {
  static const String OK = "OK";
  static const String ZERO_RESULTS = "ZERO_RESULTS";
}

class GoogleMapsPlugin extends IrcPluginBase {
  static String _baseUrl = "https://maps.googleapis.com/maps/api/geocode/json";
  String _getUrl(String search) =>
      "${_baseUrl}?key=${_apiToken}&address=${Uri.encodeQueryComponent(search)}";
  String _getMapsUrl(String place, Point location) =>
      "https://www.google.com/maps/place/${Uri.encodeQueryComponent(place)}/@${location.x},${location.y},15z/";
  static String _apiToken;

  @override
  Future<Null> register() async {
    JsonConfig config = await JsonConfig.fromPath("google.json");
    config.failOnMissingKey(["ApiToken"]);
    _apiToken = config.get("ApiToken", "") as String;
  }

  @Command("gmaps", const ["address"], UserLevel.DEFAULT, const [], true)
  bool onGoogleMaps(IrcCommand command) {
    var search = command.rawArgumentString;

    new http.Client()
      ..get(_getUrl(search)).then<Null>((response) {
        var bytes = response.bodyBytes;
        var string = UTF8.decode(bytes);
        var obj = JSON.decode(string) as Map<String, dynamic>;

        if (obj["status"] == GoogleMapsResult.OK) {
          var results = obj["results"][0] as Map;

          var address = results["formatted_address"] as String;
          var location = new Point(
              results["geometry"]["location"]["lat"] as double,
              results["geometry"]["location"]["lng"] as double);

          var maps_url = _getMapsUrl(address, location);
          GoogleUrlShortenerPlugin.shortenUrl(maps_url).then((shortenedUrl) {
            _server.sendMessage(command.originalMessage.returnTo,
                "$address - ${location.x}, ${location.y} - $shortenedUrl");
          });
        }
      });

    return true;
  }
}
