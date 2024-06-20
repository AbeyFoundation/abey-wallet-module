import 'dart:convert';

import 'package:abey_wallet/common/callback.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/utils/localauth_util.dart';
import 'package:abey_wallet/utils/preferences_util.dart';
import 'package:abey_wallet/widget/dialog/password_dialog_widget.dart';
import 'package:encrypt/encrypt.dart' as ENC;
import 'package:flutter/material.dart';
import 'package:abey_wallet/extension/string_extension.dart';

class PasswordUtil {
  static handlePassword(BuildContext context,PasswordCallback callbacks) async {
    String str = PreferencesUtil.getString(Constant.WalletLocalAuth);
    if (str.isNotEmptyString() && str == "true") {
      bool isSupport = await LocalauthUtil().isSupportBiometrics();
      if (isSupport) {
        bool isSuccess = await LocalauthUtil().authenticate();
        if (isSuccess) {
          final key = ENC.Key.fromUtf8('asdfghjklqwertyuiopzxcvbnm123456');
          final encrypter = ENC.Encrypter(ENC.AES(key));
          String str = PreferencesUtil.getString(Constant.WalletLocalAuthPwd);
          final iv = ENC.IV.fromLength(16);
          final decrypted = encrypter.decrypt(ENC.Encrypted.fromBase64(str),iv: iv);
          if (decrypted.isNotEmptyString()) {
            await callbacks(decrypted, false);
            return;
          }
        }
      }
    }

    await showDialog(
        useSafeArea:false,
        context: context, builder: (context){
      return PasswordDialogWidget(callback: (text) async{
        await callbacks(text, true);
      },);
    });
  }
}