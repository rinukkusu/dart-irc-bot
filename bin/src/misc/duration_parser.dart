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
