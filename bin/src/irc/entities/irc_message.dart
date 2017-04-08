part of irc_bot;

class IrcMessage {
  static RegExp _messageRegex =
      new RegExp(r"^(?:[:](\S+) )?(\S+)(?: (?!:)(.+?))?(?: [:](.+))?$");

  Sender sender;
  String type;
  String target;
  String message;
  String returnTo;

  String rawMessage;

  IrcMessage.fromRawMessage(String rawMessage) {
    this.rawMessage = rawMessage;
    var match = _messageRegex.firstMatch(rawMessage.trim());

    if (match != null) {
      sender = new Sender.fromRaw(match.group(1));
      type = match.group(2);
      target = match.group(3);
      message = match.group(4);

      if (target != null) {
        if (target.startsWith("#")) {
          returnTo = target;
        } else {
          returnTo = sender.username;
        }
      }
      
    }
  }
}
