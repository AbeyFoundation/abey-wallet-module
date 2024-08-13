import 'dart:typed_data';
import 'package:abey_wallet/utils/bigint_util.dart';
import 'package:abey_wallet/vender/crypto/cdsa/curve/curve.dart';
import 'package:abey_wallet/vender/crypto/cdsa/curve/curves.dart';
import 'package:abey_wallet/vender/crypto/cdsa/point/base.dart';
import 'package:abey_wallet/vender/crypto/cdsa/point/edwards.dart';
import 'package:abey_wallet/vender/crypto/cdsa/utils/ristretto_utils.dart' as ristretto_tools;

class RistrettoPoint extends EDPoint {
  RistrettoPoint._(
      {required CurveED curve,
      required BigInt x,
      required BigInt y,
      required BigInt z,
      required BigInt t,
      bool generator = false,
      BigInt? order})
      : super(
            curve: curve,
            t: t,
            x: x,
            y: y,
            z: z,
            generator: false,
            order: order);

  factory RistrettoPoint.fromEdwardsPoint(EDPoint point) {
    final coords = point.getCoords();
    return RistrettoPoint._(
        curve: point.curve,
        x: coords[0],
        y: coords[1],
        z: coords[2],
        t: coords[3],
        generator: point.generator,
        order: point.order);
  }

  factory RistrettoPoint.fromBytes(List<int> bytes, {CurveED? curveEdTw}) {
    List<int> hex = bytes;
    final c = curveEdTw ?? Curves.curveEd25519;
    final a = c.a;
    final d = c.d;
    final P = c.p;
    final s = BigintUtil.fromBytes(hex, byteOrder: Endian.little);
    if (ristretto_tools.isOdd(s, P)) {
      throw Exception("Invalid RistrettoPoint");
    }
    final s2 = ristretto_tools.positiveMod(s * s, P);
    final u1 = ristretto_tools.positiveMod(BigInt.one + a * s2, P);
    final u2 = ristretto_tools.positiveMod(BigInt.one - a * s2, P);
    final u1_2 = ristretto_tools.positiveMod(u1 * u1, P);
    final u2_2 = ristretto_tools.positiveMod(u2 * u2, P);
    final v = ristretto_tools.positiveMod(a * d * u1_2 - u2_2, P);
    final invSqrt = ristretto_tools.sqrtUV(BigInt.one, ristretto_tools.positiveMod(v * u2_2, P));
    final x2 = ristretto_tools.positiveMod(invSqrt.item2 * u2, P);
    final y2 = ristretto_tools.positiveMod(invSqrt.item2 * x2 * v, P);

    BigInt x = ristretto_tools.positiveMod((s + s) * x2, P);
    if (ristretto_tools.isOdd(x, P)) {
      x = ristretto_tools.positiveMod(-x, P);
    }

    final y = ristretto_tools.positiveMod(u1 * y2, P);
    final t = ristretto_tools.positiveMod(x * y, P);
    if (!invSqrt.item1 || ristretto_tools.isOdd(t, P) || y == BigInt.zero) {
      throw Exception("Invalid RistrettoPoint");
    }
    return RistrettoPoint.fromEdwardsPoint(EDPoint(curve: c, x: x, y: y, z: BigInt.one, t: t));
  }

  static EDPoint mapToPoint(BigInt r0) {
    final curveD = Curves.generatorED25519.curve.d;
    final primeP = Curves.curveEd25519.p;

    final rSquared = ristretto_tools.positiveMod(ristretto_tools.sqrtM1 * r0 * r0, primeP);
    final numeratorS = ristretto_tools.positiveMod((rSquared + BigInt.one) * ristretto_tools.oneMinusDSq, primeP);

    var c = BigInt.from(-1);

    final D = ristretto_tools.positiveMod((c - curveD * rSquared) * ristretto_tools.positiveMod(rSquared + curveD, primeP), primeP);

    final uvRatio = ristretto_tools.sqrtUV(numeratorS, D);

    final useSecondRoot = uvRatio.item1;
    BigInt sValue = uvRatio.item2;

    BigInt sComputed = ristretto_tools.positiveMod(sValue * r0, primeP);

    if (!ristretto_tools.isOdd(sComputed, primeP)) {
      sComputed = ristretto_tools.positiveMod(-sComputed, primeP);
    }

    if (!useSecondRoot) {
      sValue = sComputed;
    }

    if (!useSecondRoot) {
      c = rSquared;
    }

    final ntValue = ristretto_tools.positiveMod(c * (rSquared - BigInt.one) * ristretto_tools.minusOneSq - D, primeP);

    final sSquared = sValue * sValue;
    final w0 = ristretto_tools.positiveMod((sValue + sValue) * D, primeP);
    final w1 = ristretto_tools.positiveMod(ntValue * ristretto_tools.sqrtAdMinusOne, primeP);
    final w2 = ristretto_tools.positiveMod(BigInt.one - sSquared, primeP);
    final w3 = ristretto_tools.positiveMod(BigInt.one + sSquared, primeP);

    return EDPoint(
        curve: Curves.curveEd25519,
        x: ristretto_tools.positiveMod(w0 * w3, primeP),
        y: ristretto_tools.positiveMod(w2 * w1, primeP),
        z: ristretto_tools.positiveMod(w1 * w3, primeP),
        t: ristretto_tools.positiveMod(w0 * w2, primeP));
  }

  factory RistrettoPoint.fromUniform(List<int> hash) {
    final rB = BigintUtil.fromBytes(hash.sublist(0, 32), byteOrder: Endian.little) & ristretto_tools.mask255;
    final rPoint = mapToPoint(rB);

    final lB = BigintUtil.fromBytes(hash.sublist(32, 64), byteOrder: Endian.little) & ristretto_tools.mask255;
    final lPoint = mapToPoint(lB);

    final sumPoint = rPoint + lPoint;
    return RistrettoPoint.fromEdwardsPoint(sumPoint);
  }

  List<int> toEdwardBytes([EncodeType encodeType = EncodeType.comprossed]) {
    return super.toBytes(encodeType);
  }

  @override
  RistrettoPoint operator *(other) {
    final mul = super * other;
    return RistrettoPoint.fromEdwardsPoint(mul);
  }

  @override
  RistrettoPoint operator +(other) {
    final add = super + other;
    return RistrettoPoint.fromEdwardsPoint(add);
  }

  @override
  RistrettoPoint operator -() {
    final neg = -super;
    return RistrettoPoint.fromEdwardsPoint(neg);
  }

  @override
  List<int> toBytes([EncodeType encodeType = EncodeType.comprossed]) {
    final primeP = Curves.curveEd25519.p;
    final pointCoords = getCoords();
    BigInt x = pointCoords[0];
    BigInt y = pointCoords[1];
    BigInt z = pointCoords[2];
    BigInt t = pointCoords[3];

    final u1 = ristretto_tools.positiveMod(ristretto_tools.positiveMod(z + y, primeP) * ristretto_tools.positiveMod(z - y, primeP), primeP);
    final u2 = ristretto_tools.positiveMod(x * y, primeP);

    final u2Squared = ristretto_tools.positiveMod(u2 * u2, primeP);
    final invSqrt = ristretto_tools.sqrtUV(BigInt.one, ristretto_tools.positiveMod(u1 * u2Squared, primeP)).item2;
    final d1 = ristretto_tools.positiveMod(invSqrt * u1, primeP);
    final d2 = ristretto_tools.positiveMod(invSqrt * u2, primeP);
    final zInverse = ristretto_tools.positiveMod(d1 * d2 * t, primeP);
    BigInt D;
    if (ristretto_tools.isOdd(t * zInverse, primeP)) {
      final x2 = ristretto_tools.positiveMod(y * ristretto_tools.sqrtM1, primeP);
      final y2 = ristretto_tools.positiveMod(x * ristretto_tools.sqrtM1, primeP);
      x = x2;
      y = y2;
      D = ristretto_tools.positiveMod(d1 * ristretto_tools.invSqrt, primeP);
    } else {
      D = d2;
    }
    if (ristretto_tools.isOdd(x * zInverse, primeP)) {
      y = ristretto_tools.positiveMod(-y, primeP);
    }
    BigInt s = ristretto_tools.positiveMod((z - y) * D, primeP);
    if (ristretto_tools.isOdd(s, primeP)) {
      s = ristretto_tools.positiveMod(-s, primeP);
    }
    return BigintUtil.toBytes(s, order: Endian.little, length: 32);
  }
}
