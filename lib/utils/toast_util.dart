import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class ToastUtil {
  static show(String msgStr) {
    Fluttertoast.showToast(
        msg: msgStr,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Color(0xff4b4b4b),
        textColor: Color(0xffffffff),
        fontSize: 13
    );
  }

  static showLoad(String msgStr) {
    Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(msgStr)
          ],
        ),
      ),
    );
  }
}