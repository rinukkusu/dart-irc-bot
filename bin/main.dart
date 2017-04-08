import 'src/irc_bot.dart';

main(List<String> args) async {
  var server = new IrcConnection("irc.euirc.net")
    ..withUsername("rinubot")
    ..withRealname("hallo i bims")
    ..addChannel("#/prog/bot")
    ..addOwner("rinukkusu");

  await server.connect();
}
