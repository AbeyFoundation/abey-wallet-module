import 'dart:typed_data';

import 'package:abey_wallet/utils/bigint_util.dart';
import 'package:abey_wallet/utils/binary_util.dart';
import 'package:abey_wallet/utils/string_util.dart';
import 'package:abey_wallet/utils/tuple.dart';

class IntUtil {
  static Tuple<int, int> decodeVarint(List<int> byteint) {
    int ni = byteint[0];
    int size = 0;

    if (ni < 253) {
      return Tuple(ni, 1);
    }

    if (ni == 253) {
      size = 2;
    } else if (ni == 254) {
      size = 4;
    } else {
      size = 8;
    }

    BigInt value = BigintUtil.fromBytes(byteint.sublist(1, 1 + size),
        byteOrder: Endian.little);
    if (!value.isValidInt) {
      throw Exception("cannot read variable-length in this environment");
    }
    return Tuple(value.toInt(), size + 1);
  }

  static List<int> encodeVarint(int i) {
    if (i < 253) {
      return [i];
    } else if (i < 0x10000) {
      final bytes = List<int>.filled(3, 0);
      bytes[0] = 0xfd;
      writeUint16LE(i, bytes, 1);
      return bytes;
    } else if (i < 0x100000000) {
      final bytes = List<int>.filled(5, 0);
      bytes[0] = 0xfe;
      writeUint32LE(i, bytes, 1);
      return bytes;
    } else {
      throw Exception("Integer is too large: $i");
    }
  }

  static List<int> prependVarint(List<int> data) {
    final varintBytes = encodeVarint(data.length);
    return [...varintBytes, ...data];
  }

  static int bitlengthInBytes(int val) {
    int bitlength = val.bitLength;
    if (bitlength == 0) return 1;
    if (val.isNegative) {
      bitlength += 1;
    }
    return (bitlength + 7) ~/ 8;
  }

  static List<int> toBytes(int val,
      {required int length,
      Endian byteOrder = Endian.big,
      int maxBytesLength = 6}) {
    assert(maxBytesLength > 0 && maxBytesLength <= 8);
    assert(length <= maxBytesLength);
    if (length > 4) {
      int lowerPart = val & mask32;
      int upperPart = (val >> 32) & mask32;

      final bytes = [
        ...toBytes(upperPart, length: length - 4),
        ...toBytes(lowerPart, length: 4),
      ];
      if (byteOrder == Endian.little) {
        return bytes.reversed.toList();
      }
      return bytes;
    }
    List<int> byteList = List<int>.filled(length, 0);

    for (var i = 0; i < length; i++) {
      byteList[length - i - 1] = val & mask8;
      val = val >> 8;
    }

    if (byteOrder == Endian.little) {
      return byteList.reversed.toList();
    }

    return byteList;
  }

  static int fromBytes(List<int> bytes, {Endian byteOrder = Endian.big, bool sign = false, int maxBytes = 6}) {
    assert(maxBytes > 0 && maxBytes <= 8);
    assert(bytes.length <= maxBytes);
    if (byteOrder == Endian.little) {
      bytes = List<int>.from(bytes.reversed.toList());
    }
    int result = 0;
    if (bytes.length > 4) {
      int lowerPart = fromBytes(bytes.sublist(bytes.length - 4, bytes.length));
      int upperPart = fromBytes(bytes.sublist(0, bytes.length - 4));
      result = (upperPart << 32) | lowerPart;
    } else {
      for (var i = 0; i < bytes.length; i++) {
        result |= (bytes[bytes.length - i - 1] << (8 * i));
      }
    }

    if (sign && (bytes[0] & 0x80) != 0) {
      return result.toSigned(bitlengthInBytes(result) * 8);
    }

    return result;
  }

  static int parse(dynamic v) {
    try {
      if (v is int) return v;
      if (v is BigInt) return v.toInt();
      if (v is List<int>) {
        return fromBytes(v, sign: true);
      }
      if (v is String) {
        int? parse = int.tryParse(v);
        if (parse == null && StringUtil.ixHexaDecimalNumber(v)) {
          parse = int.parse(StringUtil.strip0x(v), radix: 16);
        }
        return parse!;
      }
      // ignore: empty_catches
    } catch (e) {}
    throw Exception("invalid input for parse int");
  }

  static int? tryParse(dynamic v) {
    if (v == null) return null;
    try {
      return parse(v);
    } on Exception {
      return null;
    }
  }
}
