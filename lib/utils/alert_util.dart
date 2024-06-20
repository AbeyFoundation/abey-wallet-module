import 'package:abey_wallet/widget/dialog/loading_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlertUtil {
  static LoadingDialogWidget? _dialogLoading;

  static void showSnackBar(String message, {String? title, Duration? duration}) {
    if (duration == null) {
      duration = Duration(seconds: 1);
    }
    Get.showSnackbar(GetBar(
        title: title,
        message: message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue,
        duration: duration),
    );
  }

  static void showTipsBar(String message, {String? title, Duration? duration,Color? backgroundColor}) {
    if (duration == null) {
      duration = Duration(seconds: 1);
    }
    Get.showSnackbar(GetBar(
        title: title,
        message: message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: backgroundColor??Colors.blue,
        duration: duration),
    );
  }

  static void showWarnBar(String message, {String? title, Duration? duration,SnackPosition snackPosition=SnackPosition.TOP}) {
    if (duration == null) {
      duration = Duration(seconds: 1);
    }
    Get.showSnackbar(GetBar(
        title: title,
        message: message,
        snackPosition: snackPosition,
        backgroundColor: Colors.red,
        duration: duration),
    );
  }

  static void showLoadingDialog(BuildContext context,{show:true}) async {
    if(!show){
      if(_dialogLoading!=null){
        Get.back();
        _dialogLoading=null;
      }else{

      }
      return Future.value(true);
    }
    if(_dialogLoading!=null){
      return Future.value(true);
    }
    _dialogLoading = LoadingDialogWidget();

    return await showDialog(
        barrierDismissible:false,
        useSafeArea:false,
        context: context,
        builder: (context) {
          return _dialogLoading!;
        });
  }
}