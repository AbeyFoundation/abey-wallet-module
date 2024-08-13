import 'dart:typed_data';
import 'package:abey_wallet/utils/bigint_util.dart';
import 'package:abey_wallet/utils/bytes_util.dart';
import 'package:abey_wallet/vender/crypto/cdsa/curve/curves.dart';
import 'package:abey_wallet/vender/crypto/cdsa/eddsa/publickey.dart';
import 'package:abey_wallet/vender/crypto/cdsa/point/edwards.dart';
import 'package:abey_wallet/vender/crypto/hash/hash.dart';

class EDDSAPrivateKey {
  final EDPoint generator;
  final int baselen;
  final List<int> _privateKey;
  final List<int>? _extendedKey;
  final BigInt _secret;
  final EDDSAPublicKey publicKey;
  EDDSAPrivateKey._(this.generator, this.baselen, List<int> privateKey,
      this._secret, List<int>? extendedKey)
      : _privateKey = BytesUtil.toBytes(privateKey, unmodifiable: true),
        _extendedKey = BytesUtil.tryToBytes(extendedKey, unmodifiable: true),
        publicKey = EDDSAPublicKey(generator, (generator * _secret).toBytes());

  factory EDDSAPrivateKey(EDPoint generator, List<int> privateKey, HashFunc hashMethod,) {
    final baselen = (generator.curve.p.bitLength + 1 + 7) ~/ 8;
    if (privateKey.length != baselen) {
      throw Exception('Incorrect size of private key, expected: $baselen bytes');
    }
    final extendedKey = hashMethod().update(privateKey).digest();
    final a = extendedKey.sublist(0, baselen);
    final prunedKey = _keyPrune(List<int>.from(a), generator);
    final secret = BigintUtil.fromBytes(prunedKey, byteOrder: Endian.little);
    return EDDSAPrivateKey._(generator, baselen, privateKey, secret, extendedKey.sublist(baselen));
  }

  factory EDDSAPrivateKey.fromKhalow(EDPoint generator, List<int> privateKey) {
    final baselen = (generator.curve.p.bitLength + 1 + 7) ~/ 8;
    if (privateKey.length < baselen) {
      throw Exception('Incorrect size of private key, expected: ${baselen * 2} bytes');
    }
    final List<int> privateKeyPart = privateKey.sublist(0, baselen);
    final List<int> extendedKey = privateKey.sublist(baselen);
    final secret = BigintUtil.fromBytes(privateKeyPart, byteOrder: Endian.little);
    return EDDSAPrivateKey._(generator, baselen, privateKeyPart, secret, extendedKey);
  }

  List<int> get privateKey => List<int>.from(_privateKey);

  @override
  bool operator ==(Object other) {
    if (other is EDDSAPrivateKey) {
      return generator.curve == other.generator.curve && BytesUtil.bytesEqual(_privateKey, other._privateKey);
    }
    return false;
  }

  static List<int> _keyPrune(List<int> key, EDPoint generator) {
    final h = generator.curve.cofactor();
    int hLog;
    if (h == BigInt.from(4)) {
      hLog = 2;
    } else if (h == BigInt.from(8)) {
      hLog = 3;
    } else {
      throw Exception('Only cofactor 4 and 8 curves are supported');
    }
    key[0] &= ~((1 << hLog) - 1);
    final l = generator.curve.p.bitLength;
    if (l % 8 == 0) {
      key[key.length - 1] = 0;
      key[key.length - 2] |= 0x80;
    } else {
      key[key.length - 1] = key[key.length - 1] & ((1 << (l % 8)) - 1) | (1 << (l % 8) - 1);
    }
    return key;
  }

  List<int> sign(List<int> data, HashFunc hashMethod,) {
    List<int> dom = List.empty();
    if (generator.curve == Curves.curveEd448) {
      dom = List<int>.from([...'SigEd448'.codeUnits, 0x00, 0x00]);
    }
    final r = BigintUtil.fromBytes(hashMethod().update(List<int>.from([...dom, ..._extendedKey ?? [], ...data])).digest(), byteOrder: Endian.little);
    final R = (generator * r).toBytes();
    BigInt k = BigintUtil.fromBytes(hashMethod().update(List<int>.from([...dom, ...R, ...publicKey.toBytes(), ...data])).digest(), byteOrder: Endian.little);
    k %= generator.order!;
    final s = (r + k * _secret) % generator.order!;
    return List<int>.from([
      ...R,
      ...BigintUtil.toBytes(s, length: baselen, order: Endian.little)
    ]);
  }

  @override
  int get hashCode => _privateKey.hashCode ^ generator.hashCode;
}
