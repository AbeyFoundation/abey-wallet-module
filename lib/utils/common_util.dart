import 'dart:convert';
import 'dart:math';

import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/global.dart';
import 'package:bee_encryption/bee_encryption.dart';
import 'package:abey_encryption/abey_encryption.dart';
import 'package:bee_encryption/uuid.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:abey_wallet/extension/string_extension.dart';

class CommonUtil {
  static String formatAddress(String address) {
    if (address.isEmptyString()) {
      return '';
    }
    if (address.length < 16) {
      return address;
    }
    String start = address.substring(0, 8);
    String end = address.substring(address.length - 8);
    return '$start...$end';
  }

  static String randomString({int length = 10}) {
    String alphabet = 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
    String random = "";
    for(int i = 0; i < length; i++) {
      random = random + alphabet[Random().nextInt(alphabet.length)];
    }
    return random;
  }

  static String getMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }

  static String generateUDID() {
    return getMd5(Uuid().v1());
  }

  static String generateId(){
    return getMd5(Uuid().v1() + '${DateTime.now().millisecond}');
  }

  static String getTokenId(String token) {
    return getMd5(Constant.SEED_ABC + token + Constant.SEED_ABC);
  }

  static String getChainName(String symbol) {
    switch (symbol) {
      case "ABEY":
        return "ABEY Chain";
      case "Ethereum":
        return "Ethereum";
      case "ETH":
        return "Ethereum";
      case "BNB":
        return "BNB Chain";
      case "MATIC":
        return "Polygon (Matic)";
      case "Polygon":
        return "Polygon (Matic)";
      case "TRX":
        return "Tron";
    }
    return "";
  }

  static String getKey(String authKey) {
    return getMd5(authKey + Constant.SEED_ABC + Global.DEVICE_UDID);
  }

  static Future<String> encrypt(String token, String authKey) async {
    var result = await BeeEncryption.encryptString(token, getKey(authKey));
    return result;
  }

  static Future<String> decrypt(String token, String authKey) async {
    try {
      var result = await BeeEncryption.decryptString(token, getKey(authKey));
      return result;
    } catch (e) {
      return "";
    }
  }

  static Future<String> decryptTray(String token, String authKey) async {
    try {
      var result = await BeeEncryption.ZdecryptString(token, authKey);
      return result;
    } catch (e) {
      return "";
    }
  }

  static Future<String> decryptIos(String token, String authKey) async {
    try {
      var result = await AbeyEncryption.ZdecryptIosString(token, authKey);
      return result;
    } catch (e) {
      return "";
    }
  }

  static double hexToDouble(String hex, num decimal) {
    try {
      double res = BigInt.tryParse(hex)! / BigInt.from(decimal);
      return res;
    } catch (e) {

    }
    return 0;
  }
}