import 'package:abey_wallet/utils/bigint_util.dart';
import 'package:abey_wallet/vender/crypto/cdsa/ecdsa/public_key.dart';
import 'package:abey_wallet/vender/crypto/cdsa/point/ec_projective_point.dart';
import 'package:abey_wallet/vender/crypto/cdsa/utils/utils.dart';

class ECDSASignature {
  factory ECDSASignature.fromBytes(List<int> bytes, ProjectiveECCPoint generator) {
    if (bytes.length != generator.curve.baselen * 2) {
      throw Exception("incorrect signatureBytes length ${bytes.length}");
    }
    final r = BigintUtil.fromBytes(bytes.sublist(0, generator.curve.baselen));
    final s = BigintUtil.fromBytes(bytes.sublist(generator.curve.baselen, generator.curve.baselen * 2));
    return ECDSASignature(r, s);
  }
  final BigInt r;
  final BigInt s;

  ECDSASignature(this.r, this.s);
  @override
  String toString() {
    return "($r, $s)";
  }

  List<ECDSAPublicKey> recoverPublicKeys(List<int> hash, ProjectiveECCPoint generator) {
    final curve = generator.curve;
    final order = generator.order!;
    final e = BigintUtil.fromBytes(hash);
    final alpha = (r.modPow(BigInt.from(3), curve.p) + curve.a * r + curve.b) % curve.p;
    final beta = ECDSAUtils.modularSquareRootPrime(alpha, curve.p);
    final y = (beta % BigInt.two == BigInt.zero) ? beta : (curve.p - beta);
    final ProjectiveECCPoint r1 = ProjectiveECCPoint(curve: curve, x: r, y: y, z: BigInt.one, order: order);
    final inverseR = BigintUtil.inverseMod(r, order);
    final ProjectiveECCPoint q1 = ((r1 * s) + (generator * (-e % order))) * inverseR as ProjectiveECCPoint;
    final pk1 = ECDSAPublicKey(generator, q1);
    final r2 = ProjectiveECCPoint(curve: curve, x: r, y: -y, z: BigInt.one, order: order);
    final ProjectiveECCPoint q2 = ((r2 * s) + (generator * (-e % order))) * inverseR as ProjectiveECCPoint;
    final pk2 = ECDSAPublicKey(generator, q2);
    return [pk1, pk2];
  }

  ECDSAPublicKey? recoverPublicKey(List<int> hash, ProjectiveECCPoint generator, int recId) {
    final curve = generator.curve;
    final order = generator.order!;
    final secret = BigintUtil.fromBytes(hash);
    final alpha = (r.modPow(BigInt.from(3), curve.p) + curve.a * r + curve.b) % curve.p;
    final beta = ECDSAUtils.modularSquareRootPrime(alpha, curve.p);
    BigInt y = (beta % BigInt.two == BigInt.zero) ? beta : (curve.p - beta);
    if (recId > 0) {
      y = -y;
    }
    final ProjectiveECCPoint r1 = ProjectiveECCPoint(curve: curve, x: r, y: y, z: BigInt.one, order: order);
    final ProjectiveECCPoint q1 = ((r1 * s) + (generator * (-secret % order))) * BigintUtil.inverseMod(r, order) as ProjectiveECCPoint;
    return ECDSAPublicKey(generator, q1);
  }

  List<int> toBytes(int baselen) {
    final sBytes = BigintUtil.toBytes(s, length: baselen);
    final rBytes = BigintUtil.toBytes(r, length: baselen);
    return [...rBytes, ...sBytes];
  }
}
