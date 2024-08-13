import 'dart:typed_data';
import 'package:abey_wallet/utils/bigint_util.dart';
import 'package:abey_wallet/utils/bytes_util.dart';
import 'package:abey_wallet/vender/crypto/cdsa/curve/curves.dart';
import 'package:abey_wallet/vender/crypto/cdsa/point/edwards.dart';
import 'package:abey_wallet/vender/crypto/hash/hash.dart';

class EDDSAPublicKey {
  final EDPoint generator;
  final List<int> _encoded;
  final int baselen;
  final EDPoint _point;

  EDDSAPublicKey._(
      this.generator, List<int> _encoded, this.baselen, this._point)
      : _encoded = BytesUtil.toBytes(_encoded, unmodifiable: true);

  factory EDDSAPublicKey(EDPoint generator, List<int> publicKey) {
    return EDDSAPublicKey.fromPoint(generator, EDPoint.fromBytes(curve: generator.curve, data: publicKey));
  }

  factory EDDSAPublicKey.fromPoint(EDPoint generator, EDPoint publicPoint,) {
    final int baselen = (generator.curve.p.bitLength + 1 + 7) ~/ 8;
    final pubkeyBytes = publicPoint.toBytes();
    if (pubkeyBytes.length != baselen) {
      throw Exception('Incorrect size of the public key, expected: $baselen bytes');
    }
    return EDDSAPublicKey._(generator, pubkeyBytes, baselen, publicPoint);
  }

  @override
  bool operator ==(other) {
    if (other is EDDSAPublicKey) {
      return generator.curve == other.generator.curve && BytesUtil.bytesEqual(_encoded, other._encoded);
    }
    return false;
  }

  EDPoint get point => _point;
  EDPoint publicPoint() => _point;
  List<int> toBytes() {
    return List<int>.from(_encoded);
  }

  bool verify(List<int> data, List<int> signature, HashFunc hashMethod,) {
    if (signature.length != 2 * baselen) {
      throw Exception('Invalid signature length, expected: ${2 * baselen} bytes');
    }
    final R = EDPoint.fromBytes(curve: generator.curve, data: signature.sublist(0, baselen));
    final S = BigintUtil.fromBytes(signature.sublist(baselen), byteOrder: Endian.little);
    if (S >= generator.order!) {
      throw Exception('Invalid signature');
    }
    List<int> dom = List.empty();
    if (generator.curve == Curves.curveEd448) {
      dom = List<int>.from([...'SigEd448'.codeUnits, 0x00, 0x00]);
    }
    final h = hashMethod();
    h.update(List<int>.from([...dom, ...R.toBytes(), ..._encoded, ...data]));
    final k = BigintUtil.fromBytes(h.digest(), byteOrder: Endian.little);
    if (generator * S != _point * k + R) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode => generator.curve.hashCode ^ _encoded.hashCode;
}
