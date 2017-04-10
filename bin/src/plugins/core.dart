part of irc_bot;

class CorePlugin extends IrcPluginBase {
  @override
  void register() {
    _server.commands.listen(handleCommand);
  }

  void handleCommand(IrcCommand command) {
    if (_server._commands.keys.any((x) =>
        x.name == command.command || x.alias.contains(command.command))) {
      var commandMeta = _server._commands.keys.firstWhere((x) =>
          x.name == command.command || x.alias.contains(command.command));

      if (command.originalMessage.sender.userLevel < commandMeta.minUserLevel) {
        _server.sendNotice(command.originalMessage.sender.username,
            Messages.COMMAND_NO_PERMISSION);
        return;
      }

      int minLength =
          commandMeta.arguments.where((x) => !x.startsWith("?")).length;
      int maxLength = commandMeta.arguments.length;

      if (command.arguments.length < minLength ||
          command.arguments.length > maxLength) {
        var argumentString = "";
        commandMeta.arguments.forEach((arg) {
          argumentString +=
              arg.startsWith("?") ? "[${arg.substring(1)}] " : "<${arg}> ";
        });
        _server.sendNotice(
            command.originalMessage.sender.username,
            _T(Messages.COMMAND_WRONG_USAGE,
                [commandMeta.name, argumentString]));
        return;
      }

      var handler = _server._commands[commandMeta];
      bool result = (handler(command) as InstanceMirror).reflectee as bool;
      print(result);
    }
  }

  @Command("help")
  bool onHelp(IrcCommand command) {
    var commands = _server._commands.keys.toList()
      ..sort((x, y) => x.name.compareTo(y.name))
      ..removeWhere(
          (x) => command.originalMessage.sender.userLevel < x.minUserLevel);

    var filteredCommands = commands.map((x) {
      var c = "${x.name}";
      if (x.alias.isNotEmpty) {
        c += "|" + x.alias.join("|");
      }
      return c;
    });

    _server.sendMessage(command.originalMessage.returnTo,
        "${command.originalMessage.sender.username}: ${filteredCommands.toList()}");

    return true;
  }

  @Command("join", const ["channel"], UserLevel.OWNER)
  bool onJoin(IrcCommand command) {
    if (command.arguments.isEmpty) return false;

    var channel = command.arguments.first;
    _server._joinChannel(channel);

    return true;
  }

  @Command("part", const ["channel"], UserLevel.OWNER)
  bool onPart(IrcCommand command) {
    var channel = command.originalMessage.target;

    if (command.arguments.isNotEmpty) channel = command.arguments.first;

    _server._partChannel(channel);

    return true;
  }

  @Command("ignore", const ["user", "?duration"], UserLevel.OWNER)
  bool onIgnore(IrcCommand command) {
    var user = command.arguments.first;
    if (_server._userContainer.getActualLevel(user) == UserLevel.OWNER)
      return false;

    var duration = parseDuration(command.arguments.last);

    _server.ignoreUser(user);
    var returnMessage = "";

    if (duration.inSeconds > 0) {
      new Timer(duration, () => _server.resetUser(user));
      returnMessage =
          _T(Messages.IGNORE_USER_DURATION, [user, duration.toString()]);
    } else {
      returnMessage = _T(Messages.IGNORE_USER_FOREVER, [user]);
    }

    _server.sendMessage(command.originalMessage.returnTo,
        "${command.originalMessage.sender.username}: ${returnMessage}");

    return true;
  }

  @Command("pardon", const ["user"], UserLevel.OWNER)
  bool onPardon(IrcCommand command) {
    var user = command.arguments.first;

    _server.resetUser(user);

    return true;
  }

  @Command("quit", const ["?message"], UserLevel.OWNER)
  bool onQuit(IrcCommand command) {
    var message =
        command.arguments.isNotEmpty ? command.arguments.first : "Bye.";
    _server._sendRaw("QUIT :${message}");

    exit(0);

    return true;
  }
}
