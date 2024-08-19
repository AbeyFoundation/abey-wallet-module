part of 'package:abey_wallet/vender/crypto/hash/hash.dart';

class MD4 implements SerializableHash<SH1State> {
  MD4() {
    reset();
  }

  static List<int> hash(List<int> data) {
    final h = MD4();
    h.update(data);
    final digest = h.digest();
    h.clean();
    return digest;
  }

  final _buffer = List<int>.empty(growable: true);
  int _lengthInBytes = 0;

  final List<int> _state = List<int>.filled(4, 0);

  final List<int> _currentChunk = List<int>.filled(16, 0);

  bool _finished = false;

  @override
  int get getBlockSize => 64;

  @override
  int get getDigestLength => 16;

  @override
  void clean() {
    zero(_state);
    zero(_currentChunk);
    _buffer.clear();
    reset();
  }

  void _init() {
    _state[0] = 0x67452301;
    _state[1] = 0xefcdab89;
    _state[2] = 0x98badcfe;
    _state[3] = 0x10325476;
  }

  @override
  void cleanSavedState(SH1State savedState) {
    savedState.buffer = List.empty();
    savedState.state = List<int>.from([
      0x67452301,
      0xefcdab89,
      0x98badcfe,
      0x10325476,
    ], growable: false);
    savedState.length = 0;
  }

  static int _ff(int x, int y, int z) {
    return (x & y) | ((~x) & z);
  }

  static int _gg(int x, int y, int z) {
    return (x & y) | (x & z) | (y & z);
  }

  static int _hh(int x, int y, int z) {
    return x ^ y ^ z;
  }

  static int _cc(int Function(int, int, int) f, int k, int a, int x, int y,
      int z, int m, int s) {
    return rotl32((a + f(x, y, z) + m + k), s);
  }

  static const _s = [
    [3, 7, 11, 19],
    [3, 5, 9, 13],
    [3, 9, 11, 15]
  ];

  static const _f = 0x00000000;

  static const _g = 0x5a827999;

  static const _h = 0x6ed9eba1;

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
    for (var i = 0; i < _state.length; i++) {
      writeUint32LE(_state[i], out, i * 4);
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
    var highBits = lengthInBits ~/ 0x100000000; // >> 32
    var lowBits = lengthInBits & mask32;
    writeUint32LE(lowBits, _buffer, offset);
    writeUint32LE(highBits, _buffer, offset + 4);
  }

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
    _state.setAll(0, savedState.state);
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
        state: List<int>.from(_state, growable: false));
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
        _currentChunk[j] = readUint32LE(_buffer, i * getBlockSize + j * 4);
      }
      _proccess(_currentChunk);
    }
    _buffer.removeRange(0, pendingDataChunks * getBlockSize);
  }

  void _proccess(List<int> block) {
    int a = _state[0];
    int b = _state[1];
    int c = _state[2];
    int d = _state[3];

    a = _cc(_ff, _f, a, b, c, d, block[0], _s[0][0]);
    d = _cc(_ff, _f, d, a, b, c, block[1], _s[0][1]);
    c = _cc(_ff, _f, c, d, a, b, block[2], _s[0][2]);
    b = _cc(_ff, _f, b, c, d, a, block[3], _s[0][3]);
    a = _cc(_ff, _f, a, b, c, d, block[4], _s[0][0]);
    d = _cc(_ff, _f, d, a, b, c, block[5], _s[0][1]);
    c = _cc(_ff, _f, c, d, a, b, block[6], _s[0][2]);
    b = _cc(_ff, _f, b, c, d, a, block[7], _s[0][3]);
    a = _cc(_ff, _f, a, b, c, d, block[8], _s[0][0]);
    d = _cc(_ff, _f, d, a, b, c, block[9], _s[0][1]);
    c = _cc(_ff, _f, c, d, a, b, block[10], _s[0][2]);
    b = _cc(_ff, _f, b, c, d, a, block[11], _s[0][3]);
    a = _cc(_ff, _f, a, b, c, d, block[12], _s[0][0]);
    d = _cc(_ff, _f, d, a, b, c, block[13], _s[0][1]);
    c = _cc(_ff, _f, c, d, a, b, block[14], _s[0][2]);
    b = _cc(_ff, _f, b, c, d, a, block[15], _s[0][3]);

    a = _cc(_gg, _g, a, b, c, d, block[0], _s[1][0]);
    d = _cc(_gg, _g, d, a, b, c, block[4], _s[1][1]);
    c = _cc(_gg, _g, c, d, a, b, block[8], _s[1][2]);
    b = _cc(_gg, _g, b, c, d, a, block[12], _s[1][3]);
    a = _cc(_gg, _g, a, b, c, d, block[1], _s[1][0]);
    d = _cc(_gg, _g, d, a, b, c, block[5], _s[1][1]);
    c = _cc(_gg, _g, c, d, a, b, block[9], _s[1][2]);
    b = _cc(_gg, _g, b, c, d, a, block[13], _s[1][3]);
    a = _cc(_gg, _g, a, b, c, d, block[2], _s[1][0]);
    d = _cc(_gg, _g, d, a, b, c, block[6], _s[1][1]);
    c = _cc(_gg, _g, c, d, a, b, block[10], _s[1][2]);
    b = _cc(_gg, _g, b, c, d, a, block[14], _s[1][3]);
    a = _cc(_gg, _g, a, b, c, d, block[3], _s[1][0]);
    d = _cc(_gg, _g, d, a, b, c, block[7], _s[1][1]);
    c = _cc(_gg, _g, c, d, a, b, block[11], _s[1][2]);
    b = _cc(_gg, _g, b, c, d, a, block[15], _s[1][3]);

    a = _cc(_hh, _h, a, b, c, d, block[0], _s[2][0]);
    d = _cc(_hh, _h, d, a, b, c, block[8], _s[2][1]);
    c = _cc(_hh, _h, c, d, a, b, block[4], _s[2][2]);
    b = _cc(_hh, _h, b, c, d, a, block[12], _s[2][3]);
    a = _cc(_hh, _h, a, b, c, d, block[2], _s[2][0]);
    d = _cc(_hh, _h, d, a, b, c, block[10], _s[2][1]);
    c = _cc(_hh, _h, c, d, a, b, block[6], _s[2][2]);
    b = _cc(_hh, _h, b, c, d, a, block[14], _s[2][3]);
    a = _cc(_hh, _h, a, b, c, d, block[1], _s[2][0]);
    d = _cc(_hh, _h, d, a, b, c, block[9], _s[2][1]);
    c = _cc(_hh, _h, c, d, a, b, block[5], _s[2][2]);
    b = _cc(_hh, _h, b, c, d, a, block[13], _s[2][3]);
    a = _cc(_hh, _h, a, b, c, d, block[3], _s[2][0]);
    d = _cc(_hh, _h, d, a, b, c, block[11], _s[2][1]);
    c = _cc(_hh, _h, c, d, a, b, block[7], _s[2][2]);
    b = _cc(_hh, _h, b, c, d, a, block[15], _s[2][3]);

    _state[0] = add32(_state[0], a);
    _state[1] = add32(_state[1], b);
    _state[2] = add32(_state[2], c);
    _state[3] = add32(_state[3], d);
  }
}
