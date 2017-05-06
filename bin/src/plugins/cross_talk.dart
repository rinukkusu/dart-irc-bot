part of irc_bot;

class Person {
  String name;
  IrcConnection server;
  String botName;

  Person(this.name, this.server);

  Person.fromString(String person, IrcConnection defaultServer) {
    if (person.contains("@")) {
      var parts = person.split("@");
      name = parts[0];
      server = IrcConnection._connections[parts[1]];
    }
    else {
      name = person;
      server = defaultServer;
    }

    botName = server._username;
  }
}

class CrossTalk {
  Person person1;
  Person person2;
  String registeredChannel;

  CrossTalk(this.person1, this.person2, this.registeredChannel);

  bool isUserPart(String name) => person1.name == name || person2.name == name;
  Person getPerson(String name) => person1.name == name ? person1 : person2;
  Person getOtherPerson(String sender) => person1.name == sender ? person2 : person1;
}

class CrossTalkPlugin extends IrcPluginBase {
  Map<int, CrossTalk> _xtalks = new Map();

  @override
  void register() {
    _server.messages.listen(onData);
  }

  void onData(IrcMessage msg) {
    if (msg.target != _server._username) 
      return;

    var xtalk = _xtalks.values
        .firstWhere((x) => x.isUserPart(msg.sender.username), orElse: () => null);
    if (xtalk == null)
      return;
    
    var sender = msg.sender.username;
    var target = xtalk.getOtherPerson(msg.sender.username);

    target.server.sendMessage(target.name, msg.message);
    _server.sendMessage(xtalk.registeredChannel, "<$sender> ${msg.message}");
  }

  @Command("xtalk", const ["person1", "person2"])
  bool onStartCrossTalk (IrcCommand command) {
    var id = _xtalks.length;
    var p1 = new Person.fromString(command.arguments[0], _server);
    var p2 = new Person.fromString(command.arguments[1], _server);

    _xtalks[id] = new CrossTalk(p1, p2, command.originalMessage.returnTo);

    _server.sendMessage(command.originalMessage.returnTo, _T(Messages.XTALK_CREATED, <String>[id.toString(), p1.name, p2.name]));

    return true;
  }

  @Command("xtalksay", const ["id", "person", "text"]) 
  bool onSayCrossTalk(IrcCommand command) {
    if (!_xtalks.containsKey(int.parse(command.arguments[0])))
      return false;

    var id = int.parse(command.arguments[0]);
    var target = _xtalks[id].getPerson(command.arguments[1]);
    var message = command.arguments[2];

    target.server.sendMessage(target.name, message);

    return true;
  }

  @Command("xtalkdel", const ["id"]) 
  bool onDelCrossTalk(IrcCommand command) {
    var id = int.parse(command.arguments[0]);

    if (!_xtalks.containsKey(id))
      return false;

    _xtalks.remove(id);

    _server.sendMessage(command.originalMessage.returnTo, _T(Messages.XTALK_DELETED, <String>[id.toString()]));

    return true;
  }
}