import 'dart:ui';

import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/utils/console_util.dart';

extension StringExtension on String {
  isEmptyString() {
    if (this == null || this.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  isNotEmptyString() {
    return !this.isEmptyString();
  }

  toColor() {
    try {
      if(this.indexOf("0x")>=0){
        return Color(int.parse(this));
      }
    } catch (e) {
      return ZColors.ZFFFFFFFF;
    }

    var hexColor = this.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }

  toDescAddress(address){
    return '${this.toUpperCase()}:$address';
  }

  toInt({defaultValue:0}) {
    try {
      return int.parse(this);
    } catch (e) {
      return defaultValue;
    }
  }

  toDouble({defaultValue:0.0}) {
    try {
      return double.parse(this);
    } catch (e) {
      return defaultValue;
    }
  }

  double hexToDouble() {
    return '${this.hexToInt()}'.toDouble();
  }

  int hexToInt() {
    if(!this.startsWith("0x")){
      return this.toInt();
    }
    try {
      String temp = this.substring(2,);
      var result = int.parse(temp,radix: 16);
      ConsoleUtil.i(result);
      return result;
    } catch (e) {

    }
    return 0;
  }

  String urlAppendParams(String key,String value){
    if(key.isNotEmptyString()){
      return this;
    }
    String params = '$key=${Uri.encodeComponent(value)}';
    if (this.indexOf('?') >= 0) {
      if (this.indexOf('&') >= 0) {
        return '$this&$params';
      } else {
        return '${this}$params';
      }
    } else {
      return '$this?$params';
    }
  }

}