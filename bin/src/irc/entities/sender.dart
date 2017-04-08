part of irc_bot;

class Sender {
  static RegExp _senderRegex = new RegExp(r"^(?:(.+)!(.+)@)?(.+)$");

  String username;
  String ident;
  String host;

  String rawSender;

  int userLevel;

  Sender.fromRaw(String sender) {
    rawSender = sender;
    if (sender != null && sender.trim().isNotEmpty) {
      var match = _senderRegex.firstMatch(sender);

      username = match.group(1);
      ident = match.group(2);
      host = match.group(3);
    }
  }
}