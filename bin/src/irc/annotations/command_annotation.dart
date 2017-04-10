part of irc_bot;

class Command {
  final String name;
  final List<String> arguments;
  final int minUserLevel;
  final List<String> alias;

  const Command(this.name,
      [this.arguments = const [], this.minUserLevel = UserLevel.DEFAULT, this.alias = const []]);
}
