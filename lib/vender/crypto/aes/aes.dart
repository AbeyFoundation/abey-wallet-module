import 'package:abey_wallet/utils/binary_util.dart';
import 'package:abey_wallet/vender/crypto/blockcipher/blockcipher.dart';
import 'aes_lib.dart' as aes_lib;

class AES implements BlockCipher {
  static final aes_lib.AESLib _lib = aes_lib.AESLib();

  @override
  final blockSize = 16;
  late int _keyLen;
  List<int>? _encKey;
  List<int>? _decKey;

  AES(List<int> key, [bool noDecryption = false]) {
    _keyLen = key.length;
    setKey(key, noDecryption);
  }

  @override
  AES setKey(List<int> key, [bool noDecryption = false]) {
    if (key.length != 16 && key.length != 24 && key.length != 32) {
      throw Exception("AES: wrong key size (must be 16, 24, or 32)");
    }
    if (_keyLen != key.length) {
      throw Exception("AES: initialized with different key size");
    }
    _encKey ??= List<int>.filled(key.length + 28, 0, growable: false);
    if (noDecryption) {
      if (_decKey != null) {
        zero(_decKey!);
        _decKey = null;
      }
    } else {
      _decKey ??= List<int>.filled(key.length + 28, 0, growable: false);
    }
    _lib.expandKey(key, _encKey!, _decKey);
    return this;
  }

  @override
  AES clean() {
    if (_encKey != null) {
      zero(_encKey!);
      _encKey = null;
    }
    if (_decKey != null) {
      zero(_decKey!);
      _decKey = null;
    }
    return this;
  }

  @override
  List<int> encryptBlock(List<int> src, [List<int>? dst]) {
    final out = dst ?? List<int>.filled(blockSize, 0);
    if (src.length != blockSize) {
      throw Exception("AES: invalid source block size");
    }
    if (out.length != blockSize) {
      throw Exception("AES: invalid destination block size");
    }
    if (_encKey == null) {
      throw Exception("AES: encryption key is not available");
    }
    _lib.encryptBlock(_encKey!, src, out);
    return out;
  }

  @override
  List<int> decryptBlock(List<int> src, [List<int>? dst]) {
    final out = dst ?? List<int>.filled(blockSize, 0);
    if (src.length != blockSize) {
      throw Exception("AES: invaiid source block size");
    }
    if (out.length != blockSize) {
      throw Exception("AES: invalid destination block size");
    }
    if (_decKey == null) {
      throw Exception("AES: decrypting with an instance created with noDecryption option");
    } else {
      _lib.decryptBlock(_decKey!, src, out);
    }
    return out;
  }
}
