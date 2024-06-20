import 'dart:io';
import 'package:flutter/material.dart';

class CustomBehavior extends ScrollBehavior {

  @override
  Widget buildViewportChrome(BuildContext context, Widget child, ScrollableDetails axisDirection) {
    if(Platform.isAndroid || Platform.isFuchsia) {
      return child;
    } else {
      return super.buildOverscrollIndicator(context, child, axisDirection);
    }
  }
}