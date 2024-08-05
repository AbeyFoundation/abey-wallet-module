import 'package:abey_wallet/utils/bigint_util.dart';
import 'package:abey_wallet/utils/binary_util.dart';
import 'package:abey_wallet/utils/hex_util.dart';
import 'package:abey_wallet/utils/string_util.dart';

class BytesUtil {
  static List<int> xor(List<int> dataBytes1, List<int> dataBytes2) {
    return List<int>.from(List<int>.generate(
      dataBytes1.length,
      (index) => dataBytes1[index] ^ dataBytes2[index],
    ));
  }

  static String toBinary(List<int> dataBytes, {int zeroPadBitLen = 0}) {
    return BigintUtil.toBinary(BigintUtil.fromBytes(dataBytes), zeroPadBitLen);
  }

  static List<int> fromBinary(String data, {int zeroPadByteLen = 0}) {
    BigInt intValue = BigInt.parse(data, radix: 2);
    String hexValue = intValue.toRadixString(16).padLeft(zeroPadByteLen, '0');
    return fromHexString(hexValue);
  }

  static String toHexString(List<int> dataBytes, {bool lowerCase = true, String? prefix}) {
    final String toHex = HEX.encode(dataBytes, lowerCase: lowerCase);
    return "${prefix ?? ''}$toHex";
  }

  static String? tryToHexString(List<int>? dataBytes,
      {bool lowerCase = true, String? prefix}) {
    if (dataBytes == null) return null;
    try {
      return toHexString(dataBytes, lowerCase: lowerCase, prefix: prefix);
    } catch (e) {
      return null;
    }
  }

  static List<int> fromHexString(String data, {bool paddingZero = false}) {
    try {
      String hexString = StringUtil.strip0x(data);
      if (hexString.isEmpty) return [];
      if (paddingZero && hexString.length.isOdd) {
        hexString = "0$hexString";
      }
      return HEX.decode(hexString);
    } catch (e) {
      throw Exception("invalid hex bytes");
    }
  }

  static List<int>? tryFromHexString(String? data) {
    if (data == null) return null;
    try {
      return fromHexString(data);
    } catch (e) {
      return null;
    }
  }

  static List<int> toBytes(List<int> bytes, {bool unmodifiable = false}) {
    final toBytes = bytes.map((e) => e & mask8).toList();
    if (unmodifiable) {
      return List<int>.unmodifiable(toBytes);
    }
    return toBytes;
  }

  static List<int>? tryToBytes(List<int>? bytes, {bool unmodifiable = false}) {
    if (bytes == null) return null;
    return toBytes(bytes, unmodifiable: unmodifiable);
  }

  static void validateBytes(List<int> bytes, {String? onError}) {
    for (int i = 0; i < bytes.length; i++) {
      final int byte = bytes[i];
      if (byte < 0 || byte > mask8) {
        throw Exception("${onError ?? "Invalid bytes"} at index $i $byte");
      }
    }
  }

  static int compareBytes(List<int> a, List<int> b) {
    final length = a.length < b.length ? a.length : b.length;
    for (var i = 0; i < length; i++) {
      if (a[i] < b[i]) {
        return -1;
      } else if (a[i] > b[i]) {
        return 1;
      }
    }
    if (a.length < b.length) {
      return -1;
    } else if (a.length > b.length) {
      return 1;
    }
    return 0;
  }

  static bool bytesEqual(List<int>? a, List<int>? b) {
    if (a == null) {
      return b == null;
    }
    if (b == null || a.length != b.length) {
      return false;
    }
    if (identical(a, b)) {
      return true;
    }
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) {
        return false;
      }
    }
    return true;
  }

  static bool isLessThanBytes(List<int> thashedA, List<int> thashedB) {
    for (int i = 0; i < thashedA.length && i < thashedB.length; i++) {
      if (thashedA[i] < thashedB[i]) {
        return true;
      } else if (thashedA[i] > thashedB[i]) {
        return false;
      }
    }
    return thashedA.length < thashedB.length;
  }
}
