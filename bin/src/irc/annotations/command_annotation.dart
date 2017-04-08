part of irc_bot;

class Command {
  final String name;
  final int minUserLevel;

  const Command(this.name, [this.minUserLevel = UserLevel.DEFAULT]);
}
