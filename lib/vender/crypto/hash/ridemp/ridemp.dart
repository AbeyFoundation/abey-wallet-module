part of 'package:abey_wallet/vender/crypto/hash/hash.dart';

class RIPEMD320 extends _RIPEMD {
  RIPEMD320() : super(40 ~/ 4);

  static List<int> hash(List<int> data) {
    final h = RIPEMD320();
    h.update(data);
    final digest = h.digest();
    h.clean();
    return digest;
  }
}

class RIPEMD256 extends _RIPEMD {
  RIPEMD256() : super(32 ~/ 4);

  static List<int> hash(List<int> data) {
    final h = RIPEMD256();
    h.update(data);
    final digest = h.digest();
    h.clean();
    return digest;
  }
}

class RIPEMD160 extends _RIPEMD {
  RIPEMD160() : super(20 ~/ 4);

  static List<int> hash(List<int> data) {
    final h = RIPEMD160();
    h.update(data);
    final digest = h.digest();
    h.clean();
    return digest;
  }
}

class RIPEMD128 extends _RIPEMD {
  RIPEMD128() : super(16 ~/ 4);

  static List<int> hash(List<int> data) {
    final h = RIPEMD128();
    h.update(data);
    final digest = h.digest();
    h.clean();
    return digest;
  }
}

class _RIPEMD implements SerializableHash<SH1State> {
  _RIPEMD(int length) {
    _state = List<int>.filled(length, 0);
    reset();
  }

  final _buffer = List<int>.empty(growable: true);
  int _lengthInBytes = 0;
  late final List<int> _state;
  final List<int> _currentChunk = List.filled(16, 0);

  bool _finished = false;

  @override
  void clean() {
    zero(_state);
    zero(_currentChunk);
    _buffer.clear();
    reset();
  }

  void _init() {
    final state = _RidempUtils.readState(getDigestLength);
    _state.setAll(0, state);
  }

  @override
  void cleanSavedState(SH1State savedState) {
    savedState.buffer = List.empty();
    final state = _RidempUtils.readState(getDigestLength);
    savedState.state = state;
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
  int get getDigestLength => _state.length * 4;

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

  void _proccess(List<int> chunk) {
    switch (getDigestLength) {
      case 16:
        return _proccess128(chunk);
      case 20:
        return _proccess160(chunk);
      case 32:
        return _proccess256(chunk);
      default:
        return _proccess320(chunk);
    }
  }

  void _proccess128(List<int> chunk) {
    assert(chunk.length == 16);

    int al = _state[0];
    int bl = _state[1];
    int cl = _state[2];
    int dl = _state[3];
    int ar = al;
    int br = bl;
    int cr = cl;
    int dr = dl;

    for (int i = 0; i < 64; i++) {
      int t = add32(al, chunk[_RidempUtils.zl[i]]);
      t = add32(t, _RidempUtils.T(i, bl, cl, dl));
      t = rotl32(t, _RidempUtils.sl[i]);
      al = dl;
      dl = cl;
      cl = bl;
      bl = t;

      t = add32(ar, chunk[_RidempUtils.zr[i]]);
      t = add32(t, _RidempUtils.t64(i, br, cr, dr));
      t = rotl32(t, _RidempUtils.sr[i]);
      ar = dr;
      dr = cr;
      cr = br;
      br = t;
    }

    int t = add32(add32(_state[1], cl), dr);
    _state[1] = add32(add32(_state[2], dl), ar);
    _state[2] = add32(add32(_state[3], al), br);

    _state[3] = add32(add32(_state[0], bl), cr);

    _state[0] = t;
  }

  void _proccess320(List<int> chunk) {
    assert(chunk.length == 16);
    int al = _state[0];
    int bl = _state[1];
    int cl = _state[2];
    int dl = _state[3];
    int el = _state[4];
    int ar = _state[5];
    int br = _state[6];
    int cr = _state[7];
    int dr = _state[8];
    int er = _state[9];

    for (int i = 0; i < 80; i++) {
      int t = add32(al, chunk[_RidempUtils.zl[i]]);
      t = add32(t, _RidempUtils.T(i, bl, cl, dl));
      t = rotl32(t, _RidempUtils.sl[i]);
      t = add32(t, el);
      al = el;
      el = dl;
      dl = rotl32(cl, 10);
      cl = bl;
      bl = t;

      t = add32(ar, chunk[_RidempUtils.zr[i]]);
      t = add32(t, _RidempUtils.t80(i, br, cr, dr));
      t = rotl32(t, _RidempUtils.sr[i]);
      t = add32(t, er);
      ar = er;
      er = dr;
      dr = rotl32(cr, 10);
      cr = br;
      br = t;

      switch (i) {
        case 15:
          int temp = bl;
          bl = br;
          br = temp;
          break;
        case 31:
          int temp = dl;
          dl = dr;
          dr = temp;
          break;
        case 47:
          int temp = al;
          al = ar;
          ar = temp;
          break;
        case 63:
          int temp = cl;
          cl = cr;
          cr = temp;
          break;
        case 79:
          int temp = el;
          el = er;
          er = temp;
          break;
      }
    }

    _state[0] = add32(_state[0], al);
    _state[1] = add32(_state[1], bl);
    _state[2] = add32(_state[2], cl);
    _state[3] = add32(_state[3], dl);
    _state[4] = add32(_state[4], el);
    _state[5] = add32(_state[5], ar);
    _state[6] = add32(_state[6], br);
    _state[7] = add32(_state[7], cr);
    _state[8] = add32(_state[8], dr);
    _state[9] = add32(_state[9], er);
  }

  void _proccess256(List<int> chunk) {
    assert(chunk.length == 16);

    int al = _state[0];
    int bl = _state[1];
    int cl = _state[2];
    int dl = _state[3];
    int ar = _state[4];
    int br = _state[5];
    int cr = _state[6];
    int dr = _state[7];

    for (int i = 0; i < 64; i++) {
      int t = add32(al, chunk[_RidempUtils.zl[i]]);
      t = add32(t, _RidempUtils.T(i, bl, cl, dl));
      t = rotl32(t, _RidempUtils.sl[i]);
      al = dl;
      dl = cl;
      cl = bl;
      bl = t;

      t = add32(ar, chunk[_RidempUtils.zr[i]]);
      t = add32(t, _RidempUtils.t64(i, br, cr, dr));
      t = rotl32(t, _RidempUtils.sr[i]);
      ar = dr;
      dr = cr;
      cr = br;
      br = t;

      switch (i) {
        case 15:
          int temp = al;
          al = ar;
          ar = temp;
          break;
        case 31:
          int temp = bl;
          bl = br;
          br = temp;
          break;
        case 47:
          int temp = cl;
          cl = cr;
          cr = temp;
          break;
        case 63:
          int temp = dl;
          dl = dr;
          dr = temp;
          break;
      }
    }

    _state[0] = add32(_state[0], al);
    _state[1] = add32(_state[1], bl);
    _state[2] = add32(_state[2], cl);
    _state[3] = add32(_state[3], dl);
    _state[4] = add32(_state[4], ar);
    _state[5] = add32(_state[5], br);
    _state[6] = add32(_state[6], cr);
    _state[7] = add32(_state[7], dr);
  }

  void _proccess160(List<int> chunk) {
    assert(chunk.length == 16);

    int al = _state[0];
    int bl = _state[1];
    int cl = _state[2];
    int dl = _state[3];
    int el = _state[4];
    int ar = al;
    int br = bl;
    int cr = cl;
    int dr = dl;
    int er = el;

    for (int i = 0; i < 80; i++) {
      int t = add32(al, chunk[_RidempUtils.zl[i]]);
      t = add32(t, _RidempUtils.T(i, bl, cl, dl));
      t = rotl32(t, _RidempUtils.sl[i]);
      t = add32(t, el);
      al = el;
      el = dl;
      dl = rotl32(cl, 10);
      cl = bl;
      bl = t;

      t = add32(ar, chunk[_RidempUtils.zr[i]]);
      t = (t + _RidempUtils.t80(i, br, cr, dr));
      t = rotl32(t, _RidempUtils.sr[i]);
      t = add32(t, er);
      ar = er;
      er = dr;
      dr = rotl32(cr, 10);
      cr = br;
      br = t;
    }

    int t = add32(add32(_state[1], cl), dr);
    _state[1] = add32(add32(_state[2], dl), er);
    _state[2] = add32(add32(_state[3], el), ar);
    _state[3] = add32(add32(_state[4], al), br);
    _state[4] = add32(add32(_state[0], bl), cr);
    _state[0] = t;
  }
}

class _RidempUtils {
  static int F(int x, int y, int z) {
    return x ^ y ^ z;
  }

  static int G(int x, int y, int z) {
    return (x & y) | ((~x) & z);
  }

  static int H(int x, int y, int z) {
    return (x | (~y)) ^ z;
  }

  static int I(int x, int y, int z) {
    return (x & z) | (y & (~z));
  }

  static int J(int x, int y, int z) {
    return x ^ (y | (~z));
  }

  static int T(int i, int bl, int cl, int dl) {
    if (i < 16) {
      return F(bl, cl, dl);
    }
    if (i < 32) {
      return (G(bl, cl, dl) + 0x5a827999) & mask32;
    }
    if (i < 48) {
      return (H(bl, cl, dl) + 0x6ed9eba1) & mask32;
    }
    if (i < 64) {
      return (I(bl, cl, dl) + 0x8f1bbcdc) & mask32;
    }
    return (J(bl, cl, dl) + 0xa953fd4e) & mask32;
  }

  static int t64(int i, int br, int cr, int dr) {
    if (i < 16) {
      return (I(br, cr, dr) + 0x50a28be6) & mask32;
    }
    if (i < 32) {
      return (H(br, cr, dr) + 0x5c4dd124) & mask32;
    }
    if (i < 48) {
      return (G(br, cr, dr) + 0x6d703ef3) & mask32;
    }
    return F(br, cr, dr);
  }

  static int t80(int i, int br, int cr, int dr) {
    if (i < 16) {
      return (J(br, cr, dr) + 0x50a28be6) & mask32;
    }
    if (i < 32) {
      return (I(br, cr, dr) + 0x5c4dd124) & mask32;
    }
    if (i < 48) {
      return (H(br, cr, dr) + 0x6d703ef3) & mask32;
    }
    if (i < 64) {
      return (G(br, cr, dr) + 0x7a6d76e9) & mask32;
    }
    return F(br, cr, dr);
  }

  static const List<int> zl = [
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    7,
    4,
    13,
    1,
    10,
    6,
    15,
    3,
    12,
    0,
    9,
    5,
    2,
    14,
    11,
    8,
    3,
    10,
    14,
    4,
    9,
    15,
    8,
    1,
    2,
    7,
    0,
    6,
    13,
    11,
    5,
    12,
    1,
    9,
    11,
    10,
    0,
    8,
    12,
    4,
    13,
    3,
    7,
    15,
    14,
    5,
    6,
    2,
    4,
    0,
    5,
    9,
    7,
    12,
    2,
    10,
    14,
    1,
    3,
    8,
    11,
    6,
    15,
    13
  ];

  static const List<int> zr = [
    5,
    14,
    7,
    0,
    9,
    2,
    11,
    4,
    13,
    6,
    15,
    8,
    1,
    10,
    3,
    12,
    6,
    11,
    3,
    7,
    0,
    13,
    5,
    10,
    14,
    15,
    8,
    12,
    4,
    9,
    1,
    2,
    15,
    5,
    1,
    3,
    7,
    14,
    6,
    9,
    11,
    8,
    12,
    2,
    10,
    0,
    4,
    13,
    8,
    6,
    4,
    1,
    3,
    11,
    15,
    0,
    5,
    12,
    2,
    13,
    9,
    7,
    10,
    14,
    12,
    15,
    10,
    4,
    1,
    5,
    8,
    7,
    6,
    2,
    13,
    14,
    0,
    3,
    9,
    11
  ];

  static const List<int> sl = [
    11,
    14,
    15,
    12,
    5,
    8,
    7,
    9,
    11,
    13,
    14,
    15,
    6,
    7,
    9,
    8,
    7,
    6,
    8,
    13,
    11,
    9,
    7,
    15,
    7,
    12,
    15,
    9,
    11,
    7,
    13,
    12,
    11,
    13,
    6,
    7,
    14,
    9,
    13,
    15,
    14,
    8,
    13,
    6,
    5,
    12,
    7,
    5,
    11,
    12,
    14,
    15,
    14,
    15,
    9,
    8,
    9,
    14,
    5,
    6,
    8,
    6,
    5,
    12,
    9,
    15,
    5,
    11,
    6,
    8,
    13,
    12,
    5,
    12,
    13,
    14,
    11,
    8,
    5,
    6
  ];
  static const List<int> sr = [
    8,
    9,
    9,
    11,
    13,
    15,
    15,
    5,
    7,
    7,
    8,
    11,
    14,
    14,
    12,
    6,
    9,
    13,
    15,
    7,
    12,
    8,
    9,
    11,
    7,
    7,
    12,
    7,
    6,
    15,
    13,
    11,
    9,
    7,
    15,
    11,
    8,
    6,
    6,
    14,
    12,
    13,
    5,
    14,
    13,
    13,
    7,
    5,
    15,
    5,
    8,
    11,
    14,
    14,
    6,
    14,
    6,
    9,
    12,
    9,
    12,
    5,
    15,
    8,
    8,
    5,
    12,
    9,
    12,
    5,
    14,
    6,
    8,
    13,
    6,
    5,
    15,
    13,
    11,
    11
  ];

  static List<int> readState(int lengthInBytes) {
    final l = lengthInBytes ~/ 4;
    final List<int> state = List<int>.filled(l, 0);
    state[0] = 0x67452301;
    state[1] = 0xefcdab89;
    state[2] = 0x98badcfe;
    state[3] = 0x10325476;
    switch (lengthInBytes) {
      case 20:
        state[4] = 0xc3d2e1f0;
        break;
      case 32:
        state[4] = 0x76543210;
        state[5] = 0xfedcba98;
        state[6] = 0x89abcdef;
        state[7] = 0x01234567;
        break;
      case 40:
        state[4] = 0xc3d2e1f0;
        state[5] = 0x76543210;
        state[6] = 0xfedcba98;
        state[7] = 0x89abcdef;
        state[8] = 0x01234567;
        state[9] = 0x3c2d1e0f;
    }
    return state;
  }
}
