part of irc_bot;

class CorePlugin extends IrcPluginBase {
  @override
  void register() {
    _server.commands.listen(handleCommand);
  }

  void handleCommand(IrcCommand command) {
    if (_server._commands.keys.any((x) => x.name == command.command)) {
      var commandMeta = _server._commands.keys.firstWhere((x) => x.name == command.command);

      if (command.originalMessage.sender.userLevel >= commandMeta.minUserLevel) {
        var handler = _server._commands[commandMeta];
        handler(command);
      }
      else {
        _server.sendNotice(command.originalMessage.sender.username, Messages.COMMAND_NO_PERMISSION);
      }
    }
  }

  @Command("help")
  void onHelp(IrcCommand command) {
    //_server.sendMessage(message.originalMessage.returnTo, "");
  }

  @Command("commands")
  void onCommands(IrcCommand command) {
    var commands = _server._commands.keys.toList()
      ..sort((x, y) => x.name.compareTo(y.name))
      ..removeWhere((x) => command.originalMessage.sender.userLevel < x.minUserLevel);

    _server.sendMessage(command.originalMessage.returnTo,
        "${command.originalMessage.sender.username}: ${commands.map((x) => x.name).toList()}");
  }

  @Command("join", UserLevel.OWNER)
  void onJoin(IrcCommand command) {
    if (command.arguments.isEmpty) return;

    var channel = command.arguments.first;
    _server._joinChannel(channel);
  }

  @Command("part", UserLevel.OWNER)
  void onPart(IrcCommand command) {
    var channel = command.originalMessage.target;

    if (command.arguments.isNotEmpty)
      channel = command.arguments.first;
    
    _server._partChannel(channel);
  }
}
