import 'dart:io';
import 'dart:async';

import 'entities/irc_message.dart';

class IrcServer {
  Socket _socket;

  String _host;
  int _port;
  String _username = "dartbot";
  String _realname = "Insane Bot";
  String _password;

  IrcServer(String host, [int port = 6667]) {
    _host = host;
    _port = port;
  }

  void withUsername(String username) => _username = username;
  void withRealname(String realname) => _realname = realname;
  void withPassword(String password) => _password = password;

  Future<Null> connect() async {
    _socket = await Socket.connect(_host, _port);
    _socket.listen(_onData);

    _authenticate();
  }

  void _sendRaw(String message) {
    _socket.add("${message}\r\n".codeUnits);
    print("<< ${message}");
  }

  void _authenticate() {
    _sendRaw("NICK ${_username}");
    _sendRaw("USER ${_username} 0 * :${_realname}");
  }

  void _onData(List<int> data) {
    String messageRaw = new String.fromCharCodes(data);
    var messages = messageRaw.replaceAll("\r", "").split("\n");

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
