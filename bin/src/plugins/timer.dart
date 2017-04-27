part of irc_bot;

class TimerPlugin extends IrcPluginBase {
  @override
  void register() {}

  @Command("timer", const ["time", "?message"])
  bool onTimer(IrcCommand command) {
    Duration duration = parseDuration(command.arguments.first);
    if (duration == null) return false;

    var message =
        command.arguments.length > 1 ? command.arguments[1] : "Timer ran out!";
    if (duration.inSeconds < 1) {
      _server.sendMessage(command.originalMessage.returnTo,
          "${command.originalMessage.sender.username}: Time lower than 1 second.");
      return false;
    }

    var readableDuration = getReadableDuration(duration);
    _server.sendMessage(command.originalMessage.returnTo,
        "${command.originalMessage.sender.username}: Reminding you in ~${readableDuration}");

    new Timer(duration, () {
      _server.sendMessage(command.originalMessage.returnTo,
          "${command.originalMessage.sender.username}: ${message}");
    });

    return true;
  }
}
