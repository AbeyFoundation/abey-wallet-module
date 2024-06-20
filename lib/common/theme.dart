import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/utils/style_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final ThemeData kLightTheme = _buildLightTheme();
final ThemeData kDarkTheme = _buildDarkTheme();

TextTheme _buildTextTheme(TextTheme base) {
  return base.copyWith(
    headline6: base.headline6!.copyWith(
      fontFamily: 'GoogleSans',
    ),
  );
}

ThemeData _buildLightTheme() {
  const Color primaryColor = Color(0xFF345B9A);
  Color secondaryColor = Color(0xFF095093);
  final ColorScheme colorScheme = const ColorScheme.light().copyWith(
    primary: primaryColor,
    secondary: secondaryColor,
  );
  final ThemeData base = ThemeData(
      platform: TargetPlatform.iOS,
      brightness: Brightness.light,
      primaryColor: ZColors.ZFFEECC5B,
      primaryTextTheme: TextTheme(
        headline1: StyleUtil.textStyle(size: 33, color: Colors.black,weight: FontWeight.bold),
        headline2: StyleUtil.textStyle(size: 28, color: Colors.black,weight: FontWeight.bold),
        headline3: StyleUtil.textStyle(size: 18, color: Colors.black,weight: FontWeight.bold),
        headline4: StyleUtil.textStyle(size: 12, color: Colors.black),
        headline5: StyleUtil.textStyle(size: 18, color: Colors.black),
        headline6: StyleUtil.textStyle(size: 14, color: Colors.black),
        bodyText1: StyleUtil.textStyle(size: 14, color: Colors.black),
        bodyText2: StyleUtil.textStyle(size: 12, color: Colors.black),
        subtitle1: TextStyle(fontSize: SizeUtil.sp(14),color: Colors.grey,fontWeight: FontWeight.normal),
        subtitle2: TextStyle(fontSize: SizeUtil.sp(12),color: Colors.grey,fontWeight: FontWeight.normal),
      ),
      primaryIconTheme: IconThemeData(color: Colors.black),
      scaffoldBackgroundColor: Colors.white,
      canvasColor: ZColors.ZFFFAFAFA,
      textSelectionTheme: TextSelectionThemeData(cursorColor: ZColors.ZFFEECC5B,),
      appBarTheme: AppBarTheme(
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(fontSize: 30, color: Colors.black)),
      tabBarTheme: TabBarTheme(
          labelColor: Colors.black,
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelColor: Colors.grey,
          unselectedLabelStyle:  TextStyle(fontWeight: FontWeight.normal)
      )
  );
  return base.copyWith(
    textTheme: _buildTextTheme(base.textTheme),
    primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
    accentTextTheme: _buildTextTheme(base.accentTextTheme),
  );
}

ThemeData _buildDarkTheme() {
  const Color primaryColor = Color(0xFF34355D);
  const Color secondaryColor = Color(0xFF5F58A0);
  final ColorScheme colorScheme = const ColorScheme.dark().copyWith(
    primary: primaryColor,
    secondary: secondaryColor,
  );
  final ThemeData base = ThemeData(
    brightness: Brightness.dark,
    accentColorBrightness: Brightness.dark,
    primaryColor: primaryColor,
    primaryColorDark: const Color(0xFF345B9A),
    appBarTheme: AppBarTheme(
      color: Color(0xFF34355D),
      textTheme: TextTheme().apply(displayColor: Color(0xFFD1DAFE)),
    ),
    primaryColorLight: secondaryColor,
    buttonColor: primaryColor,
    indicatorColor: Colors.white,
    toggleableActiveColor: primaryColor,
    accentColor: secondaryColor,
    canvasColor: const Color(0xFF34355D),
    scaffoldBackgroundColor: Color(0xFF34355D),
    backgroundColor: Color(0xFF34355D),
    cardColor: Color(0xFF34355D),
    errorColor: const Color(0xFFB00020),
    buttonTheme: ButtonThemeData(
      colorScheme: colorScheme,
      textTheme: ButtonTextTheme.primary,
    ),
    cupertinoOverrideTheme: CupertinoThemeData(
      primaryColor: primaryColor,
      brightness: Brightness.dark,
    ),
  );
  return base.copyWith(
    textTheme: _buildTextTheme(base.textTheme).apply(
      bodyColor: Color(0xFFEDEDED),
    ),
    primaryTextTheme: _buildTextTheme(base.primaryTextTheme).apply(
      displayColor: Color(0xFFEDEDED),
      bodyColor: Color(0xFFEDEDED),
    ),
    accentTextTheme: _buildTextTheme(base.accentTextTheme),
  );
}
