import 'dart:typed_data';

class FloatUtil {
  static List<int> toBytes(double value, {Endian byteOrder = Endian.big}) {
    final ByteData byteData = ByteData(4);
    byteData.setFloat32(0, value, byteOrder);
    return byteData.buffer.asUint8List();
  }

  static double fromBytes(List<int> bytes, {Endian byteOrder = Endian.big}) {
    final ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    return byteData.getFloat32(0, byteOrder);
  }
}
