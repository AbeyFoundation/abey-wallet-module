part of 'package:abey_wallet/vender/crypto/hash/hash.dart';

class SHA1 implements SerializableHash<SH1State> {
  SHA1() {
    reset();
  }
  final _buffer = List<int>.empty(growable: true);
  int _lengthInBytes = 0;

  final List<int> _temp = List<int>.filled(80, 0);
  final List<int> _estate = List<int>.filled(5, 0);
  final List<int> _currentChunk = List<int>.filled(16, 0);

  bool _finished = false;

  @override
  void clean() {
    zero(_temp);
    zero(_estate);
    zero(_currentChunk);
    _buffer.clear();
    reset();
  }

  void _init() {
    _estate[0] = 0x67452301;
    _estate[1] = 0xEFCDAB89;
    _estate[2] = 0x98BADCFE;
    _estate[3] = 0x10325476;
    _estate[4] = 0xC3D2E1F0;
  }

  @override
  void cleanSavedState(SH1State savedState) {
    savedState.buffer = List.empty();
    savedState.state = List<int>.from([
      0x67452301,
      0xEFCDAB89,
      0x98BADCFE,
      0x10325476,
      0xC3D2E1F0,
    ], growable: false);
    savedState.length = 0;
  }

  @override
  List<int> digest() {
    final out = List<int>.filled(getDigestLength, 0);
    finish(out);
    return out;
  }

  @override
  Hash finish(List<int> out) {
    if (!_finished) {
      _finalize();
      _iterate();
      _finished = true;
    }
    for (var i = 0; i < _estate.length; i++) {
      writeUint32BE(_estate[i], out, i * 4);
    }
    return this;
  }

  void _finalize() {
    _buffer.add(0x80);

    final contentsLength = _lengthInBytes + 1 + 8;
    final finalizedLength = (contentsLength + getBlockSize - 1) & -getBlockSize;
    for (var i = 0; i < finalizedLength - contentsLength; i++) {
      _buffer.add(0);
    }

    var lengthInBits = _lengthInBytes * 8;
    final offset = _buffer.length;

    _buffer.addAll(List<int>.filled(8, 0));
    var highBits = lengthInBits ~/ 0x100000000;
    var lowBits = lengthInBits & mask32;
    writeUint32BE(highBits, _buffer, offset);
    writeUint32BE(lowBits, _buffer, offset + 4);
  }

  void _proccess(List<int> chunk) {
    assert(chunk.length == 16);

    var a = _estate[0];
    var b = _estate[1];
    var c = _estate[2];
    var d = _estate[3];
    var e = _estate[4];

    for (var i = 0; i < 80; i++) {
      if (i < 16) {
        _temp[i] = chunk[i];
      } else {
        _temp[i] = rotl32(
            _temp[i - 3] ^ _temp[i - 8] ^ _temp[i - 14] ^ _temp[i - 16], 1);
      }

      var newA = add32(add32(rotl32(a, 5), e), _temp[i]);
      if (i < 20) {
        newA = add32(add32(newA, (b & c) | (~b & d)), 0x5A827999);
      } else if (i < 40) {
        newA = add32(add32(newA, b ^ c ^ d), 0x6ED9EBA1);
      } else if (i < 60) {
        newA = add32(add32(newA, (b & c) | (b & d) | (c & d)), 0x8F1BBCDC);
      } else {
        newA = add32(add32(newA, b ^ c ^ d), 0xCA62C1D6);
      }

      e = d;
      d = c;
      c = rotl32(b, 30);
      b = a;
      a = newA & mask32;
    }

    _estate[0] = add32(a, _estate[0]);
    _estate[1] = add32(b, _estate[1]);
    _estate[2] = add32(c, _estate[2]);
    _estate[3] = add32(d, _estate[3]);
    _estate[4] = add32(e, _estate[4]);
  }

  @override
  int get getBlockSize => 64;

  @override
  int get getDigestLength => _estate.length * 4;

  @override
  Hash reset() {
    _init();
    _finished = false;
    _lengthInBytes = 0;
    return this;
  }

  @override
  SerializableHash restoreState(SH1State savedState) {
    _buffer.clear();
    _buffer.addAll(savedState.buffer);
    _estate.setAll(0, savedState.state);
    _lengthInBytes = savedState.length;
    _iterate();
    _finished = false;
    return this;
  }

  @override
  SH1State saveState() {
    return SH1State(
        buffer: List<int>.from(_buffer.toList()),
        length: _lengthInBytes,
        state: List<int>.from(_estate, growable: false));
  }

  @override
  Hash update(List<int> data) {
    if (_finished) {
      throw Exception(
          "SHA512: can't update because hash was finished.");
    }
    _lengthInBytes += data.length;
    _buffer.addAll(BytesUtil.toBytes(data));
    _iterate();
    return this;
  }

  void _iterate() {
    var pendingDataChunks = _buffer.length ~/ getBlockSize;
    for (var i = 0; i < pendingDataChunks; i++) {
      for (var j = 0; j < _currentChunk.length; j++) {
        _currentChunk[j] = readUint32BE(_buffer, i * getBlockSize + j * 4);
      }
      _proccess(_currentChunk);
    }
    _buffer.removeRange(0, pendingDataChunks * getBlockSize);
  }

  static List<int> hash(List<int> data) {
    final h = SHA1();
    h.update(data);
    final digest = h.digest();
    h.clean();
    return digest;
  }
}

class SH1State implements HashState {
  SH1State({required this.buffer, required this.length, required this.state});
  List<int> buffer;
  int length;
  List<int> state;
}
