part of irc_bot;

class CommandDispatcher {
  IrcConnection _connection;

  CommandDispatcher(this._connection) {
    _connection.commands.listen(handleCommand);
  }

  void handleCommand(IrcCommand command) {
    if (_connection._commands.containsKey(command.command)) {
      var handler = _connection._commands[command.command];
      handler(command);
    }
  }
}
