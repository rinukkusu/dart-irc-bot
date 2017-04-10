part of irc_bot;

class UserContainer {
  Map<String, int> _users = new Map<String, int>();
  List<String> _ignoredUsers = new List<String>();

  void addUser(String name, int userLevel) {
    if (userLevel == UserLevel.IGNORED)
      _ignoredUsers.add(name);
    else {
      if (_ignoredUsers.contains(name))
        _ignoredUsers.remove(name);
      else
        _users[name] = userLevel;
    }
  }

  bool removeUser(String name) {
    if (!_users.containsKey(name)) return false;
    if (_users[name] == UserLevel.OWNER) return false;

    _users.remove(name);
    return true;
  }

  int getLevel(String name) {
    if (_ignoredUsers.contains(name)) return UserLevel.IGNORED;

    return getActualLevel(name);
  }

  int getActualLevel(String name) {
    if (!_users.containsKey(name)) return UserLevel.DEFAULT;

    return _users[name];
  }
}
