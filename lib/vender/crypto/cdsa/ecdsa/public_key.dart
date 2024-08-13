import 'package:abey_wallet/utils/bigint_util.dart';
import 'package:abey_wallet/vender/crypto/cdsa/ecdsa/signature.dart';
import 'package:abey_wallet/vender/crypto/cdsa/point/base.dart';
import 'package:abey_wallet/vender/crypto/cdsa/point/ec_projective_point.dart';

class ECDSAPublicKey {
  final ProjectiveECCPoint generator;
  final ProjectiveECCPoint point;
  ECDSAPublicKey._(this.generator, this.point);

  factory ECDSAPublicKey(ProjectiveECCPoint generator, ProjectiveECCPoint point, {bool verify = true}) {
    final curve = generator.curve;
    final n = generator.order;
    final p = curve.p;
    if (!(BigInt.zero <= point.x && point.x < p) || !(BigInt.zero <= point.y && point.y < p)) {
      throw Exception("The public point has x or y out of range.");
    }
    if (verify && !curve.containsPoint(point.x, point.y)) {
      throw Exception("AffinePointt does not lay on the curve");
    }
    if (n == null) {
      throw Exception("Generator point must have order.");
    }
    if (verify && curve.cofactor() != BigInt.one && !(point * n).isInfinity) {
      throw Exception("Generator point order is bad.");
    }
    return ECDSAPublicKey._(generator, point);
  }

  @override
  bool operator ==(Object other) {
    if (other is ECDSAPublicKey) {
      return generator.curve == other.generator.curve && point == other.point;
    }
    return false;
  }

  bool verifies(BigInt hash, ECDSASignature signature) {
    final ProjectiveECCPoint G = generator;
    final BigInt n = G.order!;
    final r = signature.r;
    final s = signature.s;
    if (r < BigInt.one || r > n - BigInt.one) {
      return false;
    }
    if (s < BigInt.one || s > n - BigInt.one) {
      return false;
    }
    final c = BigintUtil.inverseMod(s, n);
    final u1 = (hash * c) % n;
    final u2 = (r * c) % n;
    final xy = G.mulAdd(u1, point, u2);
    final v = xy.x % n;
    return v == r;
  }

  @override
  int get hashCode => generator.hashCode ^ point.hashCode;

  List<int> toBytes([EncodeType encodeType = EncodeType.comprossed]) {
    return point.toBytes(encodeType);
  }
}
