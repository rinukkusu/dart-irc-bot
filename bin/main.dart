import 'dart:async';
import 'src/irc_bot.dart';

Future<int> main(List<String> args) async {
  var server = new IrcConnection("irc.euirc.net")
    ..withUsername("rinubot")
    ..withRealname("hallo i bims")
    ..addChannel("#/prog/bot")
    ..addOwner("rinukkusu");

  await server.connect();

  var server2 = new IrcConnection("sub-r.de")
    ..withUsername("rinubot")
    ..withRealname("hallo i bims")
    ..addChannel("#dev")
    ..addOwner("rinukkusu");

  await server2.connect();

  return 0;
}
