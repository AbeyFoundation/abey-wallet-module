import 'package:abey_wallet/utils/bigint_util.dart';

class CurveFp extends Curve {
  CurveFp({required this.p, required this.a, required this.b, required this.h});

  @override
  final BigInt p;
  @override
  final BigInt a;
  final BigInt b;

  final BigInt? h;

  BigInt? cofactor() => h;

  bool containsPoint(BigInt x, BigInt y) {
    BigInt leftSide = (y * y - ((x * x + a) * x + b)) % p;
    return leftSide == BigInt.zero;
  }

  @override
  operator ==(other) {
    if (other is CurveFp) {
      return (p == other.p && a == other.a && b == other.b && h == other.h);
    }
    return false;
  }

  @override
  int get hashCode => p.hashCode ^ a.hashCode ^ b.hashCode ^ h.hashCode;

  @override
  int get baselen => BigintUtil.orderLen(p);

  @override
  int get verifyingKeyLength => throw UnimplementedError();
}

class CurveED extends Curve {
  CurveED(
      {required this.p,
      required this.a,
      required this.d,
      required this.h,
      required BigInt order});

  @override
  final BigInt p;
  @override
  final BigInt a;
  final BigInt d;
  final BigInt h;

  BigInt cofactor() => h;

  bool containsPoint(BigInt x, BigInt y) {
    BigInt leftSide = (a * x * x + y * y - BigInt.one - d * x * x * y * y) % p;
    return leftSide == BigInt.zero;
  }

  @override
  operator ==(other) {
    if (other is CurveED) {
      return (p == other.p && a == other.a && d == other.d && h == other.h);
    }
    return false;
  }

  @override
  int get hashCode => p.hashCode ^ d.hashCode ^ h.hashCode ^ a.hashCode;

  @override
  int get baselen => ((p.bitLength + 1 + 7) ~/ 8);

  @override
  int get verifyingKeyLength => baselen;
}

abstract class Curve {
  BigInt get p;
  BigInt get a;
  int get baselen;
  int get verifyingKeyLength;
}
