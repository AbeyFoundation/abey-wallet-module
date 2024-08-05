
List<int> writeUint64LE(int value, [List<int>? out, int offset = 0]) {
  out ??= List<int>.filled(8, 0);

  writeUint32LE(value & mask32, out, offset);
  writeUint32LE((value >> 32) & mask32, out, offset + 4);

  return out;
}

void writeUint32LE(int value, List<int> out, [int offset = 0]) {
  out[offset + 0] = (value & mask8);
  out[offset + 1] = ((value >> 8) & mask8);
  out[offset + 2] = ((value >> 16) & mask8);
  out[offset + 3] = ((value >> 24) & mask8);
}

void writeUint16LE(int value, List<int> out, [int offset = 0]) {
  out[offset + 0] = (value & mask8);
  out[offset + 1] = ((value >> 8) & mask8);
}

int readUint32LE(List<int> array, [int offset = 0]) {
  return ((array[offset + 3] << 24) |
          (array[offset + 2] << 16) |
          (array[offset + 1] << 8) |
          array[offset]) &
      mask32;
}

int readUint16LE(List<int> array, [int offset = 0]) {
  return ((array[offset + 1] << 8) | array[offset]) & mask32;
}

void writeUint32BE(int value, List<int> out, [int offset = 0]) {
  out[offset + 0] = (value >> 24) & mask8;
  out[offset + 1] = (value >> 16) & mask8;
  out[offset + 2] = (value >> 8) & mask8;
  out[offset + 3] = value & mask8;
}

void writeUint16BE(int value, List<int> out, [int offset = 0]) {
  out[offset] = (value >> 8) & mask8;
  out[offset + 1] = value & mask8;
}

int readUint32BE(List<int> array, [int offset = 0]) {
  return ((array[offset] << 24) |
          (array[offset + 1] << 16) |
          (array[offset + 2] << 8) |
          array[offset + 3]) &
      mask32;
}

int readUint16BE(List<int> data, [int offset = 0]) {
  if (offset < 0 || offset + 2 > data.length) {
    throw RangeError('Index out of bounds');
  }
  return ((data[offset] & mask8) << 8) | (data[offset + 1] & mask8);
}

int readUint8(List<int> array, [int offset = 0]) {
  return array[offset] & mask8;
}

const mask32 = 0xFFFFFFFF;

const mask16 = 0xFFFF;

const mask13 = 0x1fff;

const mask8 = 0xFF;

int add32(int x, int y) => (x + y) & mask32;

int rotl32(int val, int shift) {
  var modShift = shift & 31;
  return ((val << modShift) & mask32) | ((val & mask32) >> (32 - modShift));
}

int rotr32(int val, int shift) {
  var modShift = shift & 31;
  return ((val >> modShift) & mask32) | ((val & mask32) << (32 - modShift));
}

int shr16(int x) {
  return (x >> 16) & mask16;
}

void zero(List<int> array) {
  for (int i = 0; i < array.length; i++) {
    array[i] = 0;
  }
}

final BigInt maxU64 = BigInt.parse("18446744073709551615");

final BigInt maskBig8 = BigInt.from(mask8);

final BigInt maskBig16 = BigInt.from(mask16);

final BigInt maskBig32 = BigInt.from(mask32);
