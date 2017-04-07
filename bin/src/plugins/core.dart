part of irc_bot;

class CorePlugin implements IrcPluginBase {
  IrcConnection _server;

  @override
  void register(IrcConnection server) {
    _server = server;
    _server.commands.listen(handleCommand);
  }

  void handleCommand(IrcCommand command) {
    if (_server._commands.containsKey(command.command)) {
      var handler = _server._commands[command.command];
      handler(command);
    }
  }

  @Command("help")
  void onHelp(IrcCommand command) {
    //_server.sendMessage(message.originalMessage.returnTo, "");
  }

  @Command("commands")
  void onCommands(IrcCommand command) {
    var commands = _server._commands.keys.toList()..sort();

    _server.sendMessage(command.originalMessage.returnTo,
        "${command.originalMessage.sender.username}: ${commands}");
  }
}
