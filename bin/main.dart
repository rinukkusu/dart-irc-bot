import 'dart:async';
import 'src/irc_bot.dart';

Future<int> main(List<String> args) async {
  var server = new IrcConnection("irc.euirc.net")
    ..withUsername("dartisan-test")
    ..withRealname("hallo i bims")
    ..addChannel("#/prog/bot")
    ..addOwner("rinukkusu");

  await server.connect();

  return 0;
}
