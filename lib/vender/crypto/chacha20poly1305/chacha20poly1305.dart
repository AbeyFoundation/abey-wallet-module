import 'package:abey_wallet/utils/binary_util.dart';
import 'package:abey_wallet/utils/bytes_util.dart';
import 'package:abey_wallet/vender/crypto/aead/aead.dart';
import 'package:abey_wallet/vender/crypto/chacha/chacha.dart';
import 'package:abey_wallet/vender/crypto/poly1305/poly1305.dart';

const int _nonceLength = 12;
const int _tagLength = 16;
const int _keyLength = 32;

class ChaCha20Poly1305 implements AEAD {
  @override
  final int nonceLength = _nonceLength;

  @override
  final int tagLength = _tagLength;

  late List<int> _key;

  ChaCha20Poly1305(List<int> key) {
    if (key.length != _keyLength) {
      throw Exception("ChaCha20Poly1305 needs a 32-byte key");
    }
    _key = BytesUtil.toBytes(key);
  }

  @override
  List<int> encrypt(List<int> nonce, List<int> plaintext, {List<int>? associatedData, List<int>? dst}) {
    if (nonce.length > 16) {
      throw Exception("ChaCha20Poly1305: incorrect nonce length");
    }
    final counter = List<int>.filled(16, 0);
    counter.setRange(counter.length - nonce.length, counter.length, BytesUtil.toBytes(nonce));
    final authKey = List<int>.filled(32, 0);
    ChaCha20.stream(_key, counter, authKey, nonceInplaceCounterLength: 4);
    final resultLength = plaintext.length + tagLength;
    List<int> result = dst ?? List<int>.filled(resultLength, 0);
    if (result.length != resultLength) {
      throw Exception("ChaCha20Poly1305: incorrect destination length");
    }
    ChaCha20.streamXOR(_key, counter, BytesUtil.toBytes(plaintext), result, nonceInplaceCounterLength: 4);
    final calculatedTag = List<int>.filled(tagLength, 0);
    final cipherText = result.sublist(0, result.length - tagLength);
    _authenticate(calculatedTag, authKey, cipherText, associatedData);
    result.setRange(result.length - tagLength, result.length, calculatedTag);
    zero(counter);
    return result;
  }

  @override
  List<int>? decrypt(List<int> nonce, List<int> sealed, {List<int>? associatedData, List<int>? dst}) {
    if (nonce.length > 16) {
      throw Exception("ChaCha20Poly1305: incorrect nonce length");
    }
    if (sealed.length < tagLength) {
      return null;
    }
    final counter = List<int>.filled(16, 0);
    counter.setRange(counter.length - nonce.length, counter.length, nonce);
    final authKey = List<int>.filled(32, 0);
    ChaCha20.stream(_key, counter, authKey, nonceInplaceCounterLength: 4);
    final calculatedTag = List<int>.filled(tagLength, 0);
    _authenticate(calculatedTag, authKey, sealed.sublist(0, sealed.length - tagLength), associatedData);
    if (!BytesUtil.bytesEqual(calculatedTag, sealed.sublist(sealed.length - tagLength))) {
      return null;
    }
    final resultLength = sealed.length - tagLength;
    List<int> result = dst ?? List<int>.filled(resultLength, 0);
    if (result.length != resultLength) {
      throw Exception("ChaCha20Poly1305: incorrect destination length");
    }
    ChaCha20.streamXOR(_key, counter, sealed.sublist(0, sealed.length - tagLength), result, nonceInplaceCounterLength: 4);
    zero(counter);
    return result;
  }

  @override
  ChaCha20Poly1305 clean() {
    zero(_key);
    return this;
  }

  void _authenticate(List<int> tagOut, List<int> authKey, List<int> ciphertext, List<int>? associatedData) {
    final h = Poly1305(authKey);
    if (associatedData != null) {
      h.update(associatedData);
      if (associatedData.length % 16 > 0) {
        h.update(List<int>.filled(16 - (associatedData.length % 16), 0));
      }
    }
    h.update(ciphertext);
    if (ciphertext.length % 16 > 0) {
      h.update(List<int>.filled(16 - (ciphertext.length % 16), 0));
    }
    final length = List<int>.filled(8, 0);
    if (associatedData != null) {
      writeUint64LE(associatedData.length, length);
    }
    h.update(length);
    writeUint64LE(ciphertext.length, length);
    h.update(length);
    final tag = h.digest();
    for (var i = 0; i < tag.length; i++) {
      tagOut[i] = tag[i];
    }
    h.clean();
    zero(tag);
    zero(length);
  }
}
