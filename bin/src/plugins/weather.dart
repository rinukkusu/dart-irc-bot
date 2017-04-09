part of irc_bot;

class WeatherPlugin extends IrcPluginBase {
  static const String API_URL = "http://api.openweathermap.org/data/2.5/weather?units=metric";
  static const String RETURN_STRING = "%CITY% | %TEMP%°C | %WEATHERINFO% | H: %HUMIDITY%%, P: %PRESSURE%hPa";
  String ApiToken = ""; // TODO: put into seperate config
  String _getApiUrl(String place) => "${API_URL}&APPID=${ApiToken}&q=${place}";

  Map<String, String> _weatherIcons = {
     "01d": "☀", "01n": "🌚",
     "02d": "⛅", "02n": "⛅",
     "03d": "☁", "03n": "☁",
     "04d": "☁", "04n": "☁",
     "09d": "🌦", "09n": "🌦",
     "10d": "🌧", "10n": "🌧",
     "11d": "⛈", "11n": "⛈",
     "13d": "🌨", "13n": "🌨",
     "50d": "🌫", "50n": "🌫"
  };

  @override
  void register() {}

  @Command("weather")
  bool onWeather(IrcCommand command) {
    if (command.arguments.isEmpty) 
      return false;
    
    var url = _getApiUrl(command.rawArgumentString);

    new http.Client().get(url).then((response) {
      String body = UTF8.decode(response.bodyBytes);
      var decoded = JSON.decode(body);

      if (decoded["cod"] == 200) {
        var ret = RETURN_STRING
          .replaceAll("%CITY%", decoded["name"])
          .replaceAll("%TEMP%", decoded["main"]["temp"].toString())
          .replaceAll("%HUMIDITY%", decoded["main"]["humidity"].toString())
          .replaceAll("%PRESSURE%", decoded["main"]["pressure"].toString());

        String weatherInfo = "";
        String weatherIcon = "";

        (decoded["weather"] as List<Map>).forEach((info) {
          if (weatherInfo.isNotEmpty) weatherInfo += ", ";
          weatherInfo += info["description"];

          if (weatherIcon.isEmpty) {
            var icon = _weatherIcons[info["icon"]];
            weatherIcon = icon + " ";
          }
        });
        weatherInfo.trim();

        ret = ret.replaceAll("%WEATHERINFO%", "${weatherIcon}${weatherInfo}");
        _server.sendMessage(command.originalMessage.returnTo, 
          "${command.originalMessage.sender.username}: ${ret}");
      }
      else {
        _server.sendNotice(command.originalMessage.sender.username, decoded["message"]);
      }
    })
    .catchError((err) {
      _server.sendNotice(command.originalMessage.sender.username, err.toString());
    });

    return true;
  }
  
  
}