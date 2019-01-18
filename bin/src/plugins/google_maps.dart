part of irc_bot;

class GoogleMapsResult {
  static const String OK = "OK";
  static const String ZERO_RESULTS = "ZERO_RESULTS";

  String address;
  double lat;
  double lon;

  GoogleMapsResult(this.address, this.lat, this.lon);
}

class GoogleMapsPlugin extends IrcPluginBase {
  static String _baseUrl = "https://maps.googleapis.com/maps/api/geocode/json";
  static String _getUrl(String search) =>
      "${_baseUrl}?key=${_apiToken}&address=${Uri.encodeQueryComponent(search)}";
  String _getMapsUrl(String place, double lat, double lon) =>
      "https://www.google.com/maps/place/${Uri.encodeQueryComponent(place)}/@${lat},${lon},15z/";
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

    getPlace(search).then<Null>((place) {
      if (place != null) {
        var maps_url = _getMapsUrl(place.address, place.lat, place.lon);
        GoogleUrlShortenerPlugin.shortenUrl(maps_url).then((shortenedUrl) {
          _server.sendMessage(command.originalMessage.returnTo,
              "${place.address} - ${place.lat}, ${place.lon} - $shortenedUrl");
        });
      }
    });

    return true;
  }

  static Future<GoogleMapsResult> getPlace(String search) async {
    var response = await new http.Client().get(_getUrl(search));
    var bytes = response.bodyBytes;
    var string = utf8.decode(bytes);
    var obj = json.decode(string) as Map<String, dynamic>;

    if (obj["status"] == GoogleMapsResult.OK) {
      var results = obj["results"][0] as Map;

      var address = results["formatted_address"] as String;
      var lat = results["geometry"]["location"]["lat"] as double;
      var lon = results["geometry"]["location"]["lng"] as double;

      return new GoogleMapsResult(address, lat, lon);
    }

    return null;
  }
}
