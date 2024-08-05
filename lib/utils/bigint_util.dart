import 'dart:typed_data';

import 'package:abey_wallet/utils/binary_util.dart';
import 'package:abey_wallet/utils/bytes_util.dart';
import 'package:abey_wallet/utils/int_util.dart';
import 'package:abey_wallet/utils/string_util.dart';
import 'package:abey_wallet/utils/tuple.dart';

class BigintUtil {
  static List<int> bigintToBytesWithPadding(BigInt x, BigInt order) {
    String hexStr = x.toRadixString(16);
    int hexLen = hexStr.length;
    int byteLen = (order.bitLength + 7) ~/ 8;

    if (hexLen < byteLen * 2) {
      hexStr = '0' * (byteLen * 2 - hexLen) + hexStr;
    }
    return BytesUtil.fromHexString(hexStr);
  }

  static int bitlengthInBytes(BigInt value) {
    return (value.abs().bitLength + 7) ~/ 8;
  }

  static BigInt bitsToBigIntWithLengthLimit(List<int> data, int qlen) {
    BigInt x = BigInt.parse(BytesUtil.toHexString(data), radix: 16);
    int l = data.length * 8;
    if (l > qlen) {
      return (x >> (l - qlen));
    }
    return x;
  }

  static List<int> bitsToOctetsWithOrderPadding(List<int> data, BigInt order) {
    BigInt z1 = bitsToBigIntWithLengthLimit(data, order.bitLength);
    BigInt z2 = z1 - order;
    if (z2 < BigInt.zero) {
      z2 = z1;
    }
    final bytes = bigintToBytesWithPadding(z2, order);
    return bytes;
  }

  static int orderLen(BigInt value) {
    String hexOrder = value.toRadixString(16);
    int byteLength = (hexOrder.length + 1) ~/ 2;
    return byteLength;
  }

  static BigInt inverseMod(BigInt a, BigInt m) {
    if (a == BigInt.zero) {
      return BigInt.zero;
    }
    if (a >= BigInt.one && a < m) {
      return a.modInverse(m);
    }

    BigInt lm = BigInt.one, hm = BigInt.zero;
    BigInt low = a % m, high = m;

    while (low > BigInt.one) {
      BigInt r = high ~/ low;
      BigInt nm = hm - lm * r;
      BigInt newLow = high - low * r;
      hm = lm;
      high = low;
      lm = nm;
      low = newLow;
    }
    return lm % m;
  }

  static List<BigInt> computeNAF(BigInt mult) {
    List<BigInt> nafList = [];

    while (mult != BigInt.zero) {
      if (mult.isOdd) {
        BigInt nafDigit = mult % BigInt.from(4);
        if (nafDigit >= BigInt.two) {
          nafDigit -= BigInt.from(4);
        }
        nafList.add(nafDigit);
        mult -= nafDigit;
      } else {
        nafList.add(BigInt.zero);
      }
      mult ~/= BigInt.two;
    }
    return nafList;
  }

  static String toBinary(BigInt value, int zeroPadBitLen) {
    String binaryStr = value.toRadixString(2);
    if (zeroPadBitLen > 0) {
      return binaryStr.padLeft(zeroPadBitLen, '0');
    } else {
      return binaryStr;
    }
  }

  static Tuple<BigInt, BigInt> divmod(BigInt value, int radix) {
    final div = value ~/ BigInt.from(radix);
    final mod = value % BigInt.from(radix);
    return Tuple(div, mod);
  }

  static List<int> toBytes(BigInt val, {required int length, Endian order = Endian.big}) {
    if (val == BigInt.zero) {
      return List.filled(length, 0);
    }
    BigInt bigMaskEight = BigInt.from(0xff);
    List<int> byteList = List<int>.filled(length, 0);
    for (var i = 0; i < length; i++) {
      byteList[length - i - 1] = (val & bigMaskEight).toInt();
      val = val >> 8;
    }
    if (order == Endian.little) {
      byteList = byteList.reversed.toList();
    }
    return List<int>.from(byteList);
  }

  static BigInt fromBytes(List<int> bytes, {Endian byteOrder = Endian.big, bool sign = false}) {
    if (byteOrder == Endian.little) {
      bytes = List<int>.from(bytes.reversed.toList());
    }
    BigInt result = BigInt.zero;
    for (int i = 0; i < bytes.length; i++) {
      result += BigInt.from(bytes[bytes.length - i - 1]) << (8 * i);
    }
    if (result == BigInt.zero) return BigInt.zero;
    if (sign && (bytes[0] & 0x80) != 0) {
      final bitLength = bitlengthInBytes(result) * 8;
      return result.toSigned(bitLength);
    }
    return result;
  }

  static List<int> toDer(List<BigInt> bigIntList) {
    List<List<int>> encodedIntegers = bigIntList.map((bi) {
      List<int> bytes = _encodeInteger(bi);
      return bytes;
    }).toList();
    List<int> lengthBytes = _encodeLength(encodedIntegers.fold<int>(0, (sum, e) => sum + e.length));
    List<int> contentBytes = encodedIntegers.fold<List<int>>([], (prev, e) => [...prev, ...e]);
    _encodeLength(200);
    var derBytes = [
      0x30, ...lengthBytes,
      ...contentBytes,
    ];
    return derBytes;
  }

  static List<int> _encodeLength(int length) {
    if (length < 128) {
      return [length];
    } else {
      final encodeLen = IntUtil.toBytes(length, length: IntUtil.bitlengthInBytes(length), byteOrder: Endian.little);
      return [0x80 | encodeLen.length, ...encodeLen];
    }
  }

  static List<int> _encodeInteger(BigInt r) {
    assert(r >= BigInt.zero);

    List<int> s = BigintUtil.toBytes(r, length: BigintUtil.orderLen(r));

    int num = s[0];
    if (num <= 0x7F) {
      return [0x02, ..._encodeLength(s.length), ...s];
    } else {
      return [0x02, ..._encodeLength(s.length + 1), 0x00, ...s];
    }
  }

  static BigInt parse(dynamic v) {
    try {
      if (v is BigInt) return v;
      if (v is int) return BigInt.from(v);
      if (v is List<int>) {
        return fromBytes(v, sign: true);
      }
      if (v is String) {
        BigInt? parse = BigInt.tryParse(v);
        if (parse == null && StringUtil.ixHexaDecimalNumber(v)) {
          parse = BigInt.parse(StringUtil.strip0x(v), radix: 16);
        }
        return parse!;
      }
    } catch (e) {}
    throw Exception("invalid input for parse bigint");
  }

  static BigInt? tryParse(dynamic v) {
    try {
      return parse(v);
    } on Exception {
      return null;
    }
  }

  static List<int> variableNatEncode(BigInt val) {
    BigInt num = val & maskBig32;
    List<int> output = [(num & maskBig8).toInt() & 0x7F];
    num ~/= BigInt.from(128);
    while (num > BigInt.zero) {
      output.add(((num & maskBig8).toInt() & 0x7F) | 0x80);
      num ~/= BigInt.from(128);
    }
    output = output.reversed.toList();
    return output;
  }

  static Tuple<BigInt, int> variableNatDecode(List<int> bytes) {
    BigInt output = BigInt.zero;
    int bytesRead = 0;
    for (int byte in bytes) {
      output = (output << 7) | BigInt.from(byte & 0x7F);
      if (output > maxU64) {
        throw Exception("The variable size exceeds the limit for Nat Decode");
      }
      bytesRead++;
      if ((byte & 0x80) == 0) {
        return Tuple(output, bytesRead);
      }
    }
    throw Exception("Nat Decode failed.");
  }
}
