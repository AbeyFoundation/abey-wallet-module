import 'dart:typed_data';
import 'package:abey_wallet/utils/bigint_util.dart';
import 'package:abey_wallet/vender/crypto/cdsa/curve/curves.dart';

class Ed25519Utils {
  static List<int> scalarReduce(List<int> scalar) {
    final toint = BigintUtil.fromBytes(scalar, byteOrder: Endian.little);
    final reduce = toint % Curves.generatorED25519.order!;
    final tobytes = BigintUtil.toBytes(reduce, order: Endian.little, length: BigintUtil.orderLen(Curves.generatorED25519.order!));
    return tobytes;
  }
}
