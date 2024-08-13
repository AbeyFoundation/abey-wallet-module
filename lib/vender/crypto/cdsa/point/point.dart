import 'package:abey_wallet/utils/bigint_util.dart';
import 'package:abey_wallet/vender/crypto/cdsa/curve/curve.dart';
import 'package:abey_wallet/vender/crypto/cdsa/point/ec_projective_point.dart';

import 'base.dart';

class AffinePointt extends AbstractPoint {
  AffinePointt(this.curve, this.x, this.y, {this.order});

  factory AffinePointt.infinity(CurveFp curve) {
    return AffinePointt(curve, BigInt.zero, BigInt.zero);
  }

  @override
  final CurveFp curve;

  @override
  final BigInt x;

  @override
  final BigInt y;

  @override
  final BigInt? order;

  @override
  bool operator ==(Object other) {
    if (other is AffinePointt) {
      return curve == other.curve && x == other.x && y == other.y;
    }
    return other == this;
  }

  @override
  bool get isInfinity => x == BigInt.zero && y == BigInt.zero;

  /// Negates this point and returns the result.
  AffinePointt operator -() {
    return AffinePointt(curve, x, curve.p - y, order: order);
  }

  @override
  AbstractPoint operator +(AbstractPoint other) {
    if (other is! AffinePointt && other is! ProjectiveECCPoint) {
      throw Exception("cannot add with ${other.runtimeType} point");
    }
    if (other is ProjectiveECCPoint) {
      return other + this;
    }
    other as AffinePointt;
    if (other.isInfinity) {
      return this;
    }
    if (isInfinity) {
      return other;
    }
    assert(curve == other.curve);
    if (x == other.x) {
      if ((y + other.y) % curve.p == BigInt.zero) {
        return AffinePointt(curve, BigInt.zero, BigInt.zero);
      } else {
        return doublePoint();
      }
    }

    BigInt p = curve.p;
    BigInt l = (other.y - y) * BigintUtil.inverseMod(other.x - x, p) % p;

    BigInt x3 = (l * l - x - other.x) % p;
    BigInt y3 = (l * (x - x3) - y) % p;

    return AffinePointt(curve, x3, y3, order: null);
  }

  @override
  AffinePointt operator *(BigInt other) {
    BigInt leftmostBit(BigInt x) {
      assert(x > BigInt.zero);
      BigInt result = BigInt.one;
      while (result <= x) {
        result = BigInt.from(2) * result;
      }
      return result ~/ BigInt.from(2);
    }

    BigInt e = other;
    if (e == BigInt.zero || (order != null && e % order! == BigInt.zero)) {
      return AffinePointt(curve, BigInt.zero, BigInt.zero);
    }

    if (e < BigInt.zero) {
      return -this * -e;
    }

    e *= BigInt.from(3);
    AffinePointt negativeSelf = AffinePointt(curve, x, -y, order: order);
    BigInt i = leftmostBit(e) ~/ BigInt.from(2);
    AffinePointt result = this;

    while (i > BigInt.one) {
      result = result.doublePoint();
      if ((e & i) != BigInt.zero && (other & i) == BigInt.zero) {
        result = (result + this) as AffinePointt;
      }
      if ((e & i) == BigInt.zero && (other & i) != BigInt.zero) {
        result = (result + negativeSelf) as AffinePointt;
      }
      i = i ~/ BigInt.from(2);
    }

    return result;
  }

  @override
  AffinePointt doublePoint() {
    if (isInfinity) {
      return AffinePointt(curve, BigInt.zero, BigInt.zero);
    }
    BigInt p = curve.p;
    BigInt a = curve.a;
    BigInt l = (BigInt.from(3) * x * x + a) * BigintUtil.inverseMod(BigInt.from(2) * y, p) % p;
    BigInt x3 = (l * l - BigInt.from(2) * x) % p;
    BigInt y3 = (l * (x - x3) - y) % p;
    return AffinePointt(curve, x3, y3, order: null);
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}
