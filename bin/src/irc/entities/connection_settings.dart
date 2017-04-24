part of irc_bot;

class ConnectionSettings {
  String host = "irc.example.net";
  int port = 6667;
  String username = "dartbot";
  String realname = "Insane Bot";
  String password;
  String commandChar = "_";
  List<String> channels = ["#channel"];
  List<String> owners = ["username"];

  ConnectionSettings();

  ConnectionSettings.fromMap(Map<String, dynamic> map) {
    host = map["host"] as String;
    port = map["port"] as int;
    username = map["username"] as String ?? username;
    realname = map["realname"] as String ?? username;
    password = map["password"] as String;
    commandChar = map["commandChar"] as String ?? commandChar;
    channels = (map["channels"] as List<String>).toList();
    owners = (map["owners"] as List<String>).toList();
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "host": host,
      "port": port,
      "username": username,
      "realname": realname,
      "password": password,
      "commandChar": commandChar,
      "channels": channels.toList(),
      "owners": owners.toList()
    };
  }
}
