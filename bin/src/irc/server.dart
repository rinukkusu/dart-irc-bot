import 'dart:io';
import 'entities/irc_message.dart';

class IrcServer {
  Socket _socket;

  IrcServer.connect(String host, [int port = 6667]) {
    Socket.connect(host, port).then((socket) {
      _socket = socket;
      _authenticate();
      socket.listen(onData);
    });
  }

  void _sendRaw(String message) {
    _socket.add("${message}\r\n".codeUnits);
    print("<< ${message}");
  }

  void _authenticate() {
    _sendRaw("NICK dartbot");
    _sendRaw("USER dartbot 0 * :dartbot");
  }

  void onData(List<int> data) {
    String messageRaw = new String.fromCharCodes(data);
    var messages = messageRaw
      .replaceAll("\r", "")
      .split("\n");

    messages.forEach((message) {
      if (message.trim().length != 0) {
        print(">> ${message}");

        var ircMessage = new IrcMessage.fromRawMessage(message);
        if (ircMessage != null) {
          _handleMessage(ircMessage);
        }
      }
    });
  }

  void _handleMessage(IrcMessage message) {
    switch (message.command) {
      case "PING":
        _sendRaw("PONG :${message.message}");
        break;

      default:
        break;
    }
  }
}
