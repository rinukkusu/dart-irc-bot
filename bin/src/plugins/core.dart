part of irc_bot;

class CorePlugin implements IrcPluginBase {
  IrcConnection _server;

  @override
  void register(IrcConnection server) {
    _server = server;
    _server.addCommand("help", onHelp);
    _server.addCommand("commands", onCommands);
  }

  void onHelp(IrcCommand command) {
    //_server.sendMessage(message.originalMessage.returnTo, "");
  }

  void onCommands(IrcCommand command) {
    var commands = _server._commands.keys.toList()..sort();

    _server.sendMessage(command.originalMessage.returnTo,
        "${command.originalMessage.sender.username}: ${commands}");
  }
}
