part of irc_bot;

class Command {
  final String name;
  final List<String> arguments;
  final int minUserLevel;

  const Command(this.name, 
    [this.arguments = const [], this.minUserLevel = UserLevel.DEFAULT]);
}
