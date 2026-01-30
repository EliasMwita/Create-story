import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PreferencesService extends ChangeNotifier {
  static const String _boxName = 'preferences';
  static const String _themeModeKey = 'themeMode';

  Box get _box => Hive.box(_boxName);

  ThemeMode get themeMode {
    final modeIndex = _box.get(_themeModeKey, defaultValue: ThemeMode.system.index);
    return ThemeMode.values[modeIndex];
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _box.put(_themeModeKey, mode.index);
    notifyListeners();
  }
}
