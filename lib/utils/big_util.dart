import 'package:abey_wallet/utils/bigint_util.dart';

class BigUtil {
  static final BigUtil zero = BigUtil.from(0);
  static final BigUtil one = BigUtil.from(1);
  static final BigUtil ten = BigUtil.from(10);
  final BigInt numerator;
  final BigInt denominator;
  String? _inDecimal;
  static final _one = BigInt.one;
  static final _zero = BigInt.zero;
  static final _ten = BigInt.from(10);

  List<int> encodeRational() {
    final numeratorBytes = BigintUtil.toBytes(numerator, length: 2);
    final denominatorBytes = BigintUtil.toBytes(denominator, length: 2);
    final bytes = List<int>.from(numeratorBytes)..addAll(denominatorBytes);
    return bytes;
  }

  BigUtil._(this.numerator, this.denominator);

  factory BigUtil(BigInt numerator, {BigInt? denominator}) {
    if (denominator == null) {
      return BigUtil._(numerator, _one);
    }
    if (denominator == _zero) {
      throw Exception("Denominator cannot be 0.");
    }
    if (numerator == _zero) {
      return BigUtil._(_zero, _one);
    }
    return _reduce(numerator, denominator);
  }

  factory BigUtil.from(int numerator, {int? denominator}) {
    return BigUtil(BigInt.from(numerator), denominator: BigInt.from(denominator ?? 1));
  }

  static BigInt _gcd(BigInt a, BigInt b) {
    BigInt t;
    while (b != _zero) {
      t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  static BigInt _lcm(BigInt a, BigInt b) {
    return (a * b) ~/ _gcd(a, b);
  }

  static BigUtil? tryParseDecimaal(String decimal) {
    try {
      return BigUtil.parseDecimal(decimal);
    } catch (e) {
      return null;
    }
  }

  factory BigUtil.parseDecimal(String decimal) {
    List<String> parts = decimal.split(RegExp(r'e', caseSensitive: false));
    if (parts.length > 2) {
      throw Exception("Invalid input: too many 'e' tokens");
    }

    if (parts.length > 1) {
      bool isPositive = true;
      if (parts[1][0] == "-") {
        parts[1] = parts[1].substring(1);
        isPositive = false;
      }
      if (parts[1][0] == "+") {
        parts[1] = parts[1].substring(1);
      }
      final BigUtil significand = BigUtil.parseDecimal(parts[0]);
      final BigUtil exponent = BigUtil._(_ten.pow(int.parse(parts[1])), _one);
      if (isPositive) {
        return significand * exponent;
      } else {
        return significand / exponent;
      }
    }

    parts = decimal.trim().split(".");
    if (parts.length > 2) {
      throw Exception("Invalid input: too many '.' tokens");
    }
    if (parts.length > 1) {
      bool isNegative = parts[0][0] == '-';
      if (isNegative) parts[0] = parts[0].substring(1);
      BigUtil intPart = BigUtil._(BigInt.parse(parts[0]), _one);
      final int length = parts[1].length;
      while (parts[1].isNotEmpty && parts[1][0] == "0") {
        parts[1] = parts[1].substring(1);
      }

      final String exp = "1${"0" * length}";
      final BigUtil decPart = _reduce(
          parts[1].isEmpty ? _zero : BigInt.parse(parts[1]), BigInt.parse(exp));
      intPart = intPart + decPart;
      if (isNegative) intPart = ~intPart;
      return intPart;
    }

    return BigUtil._(BigInt.parse(decimal), _one);
  }

  BigInt toBigInt() {
    return _truncate;
  }

  double toDouble() {
    return numerator / denominator;
  }

  BigUtil operator +(BigUtil other) {
    final BigInt multiple = _lcm(denominator, other.denominator);
    BigInt a = multiple ~/ denominator;
    BigInt b = multiple ~/ other.denominator;

    a = numerator * a;
    b = other.numerator * b;

    return _reduce(a + b, multiple);
  }

  BigUtil operator *(BigUtil other) {
    final BigInt resultNumerator = numerator * other.numerator;
    final BigInt resultDenominator = denominator * other.denominator;
    return _reduce(resultNumerator, resultDenominator);
  }

  BigUtil operator /(BigUtil other) {
    final BigInt resultNumerator = numerator * other.denominator;
    final BigInt resultDenominator = denominator * other.numerator;
    return _reduce(resultNumerator, resultDenominator);
  }

  BigUtil operator -() {
    return BigUtil._(-numerator, denominator);
  }

  BigUtil operator -(BigUtil other) {
    return this + ~other;
  }

  BigUtil operator %(BigUtil other) {
    BigUtil re = remainder(other);
    if (isNegative) {
      re += other.abs();
    }
    return re;
  }

  bool operator <(BigUtil other) {
    return compareTo(other) < 0;
  }

  bool operator <=(BigUtil other) {
    return compareTo(other) <= 0;
  }

  bool operator >(BigUtil other) {
    return compareTo(other) > 0;
  }

  bool operator >=(BigUtil other) {
    return compareTo(other) >= 0;
  }

  BigUtil operator ~/(BigUtil other) {
    BigInt divmod = _truncate;
    BigInt rminder = _remainder;
    BigInt floor;

    if (rminder == _zero || !divmod.isNegative) {
      floor = divmod;
    } else {
      floor = divmod - _one;
    }
    return BigUtil._(floor, _one);
  }

  BigUtil operator ~() {
    if (denominator.isNegative) {
      return BigUtil._(numerator, -denominator);
    }
    return BigUtil._(-numerator, denominator);
  }

  BigUtil pow(int n) {
    final BigInt num = numerator.pow(n);
    final BigInt denom = denominator.pow(n);
    return _reduce(num, denom);
  }

  BigUtil ceil(toBigInt) {
    BigInt divmod = _truncate;
    BigInt remind = _remainder;
    BigInt ceil;

    if (remind == _zero || divmod.isNegative) {
      ceil = divmod;
    } else {
      ceil = divmod + _one;
    }

    return BigUtil._(ceil, _one);
  }

  int compareTo(BigUtil v) {
    if (denominator == v.denominator) {
      return numerator.compareTo(v.numerator);
    }
    final int comparison = (denominator.isNegative == v.denominator.isNegative) ? 1 : -1;
    return comparison * (numerator * v.denominator).compareTo(v.numerator * denominator);
  }

  BigUtil abs() {
    if (isPositive) return this;
    return ~this;
  }

  bool get isNegative {
    return (numerator.isNegative != denominator.isNegative) && numerator != _zero;
  }

  bool get isPositive {
    return (numerator.isNegative == denominator.isNegative) && numerator != _zero;
  }

  bool get isZero {
    return numerator == _zero;
  }

  static BigUtil _reduce(BigInt n, BigInt d) {
    final BigInt divisor = _gcd(n, d);
    final BigInt num = n ~/ divisor;
    final BigInt denom = d ~/ divisor;
    if (denom.isNegative) {
      return BigUtil._(-num, -denom);
    }
    return BigUtil._(num, denom);
  }

  BigUtil remainder(BigUtil other) {
    return this - (this ~/ other) * other;
  }

  BigInt get _remainder {
    return numerator.remainder(denominator);
  }

  BigInt get _truncate {
    return numerator ~/ denominator;
  }

  String toDecimal({int? digits}) {
    if (_inDecimal != null) {
      return _inDecimal!;
    }
    digits ??= scale;
    final BigInt nDive = _truncate;
    final BigInt nReminder = _remainder;
    String intPart = nDive.abs().toString();
    final BigUtil remainder = _reduce(nReminder.abs(), denominator);
    final BigUtil shiftedRemainder = remainder * BigUtil._(_ten.pow(digits), _one);
    final BigInt decPart = shiftedRemainder.numerator ~/ shiftedRemainder.denominator;
    if (isNegative) {
      intPart = "-$intPart";
    }
    if (decPart == _zero) {
      return intPart;
    }
    String decPartStr = decPart.abs().toString();
    if (decPartStr.length < digits) {
      decPartStr = '0' * (digits - decPartStr.length) + decPartStr;
    }
    if ((shiftedRemainder.numerator % shiftedRemainder.denominator) == _zero) {
      while (decPartStr.endsWith('0')) {
        decPartStr = decPartStr.substring(0, decPartStr.length - 1);
      }
    }
    if (digits < 1) {
      return intPart;
    }
    return '$intPart${decPart < _zero ? '' : '.'}$decPartStr';
  }

  bool get isDecimal => denominator != _one;

  @override
  String toString() {
    _inDecimal ??= toDecimal();
    return _inDecimal!;
  }

  int get precision {
    final toAbs = abs();
    return toAbs.scale + toAbs.toBigInt().toString().length;
  }

  int get scale {
    int scale = 0;
    BigUtil r = this;
    while (r.denominator != BigInt.one) {
      scale++;
      r *= ten;
    }
    return scale;
  }

  @override
  bool operator ==(other) {
    return other is BigUtil && other.denominator == denominator && other.numerator == numerator;
  }

  @override
  int get hashCode => numerator.hashCode ^ denominator.hashCode;
}
