import 'dart:typed_data';
import 'package:abey_wallet/utils/bigint_util.dart';
import 'package:abey_wallet/utils/bytes_util.dart';
import 'package:abey_wallet/utils/tuple.dart';
import 'package:abey_wallet/vender/crypto/cdsa/curve/curve.dart';
import 'package:abey_wallet/vender/crypto/cdsa/point/edwards.dart';
import 'package:abey_wallet/vender/crypto/cdsa/utils/utils.dart';

enum EncodeType { comprossed, hybrid, raw, uncompressed }

abstract class AbstractPoint {
  List<int> toBytes([EncodeType encodeType = EncodeType.comprossed]) {
    if (this is EDPoint) {
      return _edwardsEncode();
    }
    switch (encodeType) {
      case EncodeType.raw:
        return _encode();
      case EncodeType.uncompressed:
        return List<int>.from([0x04, ..._encode()]);
      case EncodeType.hybrid:
        return _hybridEncode();
      default:
        return _compressedEncode();
    }
  }

  String toHex([EncodeType encodeType = EncodeType.comprossed]) {
    final bytes = toBytes(encodeType);
    return BytesUtil.toHexString(bytes);
  }

  List<int> _edwardsEncode() {
    final ed = this as EDPoint;
    ed.scale();
    final encLen = (curve.p.bitLength + 1 + 7) ~/ 8;
    final yStr = BigintUtil.toBytes(y, length: encLen, order: Endian.little);
    if (x % BigInt.two == BigInt.one) {
      yStr[yStr.length - 1] |= 0x80;
    }
    return yStr;
  }

  List<int> _hybridEncode() {
    final raw = _encode();
    List<int> prefix;
    if (y.isOdd) {
      prefix = List<int>.from([0x07]);
    } else {
      prefix = List<int>.from([0x06]);
    }
    List<int> result = List<int>.filled(prefix.length + raw.length, 0);
    result.setAll(0, prefix);
    result.setAll(prefix.length, raw);
    return result;
  }

  List<int> _compressedEncode() {
    List<int> xStr = BigintUtil.toBytes(x, length: BigintUtil.orderLen(curve.p));
    List<int> prefix;
    if (y & BigInt.one != BigInt.zero) {
      prefix = List<int>.from([0x03]);
    } else {
      prefix = List<int>.from([0x02]);
    }
    List<int> result = List<int>.filled(prefix.length + xStr.length, 0);
    result.setAll(0, prefix);
    result.setAll(prefix.length, xStr);
    return result;
  }

  List<int> _encode() {
    final xBytes = BigintUtil.toBytes(x, length: BigintUtil.orderLen(curve.p));
    final yBytes = BigintUtil.toBytes(y, length: BigintUtil.orderLen(curve.p));
    return List<int>.from([...xBytes, ...yBytes]);
  }

  abstract final Curve curve;
  bool get isInfinity;
  BigInt get x;
  BigInt get y;
  BigInt? get order;
  AbstractPoint operator *(BigInt other);
  AbstractPoint operator +(AbstractPoint other);
  AbstractPoint doublePoint();

  static Tuple<BigInt, BigInt> fromBytes(
    Curve curve,
    List<int> data, {
    bool validateEncoding = true,
    EncodeType? encodeType,
  }) {
    if (curve is CurveED) {
      return _fromEdwards(curve, data);
    }
    final keyLen = data.length;
    final rawEncodingLength = 2 * BigintUtil.orderLen(curve.p);
    if (encodeType == null) {
      if (keyLen == rawEncodingLength) {
        encodeType = EncodeType.raw;
      } else if (keyLen == rawEncodingLength + 1) {
        final prefix = data[0];
        if (prefix == 0x04) {
          encodeType = EncodeType.uncompressed;
        } else if (prefix == 0x06 || prefix == 0x07) {
          encodeType = EncodeType.hybrid;
        } else {
          throw Exception("invalid key length");
        }
      } else if (keyLen == rawEncodingLength ~/ 2 + 1) {
        encodeType = EncodeType.comprossed;
      } else {
        throw Exception("invalid key length");
      }
    }
    curve as CurveFp;
    switch (encodeType) {
      case EncodeType.comprossed:
        return _fromCompressed(data, curve);
      case EncodeType.uncompressed:
        return _fromRawEncoding(data.sublist(1), rawEncodingLength);
      case EncodeType.hybrid:
        return _fromHybrid(data, rawEncodingLength);
      default:
        return _fromRawEncoding(data, rawEncodingLength);
    }
  }

  static Tuple<BigInt, BigInt> _fromEdwards(CurveED curve, List<int> data) {
    data = List<int>.from(data);
    final p = curve.p;
    final expLen = (p.bitLength + 1 + 7) ~/ 8;
    if (data.length != expLen) {
      throw Exception("AffinePointt length doesn't match the curve.");
    }
    final x0 = (data[expLen - 1] & 0x80) >> 7;
    data[expLen - 1] &= 0x80 - 1;
    final y = BigintUtil.fromBytes(data, byteOrder: Endian.little);
    final x2 = (y * y - BigInt.from(1)) * BigintUtil.inverseMod(curve.d * y * y - curve.a, p,) % p;
    BigInt x = ECDSAUtils.modularSquareRootPrime(x2, p);
    if (x.isOdd != (x0 == 1)) {
      x = (-x) % p;
    }
    return Tuple(x, y);
  }

  static Tuple<BigInt, BigInt> _fromRawEncoding(List<int> data, int rawEncodingLength) {
    assert(data.length == rawEncodingLength);
    final xs = data.sublist(0, rawEncodingLength ~/ 2);
    final ys = data.sublist(rawEncodingLength ~/ 2);
    assert(xs.length == rawEncodingLength ~/ 2);
    assert(ys.length == rawEncodingLength ~/ 2);
    final coordX = BigintUtil.fromBytes(xs);
    final coordY = BigintUtil.fromBytes(ys);
    return Tuple(coordX, coordY);
  }

  static Tuple<BigInt, BigInt> _fromCompressed(List<int> data, CurveFp curve) {
    if (data[0] != 0x02 && data[0] != 0x03) {
      throw Exception('Malformed compressed point encoding');
    }
    final isEven = data[0] == 0x02;
    final x = BigintUtil.fromBytes(data.sublist(1));
    final p = curve.p;
    final alpha = (x.modPow(BigInt.from(3), p) + curve.a * x + curve.b) % p;
    final beta = ECDSAUtils.modularSquareRootPrime(alpha, p);
    final betaEven = (beta & BigInt.one == BigInt.zero) ? false : true;
    if (isEven == betaEven) {
      final y = p - beta;
      return Tuple(x, y);
    } else {
      return Tuple(x, beta);
    }
  }

  static Tuple<BigInt, BigInt> _fromHybrid(List<int> data, int rawEncodingLength) {
    assert(data[0] == 0x06 || data[0] == 0x07);
    final result = _fromRawEncoding(data.sublist(1), rawEncodingLength);
    final x = result.item1;
    final y = result.item2;
    final prefix = y & BigInt.one;
    if (((prefix == BigInt.one && data[0] != 0x07) || (prefix == BigInt.zero && data[0] != 0x06))) {
      throw Exception('Inconsistent hybrid point encoding');
    }
    return Tuple(x, y);
  }

  @override
  String toString() {
    return "($x, $y)";
  }
}
