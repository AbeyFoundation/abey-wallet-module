import 'dart:typed_data';

import 'package:abey_wallet/utils/bigint_util.dart';
import 'package:abey_wallet/vender/crypto/cdsa/ecdsa/signature.dart';
import 'package:abey_wallet/vender/crypto/cdsa/point/ec_projective_point.dart';
import 'public_key.dart';

class ECDSAPrivateKey {
  final ECDSAPublicKey publicKey;
  final BigInt secretMultiplier;
  ECDSAPrivateKey._(this.publicKey, this.secretMultiplier);

  factory ECDSAPrivateKey.fromBytes(List<int> bytes, ProjectiveECCPoint curve) {
    if (bytes.length != curve.curve.baselen) {
      throw Exception("Invalid length of private key");
    }
    final secexp = BigintUtil.fromBytes(bytes, byteOrder: Endian.big);
    final ECDSAPublicKey publicKey = ECDSAPublicKey(curve, curve * secexp);
    return ECDSAPrivateKey._(publicKey, secexp);
  }

  @override
  bool operator ==(other) {
    if (other is ECDSAPrivateKey) {
      return publicKey == other.publicKey && secretMultiplier == other.secretMultiplier;
    }
    return false;
  }

  ECDSASignature sign(BigInt hash, BigInt randomK) {
    BigInt n = publicKey.generator.order!;
    BigInt k = randomK % n;
    BigInt ks = k + n;
    BigInt kt = ks + n;
    BigInt r;
    if (ks.bitLength == n.bitLength) {
      r = (publicKey.generator * kt).x % n;
    } else {
      r = (publicKey.generator * ks).x % n;
    }
    if (r == BigInt.zero) {
      throw Exception("unlucky random number r");
    }
    BigInt s = (BigintUtil.inverseMod(k, n) * (hash + (secretMultiplier * r) % n)) % n;
    if (s == BigInt.zero) {
      throw Exception("unlucky random number s");
    }
    return ECDSASignature(r, s);
  }

  List<int> toBytes() {
    final tob = BigintUtil.toBytes(secretMultiplier, length: publicKey.generator.curve.baselen);
    return tob;
  }

  @override
  int get hashCode => secretMultiplier.hashCode ^ publicKey.hashCode;
}
