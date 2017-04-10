part of irc_bot;

class JsonConfig {
  static const String CONFIG_PATH = "./config";
  Map<String, dynamic> _config = new Map();
  String _fileName;
  String getPath() => _getPath(_fileName);
  static String _getPath(fileName) => "${CONFIG_PATH}/${fileName}";

  static JsonConfig fromMap(String fileName, Map<String, dynamic> config) {
    JsonConfig _this = new JsonConfig();
    _this._config = config;
    _this._fileName = fileName;
    return _this;
  }

  static Future<JsonConfig> fromPath(String fileName) async {
    JsonConfig _this = JsonConfig.fromMap(fileName, {});

    await _ensurePath(fileName, true, _this);
    var contents = await new File(_getPath(fileName)).readAsString();
    _this._config = JSON.decode(contents);

    return _this;
  }

  static Future<Null> _ensurePath(String fileName, [bool callSave = false, JsonConfig _this = null]) async {
    var dir = new Directory(CONFIG_PATH);
    if (!(await dir.exists())) {
      await dir.create();
    }

    var file = new File(_getPath(fileName));
    if (callSave && !(await file.exists())) {
      await _this.save(fileName);
    }
  }

  dynamic get(String key, [dynamic ifAbsent = null]) {
    if (_config.containsKey(key))
      return _config[key];

    _config.putIfAbsent(key, () => ifAbsent);
    return ifAbsent;
  }

  void set(String key, dynamic value) {
    _config.putIfAbsent(key, () => value);
  }

  Future<Null> save([String fileName = null]) async {
    fileName ??= _fileName;
    await _ensurePath(fileName);
    var contents = JSON.encode(_config);
    await new File(_getPath(fileName)).writeAsString(contents, flush: true);
  }
}