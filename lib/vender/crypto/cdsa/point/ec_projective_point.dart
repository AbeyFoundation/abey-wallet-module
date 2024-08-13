import 'package:abey_wallet/utils/bigint_util.dart';
import 'package:abey_wallet/vender/crypto/cdsa/curve/curve.dart';
import 'base.dart';
import 'point.dart';

class ProjectiveECCPoint extends AbstractPoint {
  factory ProjectiveECCPoint(
      {required CurveFp curve,
      required BigInt x,
      required BigInt y,
      required BigInt z,
      BigInt? order,
      bool generator = false}) {
    final coords = [x, y, z];
    return ProjectiveECCPoint._(curve, coords,
        generator: generator, order: order);
  }

  factory ProjectiveECCPoint.infinity(CurveFp curve) {
    return ProjectiveECCPoint._(curve, [BigInt.zero, BigInt.zero, BigInt.zero], generator: false, order: null);
  }

  factory ProjectiveECCPoint.fromBytes({required CurveFp curve, required List<int> data, BigInt? order}) {
    final coords = AbstractPoint.fromBytes(curve, data);
    final x = coords.item1;
    final y = coords.item2;
    return ProjectiveECCPoint(
        curve: curve,
        x: x,
        y: y,
        z: BigInt.one,
        generator: false,
        order: order);
  }

  @override
  CurveFp curve;

  @override
  final BigInt? order;

  bool generator;

  List<List<BigInt>> _precompute;

  List<BigInt> _coords;

  List<BigInt> getCoords() => List.from(_coords);

  @override
  bool get isInfinity => _coords.isEmpty || (_coords[0] == BigInt.zero && _coords[1] == BigInt.zero);

  ProjectiveECCPoint._(this.curve, this._coords,
      {this.order,
      this.generator = false,
      List<List<BigInt>> precompute = const []})
      : _precompute = precompute;

  void _precomputeIfNeeded() {
    if (!generator || _precompute.isNotEmpty) {
      return;
    }
    assert(order != null);
    BigInt newOrder = order!;
    List<List<BigInt>> precomputedPoints = [];
    BigInt i = BigInt.one;
    newOrder *= BigInt.two;
    BigInt xCoord = _coords[0];
    BigInt yCoord = _coords[1];
    BigInt zCoord = _coords[2];
    ProjectiveECCPoint doubler = ProjectiveECCPoint._(curve, [xCoord, yCoord, zCoord], order: order);
    newOrder *= BigInt.two;
    precomputedPoints.add([doubler.x, doubler.y]);
    while (i < newOrder) {
      i *= BigInt.two;
      doubler = doubler.doublePoint().scale();
      precomputedPoints.add([doubler.x, doubler.y]);
    }
    _precompute = precomputedPoints;
  }

  ProjectiveECCPoint operator -() {
    final x = _coords[0];
    final y = _coords[1];
    final z = _coords[2];
    return ProjectiveECCPoint._(curve, [x, -y, z], order: order);
  }

  @override
  bool operator ==(other) {
    if (other is! AbstractPoint) {
      return false;
    }
    final BigInt x1 = _coords[0];
    final BigInt y1 = _coords[1];
    final BigInt z1 = _coords[2];
    final p = curve.p;
    final zz1 = (z1 * z1) % p;
    if (other is! ProjectiveECCPoint && other is! AffinePointt) {
      return false;
    }
    if (other.isInfinity) {
      return y1 == BigInt.zero || z1 == BigInt.zero;
    }
    BigInt x2;
    BigInt y2;
    BigInt z2;
    if (other is AffinePointt) {
      x2 = other.x;
      y2 = other.y;
      z2 = BigInt.one;
    } else if (other is ProjectiveECCPoint) {
      x2 = other._coords[0];
      y2 = other._coords[1];
      z2 = other._coords[2];
    } else {
      return false;
    }
    if (curve != other.curve) {
      return false;
    }
    final zz2 = (z2 * z2) % p;
    return ((x1 * zz2 - x2 * zz1) % p == BigInt.zero) && ((y1 * zz2 * z2 - y2 * zz1 * z1) % p == BigInt.zero);
  }

  @override
  BigInt get x {
    final xCoordinate = _coords[0];
    final zCoordinate = _coords[2];

    if (zCoordinate == BigInt.one) {
      return xCoordinate;
    }
    final p = curve.p;
    final zInverse = BigintUtil.inverseMod(zCoordinate, p);
    final result = (xCoordinate * zInverse * zInverse) % p;
    return result;
  }

  @override
  BigInt get y {
    final yCoordinate = _coords[1];
    final zCoordinate = _coords[2];
    final primeField = curve.p;
    if (zCoordinate == BigInt.one) {
      return yCoordinate;
    }
    final zInverse = BigintUtil.inverseMod(zCoordinate, primeField);
    final normalizedY = (yCoordinate * zInverse * zInverse * zInverse) % primeField;
    return normalizedY;
  }

  ProjectiveECCPoint scale() {
    final currentZ = _coords[2];
    if (currentZ == BigInt.one) {
      return this;
    }
    final currentY = _coords[1];
    final currentX = _coords[0];
    final primeField = curve.p;
    final zInverse = BigintUtil.inverseMod(currentZ, primeField);
    final zInverseSquared = (zInverse * zInverse) % primeField;
    final scaledX = (currentX * zInverseSquared) % primeField;
    final scaledY = (currentY * zInverseSquared * zInverse) % primeField;
    _coords = [scaledX, scaledY, BigInt.one];
    return this;
  }

  AffinePointt toAffine() {
    final y = _coords[1];
    final z = _coords[2];
    if (y == BigInt.zero || z == BigInt.zero) {
      return AffinePointt.infinity(curve);
    }
    scale();
    final x = _coords[0];
    final yAffine = y;
    return AffinePointt(curve, x, yAffine, order: order);
  }

  factory ProjectiveECCPoint.fromAffine(AbstractPoint point, {bool generator = false}) {
    if (point is! ProjectiveECCPoint && point is! AffinePointt) {
      throw Exception("invalid Affine point");
    }
    return ProjectiveECCPoint._(point.curve as CurveFp, [point.x, point.y, BigInt.one], generator: generator, order: point.order);
  }

  List<BigInt> _doubleWithZ1(BigInt x1, BigInt y1, BigInt p, BigInt a) {
    BigInt xSquared = (x1 * x1) % p;
    BigInt ySquared = (y1 * y1) % p;
    if (ySquared == BigInt.zero) {
      return [BigInt.zero, BigInt.zero, BigInt.one];
    }
    BigInt ySquaredSquared = (ySquared * ySquared) % p;
    BigInt s = (BigInt.two * ((x1 + ySquared) * (x1 + ySquared) - xSquared - ySquaredSquared)) % p;
    BigInt m = (BigInt.from(3) * xSquared + a) % p;
    BigInt t = (m * m - BigInt.from(2) * s) % p;
    BigInt yResult = (m * (s - t) - BigInt.from(8) * ySquaredSquared) % p;
    BigInt zResult = (BigInt.two * y1) % p;
    return [t, yResult, zResult];
  }

  List<BigInt> _double(BigInt x1, BigInt y1, BigInt z1, BigInt p, BigInt a) {
    if (z1 == BigInt.one) {
      return _doubleWithZ1(x1, y1, p, a);
    }
    if (y1 == BigInt.zero || z1 == BigInt.zero) {
      return [BigInt.zero, BigInt.zero, BigInt.one];
    }
    BigInt xSquared = (x1 * x1) % p;
    BigInt ySquared = (y1 * y1) % p;
    if (ySquared == BigInt.zero) {
      return [BigInt.zero, BigInt.zero, BigInt.one];
    }
    BigInt ySquaredSquared = (ySquared * ySquared) % p;
    BigInt zSquared = (z1 * z1) % p;
    BigInt s = (BigInt.two * ((x1 + ySquared) * (x1 + ySquared) - xSquared - ySquaredSquared)) % p;
    BigInt m = ((BigInt.from(3) * xSquared + a * zSquared * zSquared) % p);
    BigInt t = (m * m - BigInt.from(2) * s) % p;
    BigInt yResult = (m * (s - t) - BigInt.from(8) * ySquaredSquared) % p;
    BigInt zResult = ((y1 + z1) * (y1 + z1) - ySquared - zSquared) % p;
    return [t, yResult, zResult];
  }

  @override
  ProjectiveECCPoint doublePoint() {
    BigInt x1 = _coords[0];
    BigInt y1 = _coords[1];
    BigInt z1 = _coords[2];

    if (y1 == BigInt.zero) {
      return ProjectiveECCPoint.infinity(curve);
    }

    BigInt primeField = curve.p;
    BigInt curveA = curve.a;
    List<BigInt> result = _double(x1, y1, z1, primeField, curveA);
    if (result[1] == BigInt.zero || result[2] == BigInt.zero) {
      return ProjectiveECCPoint.infinity(curve);
    }

    return ProjectiveECCPoint(curve: curve, x: result[0], y: result[1], z: result[2], order: order);
  }

  List<BigInt> _addPointsWithZ1(BigInt x1, BigInt y1, BigInt x2, BigInt y2, BigInt p) {
    BigInt diff = x2 - x1;
    BigInt diffSquare = diff * diff;
    BigInt I = (diffSquare * BigInt.from(4)) % p;
    BigInt J = diff * I;
    BigInt scaledYDifference = (y2 - y1) * BigInt.from(2);
    if (diff == BigInt.zero && scaledYDifference == BigInt.zero) {
      return _doubleWithZ1(x1, y1, p, curve.a);
    }
    BigInt V = x1 * I;
    BigInt x3 = (scaledYDifference * scaledYDifference - J - V * BigInt.from(2)) % p;
    BigInt y3 = (scaledYDifference * (V - x3) - y1 * J * BigInt.from(2)) % p;
    BigInt z3 = diff * BigInt.from(2) % p;

    return [x3, y3, z3];
  }

  List<BigInt> _addPointsWithCommonZ(BigInt x1, BigInt y1, BigInt z1, BigInt x2, BigInt y2, BigInt p) {
    BigInt A = (x2 - x1).modPow(BigInt.from(2), p);
    BigInt B = (x1 * A) % p;
    BigInt C = x2 * A;
    BigInt D = (y2 - y1).modPow(BigInt.from(2), p);
    if (A == BigInt.zero && D == BigInt.zero) {
      return _double(x1, y1, z1, p, curve.a);
    }
    BigInt x3 = (D - B - C) % p;
    BigInt y3 = ((y2 - y1) * (B - x3) - y1 * (C - B)) % p;
    BigInt z3 = (z1 * (x2 - x1)) % p;

    return [x3, y3, z3];
  }

  List<BigInt> _addPointsWithZ2EqualOne(BigInt x1, BigInt y1, BigInt z1, BigInt x2, BigInt y2, BigInt p) {
    BigInt z1z1 = (z1 * z1) % p;
    BigInt u2 = (x2 * z1z1) % p;
    BigInt s2 = (y2 * z1 * z1z1) % p;

    BigInt h = (u2 - x1) % p;
    BigInt hh = (h * h) % p;
    BigInt i = (BigInt.from(4) * hh) % p;
    BigInt j = (h * i) % p;
    BigInt r = (BigInt.from(2) * (s2 - y1)) % p;

    if (r == BigInt.zero && h == BigInt.zero) {
      return _doubleWithZ1(x2, y2, p, curve.a);
    }
    BigInt v = (x1 * i) % p;
    BigInt x3 = (r * r - j - BigInt.from(2) * v) % p;
    BigInt y3 = (r * (v - x3) - BigInt.from(2) * y1 * j) % p;
    BigInt z3 = (((z1 + h).modPow(BigInt.from(2), p) - z1z1) - hh) % p;
    return [x3, y3, z3];
  }

  List<BigInt> _addPointsWithZNotEqual(BigInt x1, BigInt y1, BigInt z1, BigInt x2, BigInt y2, BigInt z2, BigInt p) {
    BigInt z1z1 = (z1 * z1) % p;
    BigInt z2z2 = (z2 * z2) % p;
    BigInt u1 = (x1 * z2z2) % p;
    BigInt u2 = (x2 * z1z1) % p;
    BigInt s1 = (y1 * z2 * z2z2) % p;
    BigInt s2 = (y2 * z1 * z1z1) % p;
    BigInt h = (u2 - u1) % p;
    BigInt i = (BigInt.from(4) * h * h) % p;
    BigInt j = (h * i) % p;
    BigInt r = (BigInt.from(2) * (s2 - s1)) % p;
    if (h == BigInt.zero && r == BigInt.zero) {
      return _double(x1, y1, z1, p, curve.a);
    }
    BigInt v = (u1 * i) % p;
    BigInt x3 = (r * r - j - BigInt.from(2) * v) % p;
    BigInt y3 = (r * (v - x3) - BigInt.from(2) * s1 * j) % p;
    BigInt z3 = (((z1 + z2).modPow(BigInt.from(2), p) - z1z1 - z2z2) * h) % p;

    return [x3, y3, z3];
  }

  List<BigInt> _addPoints(BigInt x1, BigInt y1, BigInt z1, BigInt x2, BigInt y2, BigInt z2, BigInt p) {
    if (y1 == BigInt.zero || z1 == BigInt.zero) {
      return [x2, y2, z2];
    }
    if (y2 == BigInt.zero || z2 == BigInt.zero) {
      return [x1, y1, z1];
    }
    if (z1 == z2) {
      if (z1 == BigInt.one) {
        return _addPointsWithZ1(x1, y1, x2, y2, p);
      }
      return _addPointsWithCommonZ(x1, y1, z1, x2, y2, p);
    }
    if (z1 == BigInt.one) {
      return _addPointsWithZ2EqualOne(x2, y2, z2, x1, y1, p);
    }
    if (z2 == BigInt.one) {
      return _addPointsWithZ2EqualOne(x1, y1, z1, x2, y2, p);
    }
    return _addPointsWithZNotEqual(x1, y1, z1, x2, y2, z2, p);
  }

  @override
  AbstractPoint operator +(AbstractPoint other) {
    if (isInfinity) {
      return other;
    }
    if (other.isInfinity) {
      return this;
    }
    if (other is AffinePointt) {
      other = ProjectiveECCPoint.fromAffine(other);
    }
    if (curve != other.curve) {
      throw Exception("The other point is on a different curve");
    }
    other as ProjectiveECCPoint;
    BigInt primeField = curve.p;
    BigInt x1 = _coords[0];
    BigInt y1 = _coords[1];
    BigInt z1 = _coords[2];
    BigInt x2 = other._coords[0];
    BigInt y2 = other._coords[1];
    BigInt z2 = other._coords[2];
    List<BigInt> result = _addPoints(x1, y1, z1, x2, y2, z2, primeField);

    BigInt x3 = result[0];
    BigInt y3 = result[1];
    BigInt z3 = result[2];

    if (y3 == BigInt.zero || z3 == BigInt.zero) {
      return ProjectiveECCPoint.infinity(curve);
    }

    return ProjectiveECCPoint._(curve, [x3, y3, z3], order: order);
  }

  ProjectiveECCPoint _multiplyWithPrecompute(BigInt scalar) {
    BigInt resultX = BigInt.zero,
        resultY = BigInt.zero,
        resultZ = BigInt.one,
        primeField = curve.p;
    List<List<BigInt>> precompute = List.from(_precompute);

    for (int i = 0; i < precompute.length; i++) {
      BigInt x2 = precompute[i][0];
      BigInt y2 = precompute[i][1];

      if (scalar.isOdd) {
        if (scalar.isOdd && scalar.isEven) {
          scalar = (scalar + BigInt.one) ~/ BigInt.two;
          List<BigInt> addResult = _addPoints(resultX, resultY, resultZ, x2, -y2, BigInt.one, primeField);
          resultX = addResult[0];
          resultY = addResult[1];
          resultZ = addResult[2];
        } else {
          scalar = (scalar - BigInt.one) ~/ BigInt.two;
          List<BigInt> addResult = _addPoints(resultX, resultY, resultZ, x2, y2, BigInt.one, primeField);
          resultX = addResult[0];
          resultY = addResult[1];
          resultZ = addResult[2];
        }
      } else {
        scalar ~/= BigInt.two;
      }
    }
    if (resultY == BigInt.zero || resultZ == BigInt.zero) {
      return ProjectiveECCPoint.infinity(curve);
    }
    return ProjectiveECCPoint._(curve, [resultX, resultY, resultZ], order: order);
  }

  @override
  ProjectiveECCPoint operator *(BigInt scalar) {
    if (_coords[1] == BigInt.zero || scalar == BigInt.zero) {
      return ProjectiveECCPoint.infinity(curve);
    }
    if (scalar == BigInt.one) {
      return this;
    }
    if (order != null) {
      scalar = scalar % (order! * BigInt.two);
    }

    _precomputeIfNeeded();
    if (_precompute.isNotEmpty) {
      return _multiplyWithPrecompute(scalar);
    }

    scale();

    BigInt x2 = _coords[0];
    BigInt y2 = _coords[1];

    BigInt x3 = BigInt.zero;
    BigInt y3 = BigInt.zero;
    BigInt z3 = BigInt.one;

    BigInt primeField = curve.p;
    BigInt curveA = curve.a;

    List<BigInt> nafList = BigintUtil.computeNAF(scalar);
    for (int i = nafList.length - 1; i >= 0; i--) {
      final List<BigInt> double = _double(x3, y3, z3, primeField, curveA);
      x3 = double[0];
      y3 = double[1];
      z3 = double[2];
      if (nafList[i] < BigInt.zero) {
        final add = _addPoints(x3, y3, z3, x2, -y2, BigInt.one, primeField);
        x3 = add[0];
        y3 = add[1];
        z3 = add[2];
      } else if (nafList[i] > BigInt.zero) {
        final add = _addPoints(x3, y3, z3, x2, y2, BigInt.one, primeField);
        x3 = add[0];
        y3 = add[1];
        z3 = add[2];
      }
    }

    if (y3 == BigInt.zero || z3 == BigInt.zero) {
      return ProjectiveECCPoint.infinity(curve);
    }
    return ProjectiveECCPoint._(curve, [x3, y3, z3], order: order);
  }

  ProjectiveECCPoint mulAdd(BigInt selfMul, AbstractPoint otherPoint, BigInt otherMul) {
    if (otherPoint.isInfinity || otherMul == BigInt.zero) {
      return this * selfMul;
    }
    if (selfMul == BigInt.zero) {
      return (otherPoint * otherMul) as ProjectiveECCPoint;
    }
    ProjectiveECCPoint other;
    if (otherPoint is AffinePointt) {
      other = ProjectiveECCPoint.fromAffine(otherPoint);
    } else {
      other = otherPoint as ProjectiveECCPoint;
    }
    _precomputeIfNeeded();
    other._precomputeIfNeeded();
    if (_precompute.isNotEmpty && other._precompute.isNotEmpty) {
      return (this * selfMul + other * otherMul) as ProjectiveECCPoint;
    }
    if (order != null) {
      selfMul = selfMul % order!;
      otherMul = otherMul % order!;
    }
    BigInt x3 = BigInt.zero;
    BigInt y3 = BigInt.zero;
    BigInt z3 = BigInt.one;
    BigInt p = curve.p;
    BigInt a = curve.a;
    scale();
    BigInt x1 = _coords[0];
    BigInt y1 = _coords[1];
    BigInt z1 = _coords[2];
    other.scale();
    BigInt x2 = other._coords[0];
    BigInt y2 = other._coords[1];
    BigInt z2 = other._coords[2];
    List<BigInt> mAmB = _addPoints(x1, -y1, z1, x2, -y2, z2, p);
    List<BigInt> pAmB = _addPoints(x1, y1, z1, x2, -y2, z2, p);
    List<BigInt> mApB = [pAmB[0], -pAmB[1], pAmB[2]];
    List<BigInt> pApB = [mAmB[0], -mAmB[1], mAmB[2]];
    if (pApB[1] == BigInt.zero || pApB[2] == BigInt.zero) {
      return (this * selfMul + other * otherMul) as ProjectiveECCPoint;
    }
    List<BigInt> selfNaf = BigintUtil.computeNAF(selfMul).reversed.toList();
    List<BigInt> otherNaf = BigintUtil.computeNAF(otherMul).reversed.toList();
    if (selfNaf.length < otherNaf.length) {
      selfNaf = List.filled(otherNaf.length - selfNaf.length, BigInt.zero) + selfNaf;
    } else if (selfNaf.length > otherNaf.length) {
      otherNaf = List.filled(selfNaf.length - otherNaf.length, BigInt.zero) + otherNaf;
    }
    for (int i = 0; i < selfNaf.length; i++) {
      BigInt A = selfNaf[i];
      BigInt B = otherNaf[i];
      List<BigInt> result = _double(x3, y3, z3, p, a);
      if (A == BigInt.zero) {
        if (B == BigInt.zero) {
        } else if (B < BigInt.zero) {
          result = _addPoints(result[0], result[1], result[2], x2, -y2, z2, p);
        } else {
          assert(B > BigInt.zero);
          result = _addPoints(result[0], result[1], result[2], x2, y2, z2, p);
        }
      } else if (A < BigInt.zero) {
        if (B == BigInt.zero) {
          result = _addPoints(result[0], result[1], result[2], x1, -y1, z1, p);
        } else if (B < BigInt.zero) {
          result = _addPoints(result[0], result[1], result[2], mAmB[0], mAmB[1], mAmB[2], p);
        } else {
          assert(B > BigInt.zero);
          result = _addPoints(result[0], result[1], result[2], mApB[0], mApB[1], mApB[2], p);
        }
      } else {
        assert(A > BigInt.zero);
        if (B == BigInt.zero) {
          result = _addPoints(result[0], result[1], result[2], x1, y1, z1, p);
        } else if (B < BigInt.zero) {
          result = _addPoints(result[0], result[1], result[2], pAmB[0], pAmB[1], pAmB[2], p);
        } else {
          assert(B > BigInt.zero);
          result = _addPoints(result[0], result[1], result[2], pApB[0], pApB[1], pApB[2], p);
        }
      }
      x3 = result[0];
      y3 = result[1];
      z3 = result[2];
    }
    if (y3 == BigInt.zero || z3 == BigInt.zero) {
      return ProjectiveECCPoint.infinity(curve);
    }
    return ProjectiveECCPoint._(curve, [x3, y3, z3], order: order);
  }

  @override
  int get hashCode => curve.hashCode ^ x.hashCode ^ y.hashCode;
}
