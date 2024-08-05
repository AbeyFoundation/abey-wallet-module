class BitUtil {
  static bool intIsBitSet(int value, int bitNum) {
    return (value & (1 << bitNum)) != 0;
  }

  static bool areBitsSet(int value, int bitMask) {
    return (value & bitMask) != 0;
  }

  static int setBit(int value, int bitNum) {
    return value | (1 << bitNum);
  }

  static int setBits(int value, int bitMask) {
    return value | bitMask;
  }

  static int resetBit(int value, int bitNum) {
    return value & ~(1 << bitNum);
  }

  static int resetBits(int value, int bitMask) {
    return value & ~bitMask;
  }
}
