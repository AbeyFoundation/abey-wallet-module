import "dart:typed_data";
import "package:pointycastle/digests/sha512.dart";
import "package:pointycastle/api.dart" show KeyParameter;
import "package:pointycastle/macs/hmac.dart";
import "package:pointycastle/digests/ripemd160.dart";
import "package:pointycastle/digests/sha256.dart";

final ONE1 = Uint8List.fromList([1]);
final ZERO1 = Uint8List.fromList([0]);

Uint8List hash160(Uint8List buffer) {
  Uint8List _tmp = new SHA256Digest().process(buffer);
  return new RIPEMD160Digest().process(_tmp);
}

Uint8List hmacSHA512(Uint8List key,Uint8List data) {
  final _tmp = new HMac(new SHA512Digest(), 128)..init(new KeyParameter(key));
  return _tmp.process(data);
}
