part of irc_bot;

Duration parseDuration(String durationString) {
  RegExp regex =
      new RegExp(r"^(?:(\d+)d)?\s*(?:(\d+)h)?\s*(?:(\d+)m)?\s*(?:(\d+)s?)?$");
  var match = regex.firstMatch(durationString);
  var days = int.parse(match?.group(1) ?? "0");
  var hours = int.parse(match?.group(2) ?? "0");
  var minutes = int.parse(match?.group(3) ?? "0");
  var seconds = int.parse(match?.group(4) ?? "0");

  var duration = new Duration(
      days: days, hours: hours, minutes: minutes, seconds: seconds);

  if (duration.inDays > 1000) {
    return null;
  }

  return duration;
}

String getReadableDuration(Duration difference) {
  if (difference.inDays >= 365) {
    var val = difference.inDays / 365;
    return buildAgoString("year", val);
  } else if (difference.inDays >= 30) {
    var val = difference.inDays / 30;
    return buildAgoString("month", val);
  } else if (difference.inDays >= 7) {
    var val = difference.inDays / 7;
    return buildAgoString("week", val);
  } else if (difference.inDays >= 1) {
    var val = difference.inHours / 24;
    return buildAgoString("day", val);
  } else if (difference.inHours >= 1) {
    var val = difference.inMinutes / 60;
    return buildAgoString("hour", val);
  } else if (difference.inMinutes >= 1) {
    var val = difference.inSeconds / 60;
    return buildAgoString("minute", val);
  } else {
    var val = difference.inSeconds;
    return buildAgoString("second", val);
  }
}

String buildAgoString(String unit, num value) {
  return value.toStringAsFixed(1) + " " + unit + (value != 1 ? "s" : "");
}
