import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

class PreferencesUtil {
  static PreferencesUtil? _singleton;
  static SharedPreferences? _prefs;
  static Lock _lock = Lock();

  static getInstance() async {
    if (_singleton == null) {
      await _lock.synchronized(() async {
        if(_singleton == null) {
          var singleton = PreferencesUtil._();
          await singleton._init();
          _singleton = singleton;
        }
      });
    }
  }

  PreferencesUtil._();

  Future _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool>? putObject(String key, Object value) {
    if (_prefs == null) return null;
    return _prefs!.setString(key, value == null ? "" : json.encode(value));
  }

  static Map? getObject(String key) {
    if (_prefs == null) return null;
    String _data = _prefs!.getString(key)!;
    return (_data == null || _data.isEmpty) ? null : json.decode(_data);
  }

  static Object? getObject2(String key) {
    if (_prefs == null) return null;
    String _data = _prefs!.getString(key)!;
    return (_data == null || _data.isEmpty) ? null : json.decode(_data);
  }

  static Future<bool>? putObjectList(String key, List<Object> list) {
    if (_prefs == null) return null;
    List<String> _dataList = list.map((value) {
      return json.encode(value);
    }).toList();
    return _prefs!.setStringList(key, _dataList);
  }

  static List<Map>? getObjectList(String key) {
    if (_prefs == null) return null;
    List<String> dataLis = _prefs!.getStringList(key)!;
    return dataLis.map((value) {
      Map _dataMap = json.decode(value);
      return _dataMap;
    }).toList();
  }

  static String getString(String key, {String defValue = ''}) {
    if (_prefs == null) return defValue;
    return _prefs!.getString(key) ?? defValue;
  }

  static Future<bool>? putString(String key, String value) {
    if (_prefs == null) return null;
    return _prefs!.setString(key, value);
  }

  static bool getBool(String key, {bool defValue = false}) {
    if (_prefs == null) return defValue;
    return _prefs!.getBool(key) ?? defValue;
  }

  static Future<bool>? putBool(String key, bool value) {
    if (_prefs == null) return null;
    return _prefs!.setBool(key, value);
  }

  static int getInt(String key, {int defValue = 0}) {
    if (_prefs == null) return defValue;
    return _prefs!.getInt(key) ?? defValue;
  }

  static Future<bool>? putInt(String key, int value) {
    if (_prefs == null) return null;
    return _prefs!.setInt(key, value);
  }

  static double getDouble(String key,  double defValue  ) {
    if (_prefs == null) return defValue;
    return _prefs!.getDouble(key) ?? defValue;
  }

  static Future<bool>? putDouble(String key, double value) {
    if (_prefs == null) return null;
    return _prefs!.setDouble(key, value);
  }

  static List<String> getStringList(String key, {List<String> defValue = const []}) {
    if (_prefs == null) return [];
    return _prefs!.getStringList(key) ?? [];
  }

  static Future<bool>? putStringList(String key, List<String> value) {
    if (_prefs == null) return null;
    return _prefs!.setStringList(key, value);
  }

  static dynamic getDynamic(String key, {Object? defValue}) {
    if (_prefs == null) return defValue;
    return _prefs!.get(key) ?? defValue;
  }

  static bool? haveKey(String key) {
    if (_prefs == null) return null;
    return _prefs!.getKeys().contains(key);
  }

  static Set<String>? getKeys() {
    if (_prefs == null) return null;
    return _prefs!.getKeys();
  }

  static Future<bool>? remove(String key) {
    if (_prefs == null) return null;
    return _prefs!.remove(key);
  }

  static Future<bool>? clear() {
    if (_prefs == null) return null;
    return _prefs!.clear();
  }

  static bool isInitialized() {
    return _prefs != null;
  }
}