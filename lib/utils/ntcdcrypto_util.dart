import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import "package:abey_wallet/utils/hex_util.dart";

class NTC {
  final BigInt prime = BigInt.parse("115792089237316195423570985008687907853269984665640564039457584007913129639747", radix: 10);
  var rand = Random.secure();
  final part = 16;
  final maxInt16 = 1 << 16;

  String genNumber() {
    String combinedVal = "";
    for (var i = 0; i < part; i++) {
      int part = rand.nextInt(maxInt16);
      combinedVal += part.toRadixString(10);
    }
    return combinedVal;
  }

  BigInt randomNumber() {
    BigInt rs = BigInt.parse(genNumber());
    while (rs.compareTo(prime) >= 0) {
      rs = BigInt.parse(genNumber());
    }
    return rs;
  }

  Uint8List hexToU8(String hex) {
    if (hex.length % 2 == 1) {
      hex = "0" + hex;
    }
    int len = hex.length ~/ 2;
    Uint8List u8 = new Uint8List(len);
    var j = 0;
    for (int i = 0; i < len; i++) {
      u8[i] = int.parse(hex.substring(j, j + 2), radix: 16);
      j += 2;
    }
    return u8;
  }

  String u8ToHex(Uint8List u8) {
    String hex = "";
    int len = u8.length;
    for (int i = 0; i < len; i++) {
      hex += u8[i].toRadixString(16).padLeft(2, '0');
    }
    return hex;
  }

  String toBase64Url(BigInt number) {
    String hexdata = number.toRadixString(16);
    int n = 64 - hexdata.length;
    for (int i = 0; i < n; i++) {
      hexdata = "0" + hexdata;
    }
    return base64Url.encode(hexToU8(hexdata));
  }

  BigInt fromBase64Url(String number) {
    String hexdata = u8ToHex(base64Url.decode(number));
    return BigInt.parse(hexdata, radix: 16);
  }

  String toBase64(BigInt number) {
    String hexdata = number.toRadixString(16);
    int n = 64 - hexdata.length;
    for (int i = 0; i < n; i++) {
      hexdata = "0" + hexdata;
    }
    return base64Url.encode(utf8.encode(hexdata));
  }

  BigInt fromBase64(String number) {
    String hexdata = utf8.decode(base64Url.decode(number));
    return BigInt.parse(hexdata, radix: 16);
  }

  String toHex(BigInt number) {
    String hexdata = number.toRadixString(16);
    int n = 64 - hexdata.length;
    for (int i = 0; i < n; i++) {
      hexdata = "0" + hexdata;
    }
    return hexdata;
  }

  BigInt fromHex(String number) {
    return BigInt.parse(number, radix: 16);
  }

  List<BigInt> splitSecretToBigInt(String secret) {
    List<BigInt> rs = [];
    if (secret.isNotEmpty) {
      String hexData = HEX.encode(utf8.encode(secret));
      int count = (hexData.length / 64.0).ceil();
      for (int i = 0; i < count; i++) {
        if ((i + 1) * 64 < hexData.length) {
          BigInt bi = BigInt.parse(hexData.substring(i * 64, (i + 1) * 64), radix: 16);
          rs.add(bi);
        } else {
          String last = hexData.substring(i * 64, hexData.length);
          int n = 64 - last.length;
          for (int j = 0; j < n; j++) {
            last += "0";
          }
          BigInt bi = BigInt.parse(last, radix: 16);
          rs.add(bi);
        }
      }
    }
    return rs;
  }

  String trimRight(String hexData) {
    int i = hexData.length - 1;
    while (i >= 0 && hexData[i] == '0') {
      --i;
    }
    return hexData.substring(0, i + 1);
  }

  String mergeBigIntToString(List<BigInt> secrets) {
    String rs = "";
    String hexData = "";
    for (BigInt s in secrets) {
      String tmp = s.toRadixString(16);
      int n = 64 - tmp.length;
      for (int j = 0; j < n; j++) {
        tmp = "0" + tmp;
      }
      hexData = hexData + tmp;
    }
    // hexData = trimRight(hexData);
    rs = utf8.decode(HEX.decode(hexData));
    return rs;
  }

  bool inNumbers(List<BigInt> numbers, BigInt value) {
    for (BigInt n in numbers) {
      if (n.compareTo(value) == 0) {
        return true;
      }
    }
    return false;
  }

  BigInt evaluatePolynomial(List<List<BigInt>> poly, int part, BigInt x) {
    int last = poly[part].length - 1;
    BigInt accum = poly[part][last];
    for (int i = last - 1; i >= 0; --i) {
      accum = ((accum * x) + poly[part][i]) % prime;
    }
    return accum;
  }

  bool isValidShareBase64(String candidate) {
    if (candidate.isEmpty) {
      return false;
    }
    if (candidate.length % 88 != 0) {
      return false;
    }
    int count = candidate.length ~/ 44;
    for (int i = 0; i < count; i++) {
      String part = candidate.substring(i * 44, (i + 1) * 44);
      BigInt decode = fromBase64Url(part);
      if (decode.compareTo(BigInt.zero) <= 0 || decode.compareTo(prime) >= 0) {
        return false;
      }
    }
    return true;
  }

  List<List<List<BigInt>>> decodeShareBase64(List<String> shares) {
    String first = shares[0];
    int parts = first.length ~/ 88;
    var points = List<List<List<BigInt>>>.generate(shares.length, (i) => List<List<BigInt>>.generate(parts, (j) => List<BigInt>.generate(2, (k) => BigInt.zero)));
    for (int i = 0; i < shares.length; i++) {
      if (isValidShareBase64(shares[i]) == false) {
        throw new Exception("one of the shares is invalid");
      }
      String share = shares[i];
      int count = share.length ~/ 88;
      for (int j = 0; j < count; j++) {
        String cshare = share.substring(j * 88, (j + 1) * 88);
        points[i][j][0] = fromBase64Url(cshare.substring(0, 44));
        points[i][j][1] = fromBase64Url(cshare.substring(44, 88));
      }
    }
    return points;
  }

  bool isValidShareHex(String candidate) {
    if (candidate.isEmpty) {
      return false;
    }
    if (candidate.length % 128 != 0) {
      return false;
    }
    int count = candidate.length ~/ 64;
    for (int i = 0; i < count; i++) {
      String part = candidate.substring(i * 64, (i + 1) * 64);
      BigInt decode = fromHex(part);
      if (decode.compareTo(BigInt.zero) <= 0 || decode.compareTo(prime) >= 0) {
        return false;
      }
    }
    return true;
  }

  List<List<List<BigInt>>> decodeShareHex(List<String> shares) {
    String first = shares[0];
    int parts = first.length ~/ 128;
    var points = List<List<List<BigInt>>>.generate(shares.length, (i) => List<List<BigInt>>.generate(parts, (j) => List<BigInt>.generate(2, (k) => BigInt.zero)));
    for (int i = 0; i < shares.length; i++) {
      if (isValidShareHex(shares[i]) == false) {
        throw new Exception("one of the shares is invalid");
      }
      String share = shares[i];
      int count = share.length ~/ 128;
      for (int j = 0; j < count; j++) {
        String cshare = share.substring(j * 128, (j + 1) * 128);
        points[i][j][0] = fromHex(cshare.substring(0, 64));
        points[i][j][1] = fromHex(cshare.substring(64, 128));
      }
    }
    return points;
  }

  List<String> create(int minimum, int shares, String secret, bool isBase64) {
    List<String> rs = [];
    if (minimum <= 0 || shares <= 0) {
      throw new Exception("minimum or shares is invalid");
    }
    if (minimum > shares) {
      throw new Exception("cannot require more shares then existing");
    }
    if (secret.isEmpty) {
      throw new Exception("secret is NULL or empty");
    }
    List<BigInt> secrets = splitSecretToBigInt(secret);
    List<BigInt> numbers = [];
    numbers.add(BigInt.zero);
    var polynomial = List<List<BigInt>>.generate(secrets.length, (i) => List<BigInt>.generate(minimum, (j) => BigInt.zero));
    for (int i = 0; i < secrets.length; i++) {
      polynomial[i][0] = secrets[i];
      for (int j = 1; j < minimum; j++) {
        BigInt number = randomNumber();
        while (inNumbers(numbers, number)) {
          number = randomNumber();
        }
        numbers.add(number);
        polynomial[i][j] = number;
      }
    }

    for (int i = 0; i < shares; i++) {
      String s = "";
      for (int j = 0; j < secrets.length; j++) {
        BigInt x = randomNumber();
        while (inNumbers(numbers, x)) {
          x = randomNumber();
        }
        numbers.add(x);
        BigInt y = evaluatePolynomial(polynomial, j, x);
        if (isBase64) {
          s += toBase64Url(x);
          s += toBase64Url(y);
        } else {
          s += toHex(x);
          s += toHex(y);
        }
      }
      rs.add(s);
    }
    return rs;
  }

  String combine(List<String> shares, bool isBase64) {
    String rs = "";
    if (shares.isEmpty) {
      throw new Exception("shares is NULL or empty");
    }
    var points;
    if (isBase64) {
      points = decodeShareBase64(shares);
    } else {
      points = decodeShareHex(shares);
    }
    List<BigInt> secrets = [];
    int numSecret = points[0].length;
    for (int j = 0; j < numSecret; j++) {
      secrets.add(BigInt.zero);
      for (int i = 0; i < shares.length; i++) {
        BigInt ax = points[i][j][0];
        BigInt ay = points[i][j][1];
        BigInt numerator = BigInt.one;
        BigInt denominator = BigInt.one;
        for (int k = 0; k < shares.length; k++) {
          if (k != i) {
            BigInt bx = points[k][j][0];
            BigInt negbx = -bx;
            BigInt axbx = ax - bx;
            numerator = (numerator * negbx) % prime;
            denominator = (denominator * axbx) % prime;
          }
        }
        BigInt fx = (ay * numerator) % prime;
        fx = (fx * (denominator.modInverse(prime))) % prime;
        BigInt secret = secrets[j];
        secret = (secret + fx) % prime;
        secrets[j] = secret;
      }
    }
    rs = mergeBigIntToString(secrets);
    return rs;
  }
}
