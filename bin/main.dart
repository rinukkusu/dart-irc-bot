import 'src/irc_bot.dart';

main(List<String> args) async {
  var server = new IrcServer("irc.euirc.net")
    ..withUsername("rinubot")
    ..withRealname("hallo i bims");

  await server.connect();
}
