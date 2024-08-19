part of 'package:abey_wallet/vender/crypto/hash/hash.dart';

const int _blockSize = 128;
const int _digestLength = 64;
const int _keyLength = 64;
const int _personalizationLength = 16;
const int _saltLength = 16;

const int _maxLeafSize = 4294967295;
const int _maxFanout = 255;
const int _maxMaxDepth = 255;

class Blake2bConfig {
  final List<int>? key;
  final List<int>? salt;
  final List<int>? personalization;
  final Blake2bTree? tree;

  const Blake2bConfig({this.key, this.salt, this.personalization, this.tree});
}

class Blake2bTree {
  final int fanout;
  final int maxDepth;
  final int leafSize;
  final int nodeOffsetHighBits;
  final int nodeOffsetLowBits;
  final int nodeDepth;
  final int innerDigestLength;
  final bool lastNode;

  const Blake2bTree({
    required this.fanout,
    required this.maxDepth,
    required this.leafSize,
    required this.nodeOffsetHighBits,
    required this.nodeOffsetLowBits,
    required this.nodeDepth,
    required this.innerDigestLength,
    required this.lastNode,
  });
}

final _iv = List<int>.unmodifiable(const [
  0xf3bcc908,
  0x6a09e667,
  0x84caa73b,
  0xbb67ae85,
  0xfe94f82b,
  0x3c6ef372,
  0x5f1d36f1,
  0xa54ff53a,
  0xade682d1,
  0x510e527f,
  0x2b3e6c1f,
  0x9b05688c,
  0xfb41bd6b,
  0x1f83d9ab,
  0x137e2179,
  0x5be0cd19
]);

final List<List<int>> _sigma = [
  [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30],
  [28, 20, 8, 16, 18, 30, 26, 12, 2, 24, 0, 4, 22, 14, 10, 6],
  [22, 16, 24, 0, 10, 4, 30, 26, 20, 28, 6, 12, 14, 2, 18, 8],
  [14, 18, 6, 2, 26, 24, 22, 28, 4, 12, 10, 20, 8, 0, 30, 16],
  [18, 0, 10, 14, 4, 8, 20, 30, 28, 2, 22, 24, 12, 16, 6, 26],
  [4, 24, 12, 20, 0, 22, 16, 6, 8, 26, 14, 10, 30, 28, 2, 18],
  [24, 10, 2, 30, 28, 26, 8, 20, 0, 14, 12, 6, 18, 4, 16, 22],
  [26, 22, 14, 28, 24, 2, 6, 18, 10, 0, 30, 8, 16, 12, 4, 20],
  [12, 30, 28, 18, 22, 6, 0, 16, 24, 4, 26, 14, 2, 8, 20, 10],
  [20, 4, 16, 8, 14, 12, 2, 10, 30, 22, 18, 28, 6, 24, 26, 0],
  [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30],
  [28, 20, 8, 16, 18, 30, 26, 12, 2, 24, 0, 4, 22, 14, 10, 6]
];

class BLAKE2b implements SerializableHash<Blake2bState> {
  final List<int> _state = List<int>.from(_iv, growable: false);
  final List<int> _buffer = List<int>.filled(_blockSize, 0);
  int _bufferLength = 0;
  final List<int> _ctr = List<int>.filled(4, 0);
  final List<int> _flag = List<int>.filled(4, 0);
  bool _lastNode = false;
  bool _finished = false;
  final List<int> _vtmp = List<int>.filled(32, 0);
  final List<int> _mtmp = List<int>.filled(32, 0);
  List<int>? _paddedKey;
  late List<int> _initialState;

  static List<int> hash(List<int> data,
      [int digestLength = 64, Blake2bConfig? config]) {
    final h = BLAKE2b(digestLength: digestLength, config: config);
    h.update(data);
    final digest = h.digest();
    h.clean();
    return digest;
  }

  BLAKE2b({int digestLength = 64, Blake2bConfig? config}) {
    if (digestLength < 1 || digestLength > _digestLength) {
      throw Exception("blake2b: wrong digest length");
    }
    getDigestLength = digestLength;

    if (config != null) {
      _validateConfig(config);
    }

    int klength = 0;
    if (config != null && config.key != null) {
      klength = config.key!.length;
    }

    int fanout = 1;
    int maxDepth = 1;
    if (config != null && config.tree != null) {
      fanout = config.tree!.fanout;
      maxDepth = config.tree!.maxDepth;
    }

    _state[0] ^=
        (getDigestLength | (klength << 8) | (fanout << 16) | (maxDepth << 24));

    if (config != null && config.tree != null) {
      _state[1] ^= config.tree!.leafSize;

      _state[2] ^= config.tree!.nodeOffsetLowBits;
      _state[3] ^= config.tree!.nodeOffsetHighBits;
      _state[4] ^=
          (config.tree!.nodeDepth | (config.tree!.innerDigestLength << 8));

      _lastNode = config.tree!.lastNode;
    }

    if (config != null && config.salt != null) {
      _state[8] ^= readUint32LE(config.salt!, 0);
      _state[9] ^= readUint32LE(config.salt!, 4);
      _state[10] ^= readUint32LE(config.salt!, 8);
      _state[11] ^= readUint32LE(config.salt!, 12);
    }

    if (config != null && config.personalization != null) {
      _state[12] ^= readUint32LE(config.personalization!, 0);
      _state[13] ^= readUint32LE(config.personalization!, 4);
      _state[14] ^= readUint32LE(config.personalization!, 8);
      _state[15] ^= readUint32LE(config.personalization!, 12);
    }

    _initialState = List<int>.from(_state, growable: false);

    if (config != null && config.key != null && _keyLength > 0) {
      _paddedKey = List<int>.filled(_blockSize, 0);
      _paddedKey!.setAll(0, BytesUtil.toBytes(config.key!));

      _buffer.setAll(0, _paddedKey!);
      _bufferLength = _blockSize;
    }
  }

  @override
  BLAKE2b reset() {
    _state.setAll(0, _initialState);

    if (_paddedKey != null) {
      _buffer.setAll(0, _paddedKey!);
      _bufferLength = _blockSize;
    } else {
      _bufferLength = 0;
    }

    zero(_ctr);
    zero(_flag);
    _finished = false;

    return this;
  }

  void _validateConfig(Blake2bConfig config) {
    if (config.key != null && config.key!.length > _keyLength) {
      throw Exception("blake2b: wrong key length");
    }
    if (config.salt != null && config.salt!.length != _saltLength) {
      throw Exception("blake2b: wrong salt length");
    }
    if (config.personalization != null &&
        config.personalization!.length != _personalizationLength) {
      throw Exception("blake2b: wrong personalization length");
    }
    if (config.tree != null) {
      if (config.tree!.fanout < 0 || config.tree!.fanout > _maxFanout) {
        throw Exception("blake2b: wrong tree fanout");
      }
      if (config.tree!.maxDepth < 0 || config.tree!.maxDepth > _maxMaxDepth) {
        throw Exception("blake2b: wrong tree depth");
      }
      if (config.tree!.leafSize < 0 || config.tree!.leafSize > _maxLeafSize) {
        throw Exception("blake2b: wrong leaf size");
      }
      if (config.tree!.innerDigestLength < 0 ||
          config.tree!.innerDigestLength > _digestLength) {
        throw Exception(
            "blake2b: wrong tree inner digest length");
      }
    }
  }

  @override
  BLAKE2b update(List<int> data, {int? length}) {
    if (_finished) {
      throw Exception(
          "blake2b: can't update because hash was finished.");
    }

    int left = _blockSize - _bufferLength;
    int dataPos = 0;

    int dataLength = length ?? data.length;

    if (dataLength == 0) {
      return this;
    }

    if (dataLength > left) {
      for (int i = 0; i < left; i++) {
        _buffer[_bufferLength + i] = data[dataPos + i] & mask8;
      }
      _processBlock(_blockSize);
      dataPos += left;
      dataLength -= left;
      _bufferLength = 0;
    }

    while (dataLength > _blockSize) {
      for (int i = 0; i < _blockSize; i++) {
        _buffer[i] = data[dataPos + i] & mask8;
      }
      _processBlock(_blockSize);
      dataPos += _blockSize;
      dataLength -= _blockSize;
      _bufferLength = 0;
    }

    for (int i = 0; i < dataLength; i++) {
      _buffer[_bufferLength + i] = data[dataPos + i] & mask8;
    }
    _bufferLength += dataLength;

    return this;
  }

  @override
  BLAKE2b finish(List<int> out) {
    if (!_finished) {
      for (int i = _bufferLength; i < _blockSize; i++) {
        _buffer[i] = 0;
      }

      _flag[0] = mask32;
      _flag[1] = mask32;

      if (_lastNode) {
        _flag[2] = mask32;
        _flag[3] = mask32;
      }

      _processBlock(_bufferLength);
      _finished = true;
    }

    List<int> tmp = List<int>.filled(64, 0);
    for (int i = 0; i < 16; i++) {
      writeUint32LE(_state[i], tmp, i * 4);
    }
    out.setRange(0, out.length, tmp);
    return this;
  }

  @override
  List<int> digest() {
    List<int> out = List<int>.filled(getDigestLength, 0);
    finish(out);
    return out;
  }

  @override
  void clean() {
    zero(_vtmp);
    zero(_mtmp);
    zero(_state);
    zero(_buffer);
    zero(_initialState);
    if (_paddedKey != null) {
      zero(_paddedKey!);
    }
    _bufferLength = 0;
    zero(_ctr);
    zero(_flag);
    _lastNode = false;
    _finished = false;
  }

  void _g(List<int> v, int al, int bl, int cl, int dl, int ah, int bh, int ch,
      int dh, int ml0, int mh0, int ml1, int mh1) {
    int vla = v[al],
        vha = v[ah],
        vlb = v[bl],
        vhb = v[bh],
        vlc = v[cl],
        vhc = v[ch],
        vld = v[dl],
        vhd = v[dh];

    int w = vla & mask16,
        x = (vla >> 16) & mask16,
        y = vha & mask16,
        z = (vha >> 16) & mask16;

    w += vlb & mask16;
    x += (vlb >> 16) & mask16;
    y += vhb & mask16;
    z += (vhb >> 16) & mask16;

    x += (w >> 16) & mask16;
    y += (x >> 16) & mask16;
    z += (y >> 16) & mask16;

    vha = ((y & mask16) | (z << 16)) & mask32;
    vla = ((w & mask16) | (x << 16)) & mask32;

    w = vla & mask16;
    x = (vla >> 16) & mask16;
    y = vha & mask16;
    z = (vha >> 16) & mask16;

    w += ml0 & mask16;
    x += (ml0 >> 16) & mask16;
    y += mh0 & mask16;
    z += (mh0 >> 16) & mask16;

    x += (w >> 16) & mask16;
    y += (x >> 16) & mask16;
    z += (y >> 16) & mask16;

    vha = ((y & mask16) | (z << 16)) & mask32;
    vla = ((w & mask16) | (x << 16)) & mask32;

    vld ^= vla;
    vhd ^= vha;

    w = vhd;
    vhd = vld;
    vld = w;

    w = vlc & mask16;
    x = (vlc >> 16) & mask16;
    y = vhc & mask16;
    z = (vhc >> 16) & mask16;

    w += vld & mask16;
    x += (vld >> 16) & mask16;
    y += vhd & mask16;
    z += (vhd >> 16) & mask16;

    x += (w >> 16) & mask16;
    y += (x >> 16) & mask16;
    z += (y >> 16) & mask16;

    vhc = ((y & mask16) | (z << 16)) & mask32;
    vlc = ((w & mask16) | (x << 16)) & mask32;

    vlb ^= vlc;
    vhb ^= vhc;

    w = ((vlb << 8) | (vhb >> 24)) & mask32;
    vlb = ((vhb << 8) | (vlb >> 24)) & mask32;
    vhb = w;

    w = vla & mask16;
    x = (vla >> 16) & mask16;
    y = vha & mask16;
    z = (vha >> 16) & mask16;

    w += vlb & mask16;
    x += (vlb >> 16) & mask16;
    y += vhb & mask16;
    z += (vhb >> 16) & mask16;

    x += (w >> 16) & mask16;
    y += (x >> 16) & mask16;
    z += (y >> 16) & mask16;

    vha = ((y & mask16) | (z << 16)) & mask32;
    vla = ((w & mask16) | (x << 16)) & mask32;

    w = vla & mask16;
    x = (vla >> 16) & mask16;
    y = vha & mask16;
    z = (vha >> 16) & mask16;

    w += ml1 & mask16;
    x += (ml1 >> 16) & mask16;
    y += mh1 & mask16;
    z += (mh1 >> 16) & mask16;

    x += (w >> 16) & mask16;
    y += (x >> 16) & mask16;
    z += (y >> 16) & mask16;

    vha = ((y & mask16) | (z << 16)) & mask32;
    vla = ((w & mask16) | (x << 16)) & mask32;

    vld ^= vla;
    vhd ^= vha;

    w = ((vld << 16) | (vhd >> 16)) & mask32;
    vld = ((vhd << 16) | (vld >> 16)) & mask32;
    vhd = w;

    w = vlc & mask16;
    x = (vlc >> 16) & mask16;
    y = vhc & mask16;
    z = (vhc >> 16) & mask16;

    w += vld & mask16;
    x += (vld >> 16) & mask16;
    y += vhd & mask16;
    z += (vhd >> 16) & mask16;

    x += (w >> 16) & mask16;
    y += (x >> 16) & mask16;
    z += (y >> 16) & mask16;

    vhc = ((y & mask16) | (z << 16)) & mask32;
    vlc = ((w & mask16) | (x << 16)) & mask32;

    vlb ^= vlc;
    vhb ^= vhc;

    w = ((vhb << 1) | (vlb >> 31)) & mask32;
    vlb = ((vlb << 1) | (vhb >> 31)) & mask32;
    vhb = w;

    v[al] = vla;
    v[ah] = vha;
    v[bl] = vlb;
    v[bh] = vhb;
    v[cl] = vlc;
    v[ch] = vhc;
    v[dl] = vld;
    v[dh] = vhd;
  }

  void _processBlock(int length) {
    _incrementCounter(length);
    var v = _vtmp;
    v.setAll(0, _state);
    v.setAll(16, _iv);
    v[12 * 2 + 0] ^= _ctr[0];
    v[12 * 2 + 1] ^= _ctr[1];
    v[13 * 2 + 0] ^= _ctr[2];
    v[13 * 2 + 1] ^= _ctr[3];
    v[14 * 2 + 0] ^= _flag[0];
    v[14 * 2 + 1] ^= _flag[1];
    v[15 * 2 + 0] ^= _flag[2];
    v[15 * 2 + 1] ^= _flag[3];
    var m = _mtmp;
    for (var i = 0; i < 32; i++) {
      m[i] = readUint32LE(_buffer, i * 4);
    }
    for (var r = 0; r < 12; r++) {
      _g(v, 0, 8, 16, 24, 1, 9, 17, 25, m[_sigma[r][0]], m[_sigma[r][0] + 1],
          m[_sigma[r][1]], m[_sigma[r][1] + 1]);

      _g(v, 2, 10, 18, 26, 3, 11, 19, 27, m[_sigma[r][2]], m[_sigma[r][2] + 1],
          m[_sigma[r][3]], m[_sigma[r][3] + 1]);

      _g(v, 4, 12, 20, 28, 5, 13, 21, 29, m[_sigma[r][4]], m[_sigma[r][4] + 1],
          m[_sigma[r][5]], m[_sigma[r][5] + 1]);
      _g(v, 6, 14, 22, 30, 7, 15, 23, 31, m[_sigma[r][6]], m[_sigma[r][6] + 1],
          m[_sigma[r][7]], m[_sigma[r][7] + 1]);
      _g(v, 0, 10, 20, 30, 1, 11, 21, 31, m[_sigma[r][8]], m[_sigma[r][8] + 1],
          m[_sigma[r][9]], m[_sigma[r][9] + 1]);
      _g(v, 2, 12, 22, 24, 3, 13, 23, 25, m[_sigma[r][10]],
          m[_sigma[r][10] + 1], m[_sigma[r][11]], m[_sigma[r][11] + 1]);
      _g(v, 4, 14, 16, 26, 5, 15, 17, 27, m[_sigma[r][12]],
          m[_sigma[r][12] + 1], m[_sigma[r][13]], m[_sigma[r][13] + 1]);
      _g(v, 6, 8, 18, 28, 7, 9, 19, 29, m[_sigma[r][14]], m[_sigma[r][14] + 1],
          m[_sigma[r][15]], m[_sigma[r][15] + 1]);
    }
    for (var i = 0; i < 16; i++) {
      _state[i] ^= v[i] ^ v[i + 16];
    }
  }

  @override
  void cleanSavedState(HashState savedState) {
    savedState as Blake2bState;
    zero(savedState.state);
    zero(savedState.buffer);
    zero(savedState.initialState);

    if (savedState.paddedKey != null) {
      zero(savedState.paddedKey!);
    }

    savedState.bufferLength = 0;
    zero(savedState.ctr);
    zero(savedState.flag);

    savedState.lastNode = false;
  }

  @override
  int get getBlockSize => _blockSize;

  @override
  late final int getDigestLength;

  @override
  BLAKE2b restoreState(Blake2bState savedState) {
    _state.setAll(0, savedState.state);
    _buffer.setAll(0, savedState.buffer);
    _bufferLength = savedState.bufferLength;
    _ctr.setAll(0, savedState.ctr);
    _flag.setAll(0, savedState.flag);
    _lastNode = savedState.lastNode;

    if (_paddedKey != null) {
      zero(_paddedKey!);
    }

    _paddedKey = savedState.paddedKey != null
        ? List<int>.from(savedState.paddedKey!)
        : null;

    _initialState.setAll(0, savedState.initialState);

    return this;
  }

  @override
  Blake2bState saveState() {
    if (_finished) {
      throw Exception("blake2b: cannot save finished state");
    }

    return Blake2bState(
      state: List<int>.from(_state, growable: false),
      buffer: List<int>.from(_buffer, growable: false),
      bufferLength: _bufferLength,
      ctr: List<int>.from(_ctr, growable: false),
      flag: List<int>.from(_flag, growable: false),
      lastNode: _lastNode,
      paddedKey: _paddedKey != null ? List<int>.from(_paddedKey!) : null,
      initialState: List<int>.from(_initialState, growable: false),
    );
  }

  void _incrementCounter(int length) {
    for (int i = 0; i < 3; i++) {
      int a = _ctr[i] + length;
      _ctr[i] = a & mask32;
      if (_ctr[i] == a) {
        return;
      }
      length = 1;
    }
  }
}

class Blake2bState implements HashState {
  List<int> state;

  List<int> buffer;

  int bufferLength;

  List<int> ctr;

  List<int> flag;

  bool lastNode;

  List<int>? paddedKey;

  List<int> initialState;

  Blake2bState({
    required this.state,
    required this.buffer,
    required this.bufferLength,
    required this.ctr,
    required this.flag,
    required this.lastNode,
    this.paddedKey,
    required this.initialState,
  });
}
