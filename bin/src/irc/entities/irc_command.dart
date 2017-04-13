part of irc_bot;

class IrcCommand {
  static String commandChar = "_";
  static RegExp _commandRegex = new RegExp("^${commandChar}(\\w+)\\s?(.*)\$");

  IrcMessage originalMessage;
  String command;
  List<String> arguments;
  String rawArgumentString;

  IrcCommand.fromIrcMessage(IrcMessage message) {
    originalMessage = message;

    var match = _commandRegex.firstMatch(message.message);
    command = match.group(1);
    rawArgumentString = match.group(2);

    arguments = _parseArguments(rawArgumentString);
  }

  List<String> _parseArguments(String argumentString) {
    List<String> arguments = new List<String>();
    argumentString = argumentString.trim();

    String singleArgument = "";
    bool inQuotes = false;
    for (int i = 0; i < argumentString.length; i++) {
      String c = argumentString[i];

      if (c == '\'') {
        inQuotes = !inQuotes;
        continue;
      }

      if (c == ' ') {
        if (inQuotes) {
          singleArgument += c;
        } else {
          arguments.add(singleArgument);
          singleArgument = "";
        }
      } else {
        singleArgument += c;
      }
    }

    if (singleArgument.length > 0) {
      arguments.add(singleArgument);
    }

    return arguments;
  }
}
