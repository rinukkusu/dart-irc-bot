part of irc_bot;

class Messages {
  static const String COMMAND_NO_PERMISSION = "Insufficient permissions.";
  static const String COMMAND_WRONG_USAGE = "Usage: {1} {2}";
  static const String COMMAND_NO_EXISTS = "Command does not exist: {1}";

  static const String PING_NOT_ALLOWED =
      "I'm not allowed to send PINGs for like {1} seconds.";

  static const String EDIT_CONFIG_ERROR =
      "Please edit the config file at '{1}'.";

  static const String WEATHER_LOCATION_SET =
      "Your location has been updated to '{1}'.";
  static const String WEATHER_LOCATION_MISSING =
      "You need to set your location to use this command without parameters.";

  static const String IGNORE_USER_DURATION =
      "Ignoring user '{1}' for a duration of {2}.";
  static const String IGNORE_USER_FOREVER = "Ignoring user '{1}' forever.";

  static const String RSS_FEED_ADD_SUCCESS =
      "Successfully added feed for '{1}'";
  static const String RSS_FEED_ADD_FAILURE =
      "A feed with that title already exists.";
  static const String RSS_FEED_PARSE_FAILURE =
      "Feed '{1}' didn't look like a valid RDF/RSS or Atom feed and has been removed.";
  static const String RSS_FEED_DELETE_SUCCESS =
      "Successfully deleted feed '{1}'.";
  static const String RSS_FEED_NON_EXISTANT =
      "There is no feed with that title.";
  static const String RSS_FEED_OUTPUT = "[RSS/{1}] {2} - {3}";
  static const String RSS_FEED_ERROR = "[ERROR/{1}] {2}";

  static const String XTALK_CREATED = "Started XTalk with ID {1} for {2} and {3}.";
  static const String XTALK_DELETED = "Deleted XTalk with ID {1}.";
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
