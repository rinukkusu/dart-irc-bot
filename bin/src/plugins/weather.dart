part of irc_bot;

class WeatherPlugin extends IrcPluginBase {
  static const String RETURN_STRING =
      "%CITY% | %TEMP%°C | %WEATHERINFO% | H: %HUMIDITY%%, P: %PRESSURE%hPa";
  String _apiToken = "";
  Map<String, String> _users = new Map();
  DarkSkyWeather _weatherApi;

  // d = day, n = night
  Map<String, String> _weatherIcons = {
    "clear-day": "☀",
    "clear-night": "🌚",
    "partly-cloudy-day": "⛅",
    "partly-cloudy-night": "⛅",
    "cloudy": "☁",
    "rain": "🌧",
    "thunderstorm": "⛈",
    "snow": "🌨",
    "fog": "🌫",
  };

  JsonConfig _config;

  @override
  Future<Null> register() async {
    _config = await JsonConfig.fromPath("weather.json");
    _config.failOnMissingKey(["ApiToken"]);
    _apiToken = _config.get("ApiToken", "") as String;

    if (_config.get("Users") == null) {
      _config.set("Users", _users);
      await _config.save();

      throw new Exception(
          _T(Messages.EDIT_CONFIG_ERROR, <String>[_config.getPath()]));
    }

    _weatherApi = new DarkSkyWeather(_apiToken,
        language: Language.English, units: Units.SI);
    _users = (_config.get("Users") as Map<String, dynamic>).cast<String, String>();
  }

  @Command("weather", const ["?location"], UserLevel.DEFAULT, const ["w"], true)
  bool onWeather(IrcCommand command) {
    var sender = command.originalMessage.sender;
    var location = command.rawArgumentString;

    if (location.isEmpty) {
      if (_users.containsKey(sender.username)) {
        location = _users[sender.username];
      } else {
        _server.sendNotice(sender.username, Messages.WEATHER_LOCATION_MISSING);
      }
    }

    GoogleMapsPlugin.getPlace(location).then((place) {
      _weatherApi.getForecast(place.lat, place.lon).then((weather) {
        if (weather != null) {
          var ret = RETURN_STRING
              .replaceAll("%CITY%", place.address)
              .replaceAll("%TEMP%", weather.currently.temperature.toString())
              .replaceAll("%HUMIDITY%", (weather.currently.humidity*100).toString())
              .replaceAll("%PRESSURE%", weather.currently.pressure.toString());

          String weatherInfo = weather.currently.summary;
          String weatherIcon = _weatherIcons[weather.currently.icon];

          ret = ret.replaceAll("%WEATHERINFO%", "$weatherIcon $weatherInfo");
          _server.sendMessage(command.originalMessage.returnTo,
              "${command.originalMessage.sender.username}: ${ret}");
        }
      });
    });

    return true;
  }

  @Command("weatherset", const ["location"], UserLevel.DEFAULT, const ["wset"])
  bool onSetWeather(IrcCommand command) {
    var sender = command.originalMessage.sender;
    var location = command.rawArgumentString;

    _users[sender.username] = location;
    _config.set("Users", _users);
    _config.save();

    _server.sendMessage(command.originalMessage.returnTo,
        "${sender.username}: ${_T(Messages.WEATHER_LOCATION_SET, <String>[location])}");

    return true;
  }
}
