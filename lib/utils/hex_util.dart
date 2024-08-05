import "dart:convert";
import "dart:typed_data";

import "package:abey_wallet/common/constant.dart";
import "package:abey_wallet/utils/binary_util.dart";
import "package:abey_wallet/utils/bytes_util.dart";

const HEX = const HexCodec();

class HexCodec extends Codec<List<int>, String> {
  const HexCodec();

  @override
  Converter<List<int>, String> get encoder => const HexEncoder();

  @override
  Converter<String, List<int>> get decoder => const HexDecoder();

  static const _lookupTableLower = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'a',
    'b',
    'c',
    'd',
    'e',
    'f'
  ];
  static const _lookupTableUpper = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F'
  ];

  static const _invalidHexNibble = 256;

  static const List<int> _nibbleLookupTable = [
    256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256,
    256,
    256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256,
    256,
    256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256,
    256,
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 256, 256, 256, 256, 256, 256, // 48-63 (0-9)
    256, 10, 11, 12, 13, 14, 15, 256, 256, 256, 256, 256, 256, 256, 256,
    256,
    256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256,
    256,
    256, 10, 11, 12, 13, 14, 15, 256, 256, 256, 256, 256, 256, 256, 256,
    256,
    256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256,
    256,
  ];

  int _decodeNibble(int charCode) {
    return charCode < 128 ? _nibbleLookupTable[charCode] : _invalidHexNibble;
  }

  String encode(List<int> data, {bool lowerCase = true}) {
    BytesUtil.validateBytes(data, onError: "Invalid hex bytes");
    final table = lowerCase ? _lookupTableLower : _lookupTableUpper;
    final int length = data.length;
    final List<String> result = List<String>.filled(length * 2, '');
    for (int i = 0; i < length; i++) {
      final byte = data[i];
      result[i * 2] = table[byte >> 4];
      result[i * 2 + 1] = table[byte & 0x0F];
    }
    return result.join();
  }

  List<int> decode(String hex) {
    if (hex.isEmpty) {
      return List.empty();
    }
    if (!hex.length.isEven) {
      throw Exception("Hex input string must be divisible by two");
    }
    final result = List<int>.filled(hex.length ~/ 2, 0);
    bool haveBad = false;
    for (int i = 0; i < hex.length; i += 2) {
      int v0 = _decodeNibble(hex.codeUnitAt(i));
      int v1 = _decodeNibble(hex.codeUnitAt(i + 1));
      result[i ~/ 2] = ((v0 << 4) | v1) & mask8;
      haveBad |= (v0 == _invalidHexNibble) | (v1 == _invalidHexNibble);
    }
    if (haveBad) {
      throw Exception("Incorrect characters for hex decoding");
    }
    return result;
  }
}

class HexEncoder extends Converter<List<int>, String> {
  final bool upperCase;

  const HexEncoder({bool this.upperCase: false});

  @override
  String convert(List<int> bytes) {
    StringBuffer buffer = new StringBuffer();
    for (int part in bytes) {
      if (part & 0xff != part) {
        throw new FormatException("Non-byte integer detected");
      }
      buffer.write('${part < 16 ? '0' : ''}${part.toRadixString(16)}');
    }
    if(upperCase) {
      return buffer.toString().toUpperCase();
    } else {
      return buffer.toString();
    }
  }
}

class HexDecoder extends Converter<String, List<int>> {
  const HexDecoder();

  @override
  List<int> convert(String hex) {
    String str = hex.replaceAll(" ", "");
    str = str.toLowerCase();
    if (str.length % 2 != 0) {
      str = "0" + str;
    }
    Uint8List result = new Uint8List(str.length ~/ 2);
    for (int i = 0 ; i < result.length ; i++) {
      int firstDigit = Constant.ZALPHABET.indexOf(str[i*2]);
      int secondDigit = Constant.ZALPHABET.indexOf(str[i*2+1]);
      if (firstDigit == -1 || secondDigit == -1) {
        throw new FormatException("Non-hex character detected in $hex");
      }
      result[i] = (firstDigit << 4) + secondDigit;
    }
    return result;
  }
}
