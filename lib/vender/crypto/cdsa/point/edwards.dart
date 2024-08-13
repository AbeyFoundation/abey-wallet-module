import 'package:abey_wallet/utils/bigint_util.dart';
import 'package:abey_wallet/vender/crypto/cdsa/curve/curve.dart';
import 'base.dart';

class EDPoint extends AbstractPoint {
  @override
  CurveED curve;
  @override
  BigInt? order;
  bool generator;
  List<List<BigInt>> _precompute;
  List<BigInt> _coords;

  factory EDPoint.infinity({required CurveED curve}) {
    return EDPoint._(curve, [BigInt.zero, BigInt.zero, BigInt.zero]);
  }

  EDPoint._(this.curve, this._coords, {this.order}): _precompute = const [], generator = false;

  EDPoint(
      {required this.curve,
      required BigInt x,
      required BigInt y,
      required BigInt z,
      required BigInt t,
      this.order,
      this.generator = false})
      : _coords = [x, y, z, t],
        _precompute = const [];

  factory EDPoint.fromBytes({required CurveED curve, required List<int> data, BigInt? order}) {
    final coords = AbstractPoint.fromBytes(curve, data);
    final x = coords.item1;
    final y = coords.item2;
    final t = x * y;
    return EDPoint(
        curve: curve,
        x: x,
        y: y,
        z: BigInt.one,
        t: t,
        generator: false,
        order: order);
  }

  void _maybePrecompute() {
    if (!generator || _precompute.isNotEmpty) {
      return;
    }
    BigInt newOrder = order!;
    List<List<BigInt>> compute = [];
    BigInt i = BigInt.one;
    newOrder *= BigInt.from(2);
    List<BigInt> coordsList = getCoords();
    EDPoint doubler = EDPoint._(
      curve,
      getCoords(),
      order: newOrder,
    );

    newOrder *= BigInt.from(4);
    while (i < newOrder) {
      doubler = doubler.scale();
      coordsList[0] = doubler._coords[0];
      coordsList[1] = doubler._coords[1];
      coordsList[3] = doubler._coords[3];
      i *= BigInt.two;
      doubler = doubler.doublePoint();
      compute.add([coordsList[0], coordsList[1], coordsList[3]]);
    }
    _precompute = compute;
  }

  List<BigInt> getCoords() {
    return List.from(_coords);
  }

  @override
  BigInt get x {
    BigInt x1 = _coords[0];
    BigInt z1 = _coords[2];
    if (z1 == BigInt.one) {
      return x1;
    }
    BigInt p = curve.p;
    BigInt zInv = BigintUtil.inverseMod(z1, p);
    return (x1 * zInv) % p;
  }

  @override
  BigInt get y {
    BigInt y1 = _coords[1];
    BigInt z1 = _coords[2];
    if (z1 == BigInt.one) {
      return y1;
    }
    BigInt p = curve.p;
    BigInt zInv = BigintUtil.inverseMod(z1, p);
    return (y1 * zInv) % p;
  }

  EDPoint scale() {
    BigInt z1 = _coords[2];
    if (z1 == BigInt.one) {
      return this;
    }
    BigInt x1 = _coords[0];
    BigInt y1 = _coords[1];
    BigInt p = curve.p;
    BigInt zInv = BigintUtil.inverseMod(z1, p);
    BigInt x = (x1 * zInv) % p;
    BigInt y = (y1 * zInv) % p;
    BigInt t = (x * y) % p;
    _coords[0] = x;
    _coords[1] = y;
    _coords[2] = BigInt.one;
    _coords[3] = t;

    return this;
  }

  @override
  bool operator ==(Object other) {
    if (other is EDPoint) {
      List<BigInt> otherCoords = other.getCoords();
      BigInt x1 = _coords[0];
      BigInt y1 = _coords[1];
      BigInt z1 = _coords[2];
      BigInt t1 = _coords[3];
      BigInt x2 = otherCoords[0];
      BigInt y2 = otherCoords[1];
      BigInt z2 = otherCoords[2];
      if (other.isInfinity) {
        return x1 == BigInt.zero || t1 == BigInt.zero;
      }
      if (curve != other.curve) {
        return false;
      }
      BigInt p = curve.p;
      BigInt xn1 = (x1 * z2) % p;
      BigInt xn2 = (x2 * z1) % p;
      BigInt yn1 = (y1 * z2) % p;
      BigInt yn2 = (y2 * z1) % p;
      return xn1 == xn2 && yn1 == yn2;
    }

    return false;
  }

  List<BigInt> _add(
    BigInt x1,
    BigInt y1,
    BigInt z1,
    BigInt t1,
    BigInt x2,
    BigInt y2,
    BigInt z2,
    BigInt t2,
    BigInt p,
    BigInt a,
  ) {
    BigInt A = (x1 * x2) % p;
    BigInt b = (y1 * y2) % p;
    BigInt c = (z1 * t2) % p;
    BigInt d = (t1 * z2) % p;
    BigInt e = d + c;
    BigInt f = (((x1 - y1) * (x2 + y2)) + b - A) % p;
    BigInt g = b + (a * A);
    BigInt h = d - c;

    if (h == BigInt.zero) {
      return _double(x1, y1, z1, t1, p, a);
    }
    BigInt x3 = (e * f) % p;
    BigInt y3 = (g * h) % p;
    BigInt t3 = (e * h) % p;
    BigInt z3 = (f * g) % p;
    return [x3, y3, z3, t3];
  }

  @override
  EDPoint operator +(AbstractPoint other) {
    if (other is! EDPoint || curve != other.curve) {
      throw Exception("The other point is on a different curve.");
    }
    if (other.isInfinity) {
      return this;
    }
    BigInt p = curve.p;
    BigInt a = curve.a;

    BigInt x1 = _coords[0];
    BigInt y1 = _coords[1];
    BigInt z1 = _coords[2];
    BigInt t1 = _coords[3];

    BigInt x2 = other._coords[0];
    BigInt y2 = other._coords[1];
    BigInt z2 = other._coords[2];
    BigInt t2 = other._coords[3];

    List<BigInt> result = _add(x1, y1, z1, t1, x2, y2, z2, t2, p, a);
    if (result[0] == BigInt.zero || result[3] == BigInt.zero) {
      return EDPoint.infinity(curve: curve);
    }

    return EDPoint(
        curve: curve,
        x: result[0],
        y: result[1],
        z: result[2],
        t: result[3],
        order: order);
  }

  EDPoint operator -() {
    BigInt x1 = _coords[0];
    BigInt y1 = _coords[1];
    BigInt t1 = _coords[3];
    BigInt p = curve.p;

    return EDPoint._(curve, [x1, (p - y1) % p, _coords[2], (p - t1) % p], order: order);
  }

  List<BigInt> _double(BigInt x1, BigInt y1, BigInt z1, BigInt t1, BigInt p, BigInt a) {
    BigInt A = (x1 * x1) % p;
    BigInt B = (y1 * y1) % p;
    BigInt C = (z1 * z1 * BigInt.two) % p;
    BigInt D = (a * A) % p;
    BigInt E = (((x1 + y1) * (x1 + y1)) - A - B) % p;
    BigInt G = D + B;
    BigInt F = G - C;
    BigInt H = D - B;
    BigInt x3 = (E * F) % p;
    BigInt y3 = (G * H) % p;
    BigInt t3 = (E * H) % p;
    BigInt z3 = (F * G) % p;

    return [x3, y3, z3, t3];
  }

  @override
  EDPoint doublePoint() {
    BigInt x1 = _coords[0];
    BigInt t1 = _coords[3];
    BigInt p = curve.p;
    BigInt a = curve.a;
    if (x1 == BigInt.zero || t1 == BigInt.zero) {
      return EDPoint.infinity(curve: curve);
    }
    final newCoords = _double(x1, _coords[1], _coords[2], t1, p, a);
    if (newCoords[0] == BigInt.zero || newCoords[3] == BigInt.zero) {
      return EDPoint.infinity(curve: curve);
    }
    return EDPoint._(curve, newCoords, order: order);
  }

  EDPoint _mulPrecompute(BigInt other) {
    BigInt x3 = BigInt.zero, y3 = BigInt.one, z3 = BigInt.one, t3 = BigInt.zero;
    final p = curve.p;
    final a = curve.a;

    for (final tuple in _precompute) {
      final x2 = tuple[0];
      final y2 = tuple[1];
      final t2 = tuple[2];
      final rem = other % BigInt.from(4);
      if (rem == BigInt.zero || rem == BigInt.from(2)) {
        other ~/= BigInt.from(2);
      } else if (rem == BigInt.from(3)) {
        other = (other + BigInt.one) ~/ BigInt.two;
        final result = _add(x3, y3, z3, t3, -x2, y2, BigInt.one, -t2, p, a);

        x3 = result[0];
        y3 = result[1];
        z3 = result[2];
        t3 = result[3];
      } else {
        assert(rem == BigInt.one);
        other = (other - BigInt.one) ~/ BigInt.two;
        final result = _add(x3, y3, z3, t3, x2, y2, BigInt.one, t2, p, a);
        x3 = result[0];
        y3 = result[1];
        z3 = result[2];
        t3 = result[3];
      }
    }
    if (x3 == BigInt.zero || t3 == BigInt.zero) {
      return EDPoint.infinity(curve: curve);
    }
    return EDPoint(curve: curve, x: x3, y: y3, z: z3, t: t3, order: order);
  }

  @override
  EDPoint operator *(BigInt other) {
    BigInt x2 = _coords[0];
    BigInt t2 = _coords[3];
    BigInt y2 = _coords[1];
    BigInt z2 = _coords[2];

    if (x2 == BigInt.zero || t2 == BigInt.zero || other == BigInt.zero) {
      return EDPoint.infinity(curve: curve);
    }
    if (order != null) {
      other %= (order! * BigInt.two);
    }
    _maybePrecompute();
    if (_precompute.isNotEmpty) {
      return _mulPrecompute(other);
    }
    BigInt x3 = BigInt.zero;
    BigInt y3 = BigInt.one;
    BigInt z3 = BigInt.one;
    BigInt t3 = BigInt.one;
    final nf = BigintUtil.computeNAF(other).reversed.toList();
    for (BigInt i in nf) {
      List<BigInt> resultCoords = _double(x3, y3, z3, t3, curve.p, curve.a);
      x3 = resultCoords[0];
      y3 = resultCoords[1];
      z3 = resultCoords[2];
      t3 = resultCoords[3];
      if (i < BigInt.zero) {
        List<BigInt> doubleCoords = _add(x3, y3, z3, t3, -x2, y2, z2, -t2, curve.p, curve.a);
        x3 = doubleCoords[0];
        y3 = doubleCoords[1];
        z3 = doubleCoords[2];
        t3 = doubleCoords[3];
      } else if (i > BigInt.zero) {
        List<BigInt> doubleCoords = _add(x3, y3, z3, t3, x2, y2, z2, t2, curve.p, curve.a);
        x3 = doubleCoords[0];
        y3 = doubleCoords[1];
        z3 = doubleCoords[2];
        t3 = doubleCoords[3];
      }
    }
    if (x3 == BigInt.zero || t3 == BigInt.zero) {
      return EDPoint.infinity(curve: curve);
    }
    return EDPoint._(curve, [x3, y3, z3, t3], order: order);
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ order.hashCode;

  @override
  bool get isInfinity => _coords.isEmpty || (_coords[0] == BigInt.zero && _coords[1] == BigInt.zero);
}
