import 'dart:async';
import 'src/irc_bot.dart';

Future<int> main(List<String> args) async {
  var servers = await IrcConnection.loadFromConfig();

  servers.forEach((server) async => await server.connect());

  return 0;
}
