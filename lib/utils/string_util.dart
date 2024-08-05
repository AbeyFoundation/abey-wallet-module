import 'dart:convert';

import 'package:abey_wallet/utils/bytes_util.dart';

enum StringEncoding {
  ascii,
  utf8,
  base64,
  base64UrlSafe
}

class StringUtil {
  static final RegExp _hexBytesRegex = RegExp(r'^(0x|0X)?([0-9A-Fa-f]{2})+$');
  static final RegExp _hexaDecimalRegex = RegExp(r'^(0x|0X)?[0-9A-Fa-f]+$');
  static bool isHexBytes(String v) {
    return _hexBytesRegex.hasMatch(v);
  }

  static bool ixHexaDecimalNumber(String v) {
    return _hexaDecimalRegex.hasMatch(v);
  }

  static List<int> toBytes(String v) {
    if (isHexBytes(v)) {
      return BytesUtil.fromHexString(v);
    } else {
      return encode(v);
    }
  }

  static List<int>? tryToBytes(String? v) {
    if (v == null) return null;
    try {
      if (isHexBytes(v)) {
        return BytesUtil.fromHexString(v);
      } else {
        return encode(v);
      }
    } catch (e) {
      return null;
    }
  }

  static String strip0x(String value) {
    if (value.toLowerCase().startsWith("0x")) {
      return value.substring(2);
    }
    return value;
  }

  static List<int> encode(String value, {StringEncoding type = StringEncoding.utf8}) {
    switch (type) {
      case StringEncoding.utf8:
        return utf8.encode(value);
      case StringEncoding.base64:
      case StringEncoding.base64UrlSafe:
        return base64Decode(value);
      default:
        return ascii.encode(value);
    }
  }

  static List<int>? tryEncode(String? value, {StringEncoding type = StringEncoding.utf8}) {
    if (value == null) return null;
    try {
      return encode(value, type: type);
    } catch (e) {
      return null;
    }
  }

  static String decode(List<int> value, {StringEncoding type = StringEncoding.utf8, bool allowInvalidOrMalformed = false}) {
    switch (type) {
      case StringEncoding.utf8:
        return utf8.decode(value, allowMalformed: allowInvalidOrMalformed);
      case StringEncoding.base64:
        return base64Encode(value);
      case StringEncoding.base64UrlSafe:
        return base64UrlEncode(value);
      default:
        return ascii.decode(value, allowInvalid: allowInvalidOrMalformed);
    }
  }

  static String? tryDecode(List<int>? value, {StringEncoding type = StringEncoding.utf8, bool allowInvalidOrMalformed = false}) {
    if (value == null) return null;
    try {
      return decode(value, type: type, allowInvalidOrMalformed: allowInvalidOrMalformed);
    } catch (e) {
      return null;
    }
  }

  static String fromJson(Object data) {
    return jsonEncode(data);
  }

  static T toJson<T>(String data) {
    final decode = jsonDecode(data);
    if (decode is! T) {
      throw Exception("Invalid json casting. excepted: $T got: ${decode.runtimeType}");
    }
    return jsonDecode(data);
  }

  static String? tryFromJson(Object? data) {
    try {
      return fromJson(data!);
    } catch (e) {
      return null;
    }
  }

  static T? tryToJson<T>(String data) {
    try {
      return toJson(data);
    } catch (e) {
      return null;
    }
  }
}
