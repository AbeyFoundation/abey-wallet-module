import 'package:abey_wallet/utils/bigint_util.dart';
import 'package:abey_wallet/vender/crypto/hash/hash.dart';
import 'package:abey_wallet/vender/crypto/hmac/hmac.dart';

class RFC6979 {
  static BigInt generateK(BigInt order, BigInt secexp, HashFunc hashFunc, List<int> data, {int retryGn = 0, List<int>? extraEntropy}) {
    int qlen = order.bitLength;
    final hx = hashFunc();
    int holen = hx.getDigestLength;
    int rolen = (qlen + 7) ~/ 8;

    List<List<int>> bx = [
      BigintUtil.toBytes(secexp, length: BigintUtil.orderLen(order)),
      BigintUtil.bitsToOctetsWithOrderPadding(data, order),
      extraEntropy ?? List.empty(),
    ];

    List<int> v = List<int>.filled(holen, 0);
    v.fillRange(0, holen, 0x01);
    List<int> k = List<int>.filled(holen, 0);
    HMAC hmac = HMAC(hashFunc, k);
    hmac.update(List<int>.from([...v, 0x00]));
    for (var i in bx) {
      hmac.update(i);
    }
    k = hmac.digest();
    hmac.clean();
    hmac = HMAC(hashFunc, k);
    hmac.update(v);
    v = hmac.digest();
    hmac.clean();
    hmac = HMAC(hashFunc, k);
    hmac.update(List<int>.from([...v, 0x01]));

    for (var i in bx) {
      hmac.update(i);
    }
    k = hmac.digest();
    v = HMAC(hashFunc, k).update(v).digest();
    while (true) {
      List<int> t = List.empty();
      while (t.length < rolen) {
        v = HMAC(hashFunc, k).update(v).digest();
        t = List<int>.from([...t, ...v]);
      }
      BigInt secret = BigintUtil.bitsToBigIntWithLengthLimit(t, qlen);
      if (secret >= BigInt.one && secret < order) {
        if (retryGn <= 0) {
          return secret;
        }
        retryGn -= 1;
      }
      k = HMAC(hashFunc, k).update(List<int>.from([...v, 0x00])).digest();
      v = HMAC(hashFunc, k).update(v).digest();
    }
  }
}
