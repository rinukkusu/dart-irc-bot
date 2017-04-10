part of irc_bot;

class Messages {
  static const String COMMAND_NO_PERMISSION = "Insufficient permissions.";
  static const String COMMAND_WRONG_USAGE = "Usage: {1} {2}";

  static const String PING_NOT_ALLOWED =
      "I'm not allowed to send PINGs for like {1} seconds.";

  static const String EDIT_CONFIG_ERROR = "Please edit the config file at '{1}'.";

  static const String WEATHER_LOCATION_SET =
      "Your location has been updated to '{1}'.";
  static const String WEATHER_LOCATION_MISSING =
      "You need to set your location to use this command without parameters.";
}

String _T(String template, [List<dynamic> params = null]) {
  var finalString = template;

  if (params != null && params.length > 0) {
    for (int i = 1; i <= params.length; i++) {
      finalString = finalString.replaceAll("{${i}}", params[i - 1].toString());
    }
  }

  return finalString;
}
