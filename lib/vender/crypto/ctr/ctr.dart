import 'package:abey_wallet/utils/binary_util.dart';
import 'package:abey_wallet/vender/crypto/blockcipher/blockcipher.dart';

class CTR {
  late final List<int> _counter;
  late final List<int> _buffer;
  int _bufpos = 0;
  BlockCipher? _cipher;
  int? get blockSize => _cipher?.blockSize;

  CTR(BlockCipher cipher, List<int> iv) {
    _counter = List<int>.filled(cipher.blockSize, 0);
    _buffer = List<int>.filled(cipher.blockSize, 0);
    setCipher(cipher, iv);
  }

  CTR setCipher(BlockCipher cipher, List<int>? iv) {
    _cipher = null;

    if (iv != null && iv.length != _counter.length) {
      throw Exception("CTR: iv length must be equal to cipher block size");
    }
    _cipher = cipher;

    if (iv != null) {
      _counter.setAll(0, iv);
    }
    _bufpos = _buffer.length;
    return this;
  }

  CTR clean() {
    zero(_buffer);
    zero(_counter);
    _bufpos = _buffer.length;
    _cipher = null;
    return this;
  }

  void _fillBuffer() {
    _cipher!.encryptBlock(_counter, _buffer);
    _bufpos = 0;
    _incrementCounter(_counter);
  }

  void streamXOR(List<int> src, List<int> dst) {
    for (var i = 0; i < src.length; i++) {
      if (_bufpos == _buffer.length) {
        _fillBuffer();
      }
      dst[i] = (src[i] & mask8) ^ _buffer[_bufpos++];
    }
  }

  void stream(List<int> dst) {
    for (var i = 0; i < dst.length; i++) {
      if (_bufpos == _buffer.length) {
        _fillBuffer();
      }
      dst[i] = _buffer[_bufpos++];
    }
  }
}

void _incrementCounter(List<int> counter) {
  var carry = 1;
  for (var i = counter.length - 1; i >= 0; i--) {
    carry = carry + (counter[i] & mask8);
    counter[i] = carry & mask8;
    carry >>= 8;
  }
  if (carry > 0) {
    throw Exception("CTR: counter overflow");
  }
}
