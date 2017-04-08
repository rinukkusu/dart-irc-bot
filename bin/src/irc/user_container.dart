part of irc_bot;

class UserContainer {
  Map<String, int> _users = new Map<String, int>();

  void addUser(String name, int userLevel) {
    _users.putIfAbsent(name, () => userLevel);
  }

  bool removeUser(String name) {
    if (!_users.containsKey(name)) return false;
    if (_users[name] == UserLevel.OWNER) return false;
        
    _users.remove(name);
    return true;
  }

  int getLevel(String name) {
    if (!_users.containsKey(name)) return UserLevel.DEFAULT;

    return _users[name];
  }
}