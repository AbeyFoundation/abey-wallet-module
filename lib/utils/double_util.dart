import 'dart:typed_data';

class DoubleUtil {
  static List<int> toBytes(double value, {Endian byteOrder = Endian.big}) {
    final ByteData byteData = ByteData(8);
    byteData.setFloat64(0, value, byteOrder);
    return byteData.buffer.asUint8List();
  }

  static double fromBytes(List<int> bytes, {Endian byteOrder = Endian.big}) {
    final ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    return byteData.getFloat64(0, byteOrder);
  }
}
