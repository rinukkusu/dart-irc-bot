part of irc_bot;

class CrossTalk {
  String person1;
  String person2;
  String registeredChannel;

  CrossTalk(this.person1, this.person2, this.registeredChannel);

  bool isUserPart(String name) => person1 == name || person2 == name;
  String getOtherPerson(String sender) => person1 == sender ? person2 : person1;
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

    _server.sendMessage(target, msg.message);
    _server.sendMessage(xtalk.registeredChannel, "<$sender> ${msg.message}");
  }

  @Command("xtalk", const ["person1", "person2"])
  bool onStartCrossTalk (IrcCommand command) {
    var id = _xtalks.length;
    _xtalks[id] = new CrossTalk(command.arguments[0], command.arguments[1], command.originalMessage.returnTo);

    return true;
  }
}