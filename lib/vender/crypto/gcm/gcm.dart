import 'package:abey_wallet/utils/binary_util.dart';
import 'package:abey_wallet/utils/bytes_util.dart';
import 'package:abey_wallet/vender/crypto/aead/aead.dart';
import 'package:abey_wallet/vender/crypto/blockcipher/blockcipher.dart';
import 'package:abey_wallet/vender/crypto/ctr/ctr.dart';

import 'dart:math' as math;

class GCM implements AEAD {
  @override
  final int nonceLength = 12;
  @override
  final int tagLength = 16;

  late List<int> _subkey;
  late BlockCipher _cipher;

  GCM(BlockCipher cipher) {
    if (cipher.blockSize != 16) {
      throw Exception("GCM supports only 16-byte block cipher");
    }
    _cipher = cipher;
    _subkey = List<int>.filled(_cipher.blockSize, 0);
    _cipher.encryptBlock(List<int>.filled(_cipher.blockSize, 0), _subkey);
  }

  @override
  List<int> encrypt(List<int> nonce, List<int> plaintext, {List<int>? associatedData, List<int>? dst}) {
    if (nonce.length != nonceLength) {
      throw Exception("GCM: incorrect nonce length");
    }
    final blockSize = _cipher.blockSize;
    final resultLength = plaintext.length + tagLength;
    List<int> result = dst ?? List<int>.filled(resultLength, 0);
    if (result.length != resultLength) {
      throw Exception("GCM: incorrect destination length");
    }
    final counter = List<int>.filled(blockSize, 0);
    counter.setAll(0, nonce);
    counter[blockSize - 1] = 1;
    final tagMask = List<int>.filled(blockSize, 0);
    _cipher.encryptBlock(counter, tagMask);
    counter[blockSize - 1] = 2;
    final ctr = CTR(_cipher, counter);
    ctr.streamXOR(plaintext, result);
    ctr.clean();
    final calculatedTag = List<int>.filled(tagLength, 0);
    final cipherText = result.sublist(0, result.length - tagLength);
    _authenticate(calculatedTag, tagMask, cipherText, associatedData);
    result.setRange(result.length - tagLength, result.length, calculatedTag);
    zero(counter);
    zero(tagMask);
    return result;
  }

  @override
  List<int>? decrypt(List<int> nonce, List<int> sealed, {List<int>? associatedData, List<int>? dst}) {
    if (nonce.length != nonceLength) {
      throw Exception("GCM: incorrect nonce length");
    }
    if (sealed.length < tagLength) {
      return null;
    }
    final blockSize = _cipher.blockSize;
    final counter = List<int>.filled(blockSize, 0);
    counter.setAll(0, nonce);
    counter[blockSize - 1] = 1;
    final tagMask = List<int>.filled(blockSize, 0);
    _cipher.encryptBlock(counter, tagMask);
    counter[blockSize - 1] = 2;
    final calculatedTag = List<int>.filled(tagLength, 0);
    _authenticate(calculatedTag, tagMask, sealed.sublist(0, sealed.length - tagLength), associatedData);
    if (!BytesUtil.bytesEqual(calculatedTag, sealed.sublist(sealed.length - tagLength))) {
      return null;
    }
    final resultLength = sealed.length - tagLength;
    List<int> result = dst ?? List<int>.filled(resultLength, 0);
    if (result.length != resultLength) {
      throw Exception("GCM: incorrect destination length");
    }
    final ctr = CTR(_cipher, counter);
    ctr.streamXOR(sealed.sublist(0, sealed.length - tagLength), result);
    ctr.clean();
    zero(counter);
    zero(tagMask);
    return result;
  }

  @override
  GCM clean() {
    zero(_subkey);
    return this;
  }

  _authenticate(List<int> tagOut, List<int> tagMask, List<int> ciphertext, [List<int>? associatedData]) {
    final blockSize = _cipher.blockSize;
    if (associatedData != null) {
      for (int i = 0; i < associatedData.length; i += blockSize) {
        final slice = associatedData.sublist(i, math.min(i + blockSize, associatedData.length));
        _addmul(tagOut, slice, _subkey);
      }
    }
    for (int i = 0; i < ciphertext.length; i += blockSize) {
      final slice = ciphertext.sublist(i, math.min(i + blockSize, ciphertext.length));
      _addmul(tagOut, slice, _subkey);
    }
    final lengthsBlock = List<int>.filled(blockSize, 0);
    if (associatedData != null) {
      _writeBitLength(associatedData.length, lengthsBlock, 0);
    }
    _writeBitLength(ciphertext.length, lengthsBlock, 8);
    _addmul(tagOut, lengthsBlock, _subkey);
    for (var i = 0; i < tagMask.length; i++) {
      tagOut[i] ^= tagMask[i];
    }
    zero(lengthsBlock);
  }

  void _writeBitLength(int byteLength, List<int> dst, [int offset = 0]) {
    final hi = (byteLength ~/ 0x20000000);
    final lo = byteLength << 3;
    writeUint32BE(hi, dst, offset + 0);
    writeUint32BE(lo, dst, offset + 4);
  }

  void _addmul(List<int> a, List<int> x, List<int> y) {
    for (int i = 0; i < x.length; i++) {
      a[i] ^= x[i];
    }

    int v0 = (y[3] | y[2] << 8 | y[1] << 16 | y[0] << 24);
    int v1 = (y[7] | y[6] << 8 | y[5] << 16 | y[4] << 24);
    int v2 = (y[11] | y[10] << 8 | y[9] << 16 | y[8] << 24);
    int v3 = (y[15] | y[14] << 8 | y[13] << 16 | y[12] << 24);
    int z0 = 0, z1 = 0, z2 = 0, z3 = 0;

    for (var i = 0; i < 128; i++) {
      int mask = ~((((-(a[i >> 3] & (1 << (~i & 7)))) >> 31) & 1) - 1);
      z0 ^= v0 & mask;
      z1 ^= v1 & mask;
      z2 ^= v2 & mask;
      z3 ^= v3 & mask;

      mask = ~((v3 & 1) - 1);
      v3 = ((v2 << 31) & mask32) | ((v3 >> 1) & mask32);
      v2 = ((v1 << 31) & mask32) | ((v2 >> 1) & mask32);
      v1 = ((v0 << 31) & mask32) | ((v1 >> 1) & mask32);
      v0 = ((v0 >> 1) & mask32) ^ (0xe1000000 & mask);
    }
    writeUint32BE(z0, a, 0);
    writeUint32BE(z1, a, 4);
    writeUint32BE(z2, a, 8);
    writeUint32BE(z3, a, 12);
  }
}
