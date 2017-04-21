part of irc_bot;

Duration parseDuration(String durationString) {
  RegExp regex =
      new RegExp(r"^(?:(\d+)d)?\s*(?:(\d+)h)?\s*(?:(\d+)m)?\s*(?:(\d+)s)?$");
  var match = regex.firstMatch(durationString);
  var days = int.parse(match?.group(1) ?? "0");
  var hours = int.parse(match?.group(2) ?? "0");
  var minutes = int.parse(match?.group(3) ?? "0");
  var seconds = int.parse(match?.group(4) ?? "0");

  return new Duration(
      days: days, hours: hours, minutes: minutes, seconds: seconds);
}

String getReadableDuration(Duration difference) {
  if (difference.inDays >= 365) {
    int val = (difference.inDays / 365).floor();
    return buildAgoString("year", val);
  } else if (difference.inDays >= 30) {
    int val = (difference.inDays / 30).floor();
    return buildAgoString("month", val);
  } else if (difference.inDays >= 7) {
    int val = (difference.inDays / 7).floor();
    return buildAgoString("week", val);
  } else if (difference.inDays >= 1) {
    int val = difference.inDays.floor();
    return buildAgoString("day", val);
  } else if (difference.inHours >= 1) {
    int val = difference.inHours.floor();
    return buildAgoString("hour", val);
  } else if (difference.inMinutes >= 1) {
    int val = difference.inMinutes.floor();
    return buildAgoString("minute", val);
  } else {
    int val = difference.inSeconds.floor();
    return buildAgoString("second", val);
  }
}

String buildAgoString(String unit, int value) {
  return value.toString() + " " + unit + (value != 1 ? "s" : "");
}
