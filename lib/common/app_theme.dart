import 'package:abey_wallet/common/zcolor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppTheme {
  AppTheme._();

  static const String fontName = 'WorkSans';

  static TextStyle text30({double fontSize = 30, Color color = ZColors.ZFFFFFFFF, FontWeight fontWeight = FontWeight.w700}) {
    return TextStyle(
      fontFamily: fontName,
      fontWeight: fontWeight,
      fontSize: fontSize,
      letterSpacing: 0.25,
      color: color,
    );
  }

  static TextStyle text20({double fontSize = 20, Color? color, FontWeight fontWeight = FontWeight.w700}) {
    return TextStyle(
        fontFamily: fontName,
        fontWeight: fontWeight,
        fontSize: fontSize,
        letterSpacing: 0.25,
        color: color != null ? color : ZColors.KFF033B19Theme(Get.context!),
    );
  }

  static TextStyle text18({double fontSize = 18, Color? color, FontWeight fontWeight = FontWeight.w700}) {
    return TextStyle(
      fontFamily: fontName,
      fontWeight: fontWeight,
      fontSize: fontSize,
      letterSpacing: 0.2,
      color: color != null ? color : ZColors.KFF033B19Theme(Get.context!),
    );
  }

  static TextStyle text16({double fontSize = 16, Color? color, FontWeight fontWeight = FontWeight.w400}) {
    return TextStyle(
      fontFamily: fontName,
      fontWeight: fontWeight,
      fontSize: fontSize,
      letterSpacing: 0.15,
      color: color != null ? color : ZColors.KFF033B19Theme(Get.context!),
    );
  }

  static TextStyle text14({double fontSize = 14, Color? color, FontWeight fontWeight = FontWeight.w400}) {
    return TextStyle(
      fontFamily: fontName,
      fontWeight: fontWeight,
      fontSize: fontSize,
      letterSpacing: 0.1,
      color: color != null ? color : ZColors.KFF033B19Theme(Get.context!),
    );
  }

  static TextStyle text12({double fontSize = 12, Color? color, FontWeight fontWeight = FontWeight.w400}) {
    return TextStyle(
      fontFamily: fontName,
      fontWeight: fontWeight,
      fontSize: fontSize,
      letterSpacing: 0.05,
      color: color != null ? color : ZColors.KFFA0A0A8Theme(Get.context!),
    );
  }

  static TextStyle text11({double fontSize = 11, Color? color, FontWeight fontWeight = FontWeight.w400}) {
    return TextStyle(
      fontFamily: fontName,
      fontWeight: fontWeight,
      fontSize: fontSize,
      letterSpacing: 0,
      color: color != null ? color : ZColors.KFFA0A0A8Theme(Get.context!),
    );
  }

  static TextStyle text10({double fontSize = 10, Color? color, FontWeight fontWeight = FontWeight.w400}) {
    return TextStyle(
      fontFamily: fontName,
      fontWeight: fontWeight,
      fontSize: fontSize,
      letterSpacing: 0,
      color: color != null ? color : ZColors.KFFA0A0A8Theme(Get.context!),
    );
  }

}
