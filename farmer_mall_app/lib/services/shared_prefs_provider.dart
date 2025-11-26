import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferencesAsync;

class SharedPrefsProvider {
  SharedPrefsProvider._();
  static final SharedPrefsProvider _instance = SharedPrefsProvider._();
  factory SharedPrefsProvider() => _instance;

  SharedPreferencesAsync? _prefs;

  Future<SharedPreferencesAsync> instance() async {
    if (_prefs != null) return _prefs!;
    WidgetsFlutterBinding.ensureInitialized();
    _prefs = SharedPreferencesAsync();
    return _prefs!;
  }
}

