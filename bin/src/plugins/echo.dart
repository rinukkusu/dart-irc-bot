import '../irc/entities/irc_command.dart';
import '../irc/plugin_base.dart';
import '../irc/server.dart';

class EchoPlugin implements IrcPluginBase {
  IrcServer _server;

  @override
  void register(IrcServer server) {
    _server = server;
    _server.commands.listen(onCommand);
  }

  void onCommand(IrcCommand message) {
    if (message.command == "echo")
      _server.sendMessage(message.originalMessage.returnTo, message.rawArgumentString);
  }
}
