import 'dart:convert';
import 'dart:typed_data';

import 'package:abey_wallet/utils/string_util.dart';

const Base32CodecRfc base32Rfc = Base32CodecRfc();

String base32RfcEncode(Uint8List input) => base32Rfc.encode(input);

Uint8List base32RfcDecode(String input) => base32Rfc.decode(input);

const Base32CodecRfcHex base32RfcHex = Base32CodecRfcHex();

String base32RfcHexEncode(Uint8List input) => base32RfcHex.encode(input);

Uint8List base32RfcHexDecode(String input) => base32RfcHex.decode(input);

const Base32CodecCrockford base32Crockford = Base32CodecCrockford();

String base32CrockfordEncode(Uint8List input) => base32Crockford.encode(input);

Uint8List base32CrockfordDecode(String input) => base32Crockford.decode(input);

const Base32CodecZBase base32ZBase = Base32CodecZBase();

String base32ZBaseEncode(Uint8List input) => base32ZBase.encode(input);

Uint8List base32ZBaseDecode(String input) => base32ZBase.decode(input);

const Base32CodecGeoHash base32GeoHash = Base32CodecGeoHash();

String base32GeoHashEncode(Uint8List input) => base32GeoHash.encode(input);

Uint8List base32GeoHashDecode(String input) => base32GeoHash.decode(input);

const Base32CodecWordSafe base32WordSafe = Base32CodecWordSafe();

String base32WordSafeEncode(Uint8List input) => base32WordSafe.encode(input);

Uint8List base32WordSafeDecode(String input) => base32WordSafe.decode(input);

class Base32Const {
  static const String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  static const String paddingChar = '=';
  static final Map<String, Map<String, int>> _b32rev = {};
}

class Base32Utils {
  static String addPadding(String data) {
    final lastBlockWidth = data.length % 8;
    if (lastBlockWidth != 0) {
      data += '=' * (8 - lastBlockWidth);
    }
    return data;
  }

  static String translateAlphabet(String data, String fromAlphabet, String toAlphabet) {
    final translationMap = Map<String, String>.fromIterable(
      fromAlphabet.codeUnits,
      key: (unit) => String.fromCharCode(unit),
      value: (unit) {
        final index = fromAlphabet.indexOf(String.fromCharCode(unit));
        return toAlphabet[index];
      },
    );
    final translatedData = data.split('').map((char) {
      return translationMap[char] ?? char;
    }).join('');
    return translatedData;
  }

  static List<int> _b32decode(String alphabet, String base32,) {
    if (!Base32Const._b32rev.containsKey(alphabet)) {
      Base32Const._b32rev[alphabet] = {};
      for (var i = 0; i < alphabet.length; i++) {
        Base32Const._b32rev[alphabet]![alphabet[i]] = i;
      }
    }
    int shift = 8;
    int carry = 0;
    List<int> decoded = [];
    base32.split('').forEach((char) {
      if (char == '=') {
        return;
      }
      final symbol = (Base32Const._b32rev[alphabet]![char] ?? 0) & 0xff;
      shift -= 5;
      if (shift > 0) {
        carry |= (symbol << shift) & 0xff;
      } else if (shift < 0) {
        decoded.add(carry | (symbol >> -shift));
        shift += 8;
        carry = (symbol << shift) & 0xff;
      } else {
        decoded.add(carry | symbol);
        shift = 8;
        carry = 0;
      }
    });
    if (shift != 8 && carry != 0) {
      decoded.add(carry);
      shift = 8;
      carry = 0;
    }
    return decoded;
  }

  static List<int> b32encode(String alphabet, List<int> s) {
    final leftover = s.length % 5;
    if (leftover != 0) {
      final padding = List.filled(5 - leftover, 0);
      s = List<int>.from([...s, ...padding]);
    }
    int shift = 3;
    int carry = 0;
    final encoded = <int>[];
    for (final byte in s) {
      int symbol = carry | (byte >> shift);
      encoded.addAll(alphabet[symbol & 0x1f].codeUnits);
      if (shift > 5) {
        shift -= 5;
        symbol = byte >> shift;
        encoded.addAll(alphabet[symbol & 0x1f].codeUnits);
      }
      shift = 5 - shift;
      carry = byte << shift;
      shift = 8 - shift;
    }
    if (shift != 3) {
      encoded.addAll(alphabet[carry & 0x1f].codeUnits);
      shift = 3;
      carry = 0;
    }
    if (leftover == 1) {
      encoded.setAll(encoded.length - 6, [0x3d, 0x3d, 0x3d, 0x3d, 0x3d, 0x3d]);
    } else if (leftover == 2) {
      encoded.setAll(encoded.length - 4, [0x3d, 0x3d, 0x3d, 0x3d]);
    } else if (leftover == 3) {
      encoded.setAll(encoded.length - 3, [0x3d, 0x3d, 0x3d]);
    } else if (leftover == 4) {
      encoded.setAll(encoded.length - 1, [0x3d]);
    }
    return List<int>.from(encoded);
  }
}

class Base32CodecRfc extends Codec<Uint8List, String> {
  static const String _alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
  static const String _padding = "=";
  const Base32CodecRfc();

  @override
  Converter<Uint8List, String> get encoder => const Base32Encoder(_alphabet, _padding);

  @override
  Converter<String, Uint8List> get decoder => const Base32Decoder(_alphabet, _padding);
}

class Base32CodecRfcHex extends Codec<Uint8List, String> {
  static const String _alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUV";
  static const String _padding = "=";
  const Base32CodecRfcHex();

  @override
  Converter<Uint8List, String> get encoder => const Base32Encoder(_alphabet, _padding);

  @override
  Converter<String, Uint8List> get decoder => const Base32Decoder(_alphabet, _padding);
}

class Base32CodecCrockford extends Codec<Uint8List, String> {
  static const String _alphabet = "0123456789ABCDEFGHJKMNPQRSTVWXYZ";
  static const String _padding = "";
  const Base32CodecCrockford();

  @override
  Converter<Uint8List, String> get encoder => const Base32Encoder(_alphabet, _padding);

  @override
  Converter<String, Uint8List> get decoder => const Base32DecoderCrockford(_alphabet, _padding);
}

class Base32CodecZBase extends Codec<Uint8List, String> {
  static const String _alphabet = "YBNDRFG8EJKMCPQXOT1UWISZA345H769";
  static const String _padding = "";
  const Base32CodecZBase();

  @override
  Converter<Uint8List, String> get encoder => const Base32Encoder(_alphabet, _padding);

  @override
  Converter<String, Uint8List> get decoder => const Base32Decoder(_alphabet, _padding);
}

class Base32CodecGeoHash extends Codec<Uint8List, String> {
  static const String _alphabet = "0123456789bcdefghjkmnpqrstuvwxyz";
  static const String _padding = "";
  const Base32CodecGeoHash();

  @override
  Converter<Uint8List, String> get encoder => const Base32Encoder(_alphabet, _padding);

  @override
  Converter<String, Uint8List> get decoder => const Base32Decoder(_alphabet, _padding, caseInsensitive: false);
}

class Base32CodecWordSafe extends Codec<Uint8List, String> {
  static const String _alphabet = "23456789CFGHJMPQRVWXcfghjmpqrvwx";
  static const String _padding = "";
  const Base32CodecWordSafe();

  @override
  Converter<Uint8List, String> get encoder => const Base32Encoder(_alphabet, _padding);

  @override
  Converter<String, Uint8List> get decoder => const Base32Decoder(_alphabet, _padding, caseInsensitive: false);
}

class Base32CodecCustom extends Codec<Uint8List, String> {
  final String alphabet;
  final String padding;
  const Base32CodecCustom(this.alphabet, this.padding);

  @override
  Converter<Uint8List, String> get encoder => Base32Encoder(alphabet, padding);

  @override
  Converter<String, Uint8List> get decoder => Base32Decoder(alphabet, padding);
}

class Base32Encoder extends Converter<Uint8List, String> {
  final String _alphabet;
  final String _padding;
  const Base32Encoder(this._alphabet, this._padding);

  @override
  String convert(Uint8List input) {
    final buffer = StringBuffer();
    int bits = 0;
    int value = 0;
    for (int i = 0; i < input.length; i++) {
      value = (value << 8) | input[i];
      bits += 8;
      while (bits >= 5) {
        buffer.write(_alphabet[(value >> (bits - 5)) & 0x1F]);
        bits -= 5;
      }
    }
    if (bits > 0) {
      buffer.write(_alphabet[(value << (5 - bits)) & 0x1F]);
    }
    if (_padding.isNotEmpty && (buffer.length % 8) != 0) {
      buffer.write(_padding * ((buffer.length % 8) - 8).abs());
    }
    return buffer.toString();
  }

  static String encode(String data, [String? customAlphabet]) {
    String encoded = StringUtil.decode(Base32Utils.b32encode(Base32Const.alphabet, StringUtil.encode(data)));
    if (customAlphabet != null) {
      encoded = Base32Utils.translateAlphabet(encoded, Base32Const.alphabet, customAlphabet);
    }
    return encoded;
  }

  static String encodeBytes(List<int> data, [String? customAlphabet]) {
    String encoded = StringUtil.decode(Base32Utils.b32encode(Base32Const.alphabet, data));
    if (customAlphabet != null) {
      encoded = Base32Utils.translateAlphabet(encoded, Base32Const.alphabet, customAlphabet);
    }
    return encoded;
  }

  static String encodeNoPadding(String data, [String? customAlphabet]) {
    return encode(data, customAlphabet).replaceAll(Base32Const.paddingChar, '');
  }

  static String encodeNoPaddingBytes(List<int> data, [String? customAlphabet]) {
    return encodeBytes(data, customAlphabet).replaceAll(Base32Const.paddingChar, '');
  }

  static List<int> decode(String data, [String? customAlphabet]) {
    try {
      data = Base32Utils.addPadding(data);
      if (customAlphabet != null) {
        data = Base32Utils.translateAlphabet(data, customAlphabet, Base32Const.alphabet);
      }
      final decodedBytes = Base32Utils._b32decode(Base32Const.alphabet, data);
      return List<int>.from(decodedBytes);
    } catch (ex) {
      throw Exception('Invalid Base32 string');
    }
  }
}

class Base32Decoder extends Converter<String, Uint8List> {
  final String _alphabet;
  final String _padding;
  final bool caseInsensitive;

  const Base32Decoder(
    this._alphabet,
    this._padding, {
    this.caseInsensitive = true,
  });

  @override
  Uint8List convert(String input) {
    String data = caseInsensitive ? input.toUpperCase() : input;
    if (_padding.isNotEmpty) {
      data = data.replaceAll(_padding, "");
    }
    final buffer = Uint8List(data.length * 5 ~/ 8);
    final length = data.length;
    int bits = 0;
    int value = 0;
    int byte = 0;
    for (int i = 0; i < length; i++) {
      final index = _alphabet.indexOf(data[i]);
      if (index == -1) {
        throw FormatException('Invalid character detected: ${data[i]}');
      }
      value = (value << 5) | index;
      bits += 5;
      if (bits >= 8) {
        buffer[byte++] = (value >> (bits - 8)) & 0xFF;
        bits -= 8;
      }
    }
    return buffer;
  }
}

class Base32DecoderCrockford extends Base32Decoder {
  const Base32DecoderCrockford(String alphabet, String padding) : super(alphabet, padding);

  @override
  Uint8List convert(String input) {
    return super.convert(
      input.replaceAll(RegExp('[oO]'), '0').replaceAll(RegExp('[IiLl]'), '1'),
    );
  }
}
