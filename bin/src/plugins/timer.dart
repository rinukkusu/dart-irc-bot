part of irc_bot;

class TimerPlugin extends IrcPluginBase {
  @override
  void register() {}

  @Command("timer", const ["time", "?message"])
  bool onTimer(IrcCommand command) {
    Duration duration = parseDuration(command.arguments.first);
    var message =
        command.arguments.length > 1 ? command.arguments[1] : "Aufgemerkt!";
    if (duration.inSeconds < 1)
      _server.sendMessage(command.originalMessage.returnTo,
          "${command.originalMessage.sender.username}: time lower than 1 second.");

    new Timer(duration, () {
      _server.sendMessage(command.originalMessage.returnTo,
          "${command.originalMessage.sender.username}: {message}");
    });
  }
}
