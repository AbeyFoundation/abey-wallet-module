import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/utils/preferences_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:flutter/material.dart';

const String _themeModeKey = '_themeModeKey';
const String _directionKey = '_directionKey';
const String _kDirectionLTR = '_kDirectionLTR';
const String _kDirectionRTL = '_kDirectionRTL';

class StyleUtil {

  static ThemeMode get themeMode {
    if (PreferencesUtil.getInstance() == null) {
      return ThemeMode.system;
    }
    String themeModeString = PreferencesUtil.getString(_themeModeKey).isNotEmpty ? PreferencesUtil.getString(_themeModeKey) : Constant.ZSystemThemeModeString;
    if (themeModeString == Constant.ZLightThemeModeString) {
      return ThemeMode.light;
    }
    if (themeModeString == Constant.ZDarkThemeModeString) {
      return ThemeMode.dark;
    } else {
      return ThemeMode.system;
    }
  }

  static setThemeMode(ThemeMode themeMode) {
    if (themeMode == ThemeMode.dark) {
      PreferencesUtil.putString(_themeModeKey, Constant.ZDarkThemeModeString);
    } else {
      PreferencesUtil.putString(_themeModeKey, Constant.ZLightThemeModeString);
    }
  }

  static TextDirection get textDirection {
    String directionStr = PreferencesUtil.getString(_directionKey);
    TextDirection direction = directionStr == _kDirectionRTL ? TextDirection.rtl : TextDirection.ltr;
    return direction;
  }

  static setTextDirection(TextDirection textDirection) {
    String directionStr = textDirection == TextDirection.rtl ? _kDirectionRTL : _kDirectionLTR;
    PreferencesUtil.putString(_directionKey, directionStr);
  }

  static textStyle({double size=30, Color color=Colors.black, FontWeight weight = FontWeight.normal}) {
    return TextStyle(
        fontSize: SizeUtil.sp(size),
        color: color,
        fontWeight: weight,
        decoration: TextDecoration.none);
  }
}