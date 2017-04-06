class IrcMessage {
  static RegExp _messageRegex = new RegExp(r"^(?:[:](\S+) )?(\S+)(?: (?!:)(.+?))?(?: [:](.+))?$");

  String host;
  String command;
  String target;
  String message;

  IrcMessage.fromRawMessage(String rawMessage) {
    var match = _messageRegex.firstMatch(rawMessage.trim());
    
    if (match != null) {
      host = match.group(1);
      command = match.group(2);
      target = match.group(3);
      message = match.group(4);
    }
  }
}
