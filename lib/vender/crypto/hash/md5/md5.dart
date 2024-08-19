part of 'package:abey_wallet/vender/crypto/hash/hash.dart';

class MD5 implements SerializableHash<SH1State> {
  MD5() {
    reset();
  }

  static List<int> hash(List<int> data) {
    final h = MD5();
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
    savedState.state = List.unmodifiable([
      0x67452301,
      0xefcdab89,
      0x98badcfe,
      0x10325476,
    ]);
    savedState.length = 0;
  }

  static int _ff(int x, int y, int z) {
    return ((x & y) | (~x & z)) & mask32;
  }

  static int _gg(int x, int y, int z) {
    return ((x & z) | (y & ~z)) & mask32;
  }

  static int _hh(int x, int y, int z) {
    return (x ^ y ^ z) & mask32;
  }

  static int _ii(int x, int y, int z) {
    return (y ^ (x | ~z)) & mask32;
  }

  static int _cc(int Function(int, int, int) f, int k, int a, int x, int y,
      int z, int m, int s) {
    return (add32(rotl32(add32(add32(add32(a, f(x, y, z)), m), k), s), x));
  }

  static final List<int> _t = List<int>.generate(64, (i) {
    return ((math.sin(i + 1) * 0x100000000).abs()).toInt();
  });

  static const _s = [
    [7, 12, 17, 22],
    [5, 9, 14, 20],
    [4, 11, 16, 23],
    [6, 10, 15, 21]
  ];

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

    var highBits = lengthInBits ~/ 0x100000000;
    var lowBits = lengthInBits & mask32;
    writeUint32LE(lowBits, _buffer, offset);
    writeUint32LE(highBits, _buffer, offset + 4);
  }

  @override
  int get getBlockSize => 64;

  @override
  int get getDigestLength => 16;

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
        state: List.unmodifiable(_state));
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
    int a = _state[0] | 0;
    int b = _state[1] | 0;
    int c = _state[2] | 0;
    int d = _state[3] | 0;

    a = _cc(_ff, _t[0], a, b, c, d, block[0], _s[0][0]);
    d = _cc(_ff, _t[1], d, a, b, c, block[1], _s[0][1]);
    c = _cc(_ff, _t[2], c, d, a, b, block[2], _s[0][2]);
    b = _cc(_ff, _t[3], b, c, d, a, block[3], _s[0][3]);
    a = _cc(_ff, _t[4], a, b, c, d, block[4], _s[0][0]);
    d = _cc(_ff, _t[5], d, a, b, c, block[5], _s[0][1]);
    c = _cc(_ff, _t[6], c, d, a, b, block[6], _s[0][2]);
    b = _cc(_ff, _t[7], b, c, d, a, block[7], _s[0][3]);
    a = _cc(_ff, _t[8], a, b, c, d, block[8], _s[0][0]);
    d = _cc(_ff, _t[9], d, a, b, c, block[9], _s[0][1]);
    c = _cc(_ff, _t[10], c, d, a, b, block[10], _s[0][2]);
    b = _cc(_ff, _t[11], b, c, d, a, block[11], _s[0][3]);
    a = _cc(_ff, _t[12], a, b, c, d, block[12], _s[0][0]);
    d = _cc(_ff, _t[13], d, a, b, c, block[13], _s[0][1]);
    c = _cc(_ff, _t[14], c, d, a, b, block[14], _s[0][2]);
    b = _cc(_ff, _t[15], b, c, d, a, block[15], _s[0][3]);

    a = _cc(_gg, _t[16], a, b, c, d, block[1], _s[1][0]);
    d = _cc(_gg, _t[17], d, a, b, c, block[6], _s[1][1]);
    c = _cc(_gg, _t[18], c, d, a, b, block[11], _s[1][2]);
    b = _cc(_gg, _t[19], b, c, d, a, block[0], _s[1][3]);
    a = _cc(_gg, _t[20], a, b, c, d, block[5], _s[1][0]);
    d = _cc(_gg, _t[21], d, a, b, c, block[10], _s[1][1]);
    c = _cc(_gg, _t[22], c, d, a, b, block[15], _s[1][2]);
    b = _cc(_gg, _t[23], b, c, d, a, block[4], _s[1][3]);
    a = _cc(_gg, _t[24], a, b, c, d, block[9], _s[1][0]);
    d = _cc(_gg, _t[25], d, a, b, c, block[14], _s[1][1]);
    c = _cc(_gg, _t[26], c, d, a, b, block[3], _s[1][2]);
    b = _cc(_gg, _t[27], b, c, d, a, block[8], _s[1][3]);
    a = _cc(_gg, _t[28], a, b, c, d, block[13], _s[1][0]);
    d = _cc(_gg, _t[29], d, a, b, c, block[2], _s[1][1]);
    c = _cc(_gg, _t[30], c, d, a, b, block[7], _s[1][2]);
    b = _cc(_gg, _t[31], b, c, d, a, block[12], _s[1][3]);

    a = _cc(_hh, _t[32], a, b, c, d, block[5], _s[2][0]);
    d = _cc(_hh, _t[33], d, a, b, c, block[8], _s[2][1]);
    c = _cc(_hh, _t[34], c, d, a, b, block[11], _s[2][2]);
    b = _cc(_hh, _t[35], b, c, d, a, block[14], _s[2][3]);
    a = _cc(_hh, _t[36], a, b, c, d, block[1], _s[2][0]);
    d = _cc(_hh, _t[37], d, a, b, c, block[4], _s[2][1]);
    c = _cc(_hh, _t[38], c, d, a, b, block[7], _s[2][2]);
    b = _cc(_hh, _t[39], b, c, d, a, block[10], _s[2][3]);
    a = _cc(_hh, _t[40], a, b, c, d, block[13], _s[2][0]);
    d = _cc(_hh, _t[41], d, a, b, c, block[0], _s[2][1]);
    c = _cc(_hh, _t[42], c, d, a, b, block[3], _s[2][2]);
    b = _cc(_hh, _t[43], b, c, d, a, block[6], _s[2][3]);
    a = _cc(_hh, _t[44], a, b, c, d, block[9], _s[2][0]);
    d = _cc(_hh, _t[45], d, a, b, c, block[12], _s[2][1]);
    c = _cc(_hh, _t[46], c, d, a, b, block[15], _s[2][2]);
    b = _cc(_hh, _t[47], b, c, d, a, block[2], _s[2][3]);

    a = _cc(_ii, _t[48], a, b, c, d, block[0], _s[3][0]);
    d = _cc(_ii, _t[49], d, a, b, c, block[7], _s[3][1]);
    c = _cc(_ii, _t[50], c, d, a, b, block[14], _s[3][2]);
    b = _cc(_ii, _t[51], b, c, d, a, block[5], _s[3][3]);
    a = _cc(_ii, _t[52], a, b, c, d, block[12], _s[3][0]);
    d = _cc(_ii, _t[53], d, a, b, c, block[3], _s[3][1]);
    c = _cc(_ii, _t[54], c, d, a, b, block[10], _s[3][2]);
    b = _cc(_ii, _t[55], b, c, d, a, block[1], _s[3][3]);
    a = _cc(_ii, _t[56], a, b, c, d, block[8], _s[3][0]);
    d = _cc(_ii, _t[57], d, a, b, c, block[15], _s[3][1]);
    c = _cc(_ii, _t[58], c, d, a, b, block[6], _s[3][2]);
    b = _cc(_ii, _t[59], b, c, d, a, block[13], _s[3][3]);
    a = _cc(_ii, _t[60], a, b, c, d, block[4], _s[3][0]);
    d = _cc(_ii, _t[61], d, a, b, c, block[11], _s[3][1]);
    c = _cc(_ii, _t[62], c, d, a, b, block[2], _s[3][2]);
    b = _cc(_ii, _t[63], b, c, d, a, block[9], _s[3][3]);

    _state[0] = add32(_state[0], a);
    _state[1] = add32(_state[1], b);
    _state[2] = add32(_state[2], c);
    _state[3] = add32(_state[3], d);
  }
}
