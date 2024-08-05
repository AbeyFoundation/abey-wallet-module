import 'dart:convert';
import 'dart:typed_data';

import 'package:abey_wallet/utils/bigint_util.dart';
import 'package:abey_wallet/utils/bytes_util.dart';

import 'base_constants.dart';

const Base58CodecBitcoin base58Bitcoin = Base58CodecBitcoin();

String base58BitcoinEncode(Uint8List input) => base58Bitcoin.encode(input);

Uint8List base58BitcoinDecode(String input) => base58Bitcoin.decode(input);

const Base58CodecFlickr base58Flickr = Base58CodecFlickr();

String base58FlickrEncode(Uint8List input) => base58Flickr.encode(input);

Uint8List base58FlickrDecode(String input) => base58Flickr.decode(input);

const Base58CodecRipple base58Ripple = Base58CodecRipple();

String base58RippleEncode(Uint8List input) => base58Ripple.encode(input);

Uint8List base58RippleDecode(String input) => base58Ripple.decode(input);

enum Base58Alphabets {
  bitcoin,
  ripple,
}

class Base58Const {
  static const int radix = 58;
  static const int checksumByteLen = 4;

  static const Map<Base58Alphabets, String> alphabets = {
    Base58Alphabets.bitcoin: "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz",
    Base58Alphabets.ripple: "rpshnaf39wBUDNEGHJKLM4PQRST7VWXYZ2bcdeCg65jkm8oFqi1tuvAxyz",
  };
}

class Base58CodecBitcoin extends Codec<Uint8List, String> {
  static const String _alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";
  const Base58CodecBitcoin();

  @override
  Converter<Uint8List, String> get encoder => const Base58Encoder(_alphabet);

  @override
  Converter<String, Uint8List> get decoder => const Base58Decoder(_alphabet, bitcoinListBase58);
}

class Base58CodecFlickr extends Codec<Uint8List, String> {
  static const String _alphabet = "123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ";
  const Base58CodecFlickr();

  @override
  Converter<Uint8List, String> get encoder => const Base58Encoder(_alphabet);

  @override
  Converter<String, Uint8List> get decoder => const Base58Decoder(_alphabet, flickrListBase58);
}

class Base58CodecRipple extends Codec<Uint8List, String> {
  static const String _alphabet = "rpshnaf39wBUDNEGHJKLM4PQRST7VWXYZ2bcdeCg65jkm8oFqi1tuvAxyz";
  const Base58CodecRipple();

  @override
  Converter<Uint8List, String> get encoder => const Base58Encoder(_alphabet);

  @override
  Converter<String, Uint8List> get decoder => const Base58Decoder(_alphabet, rippleListBase58);
}

class Base58CodecCustom extends Codec<Uint8List, String> {
  final String alphabet;
  final List<int> decodeList;
  const Base58CodecCustom({required this.alphabet, required this.decodeList});

  @override
  Converter<Uint8List, String> get encoder => Base58Encoder(alphabet);

  @override
  Converter<String, Uint8List> get decoder => Base58Decoder(alphabet, decodeList);
}

class Base58Encoder extends Converter<Uint8List, String> {
  final String _alphabet;
  const Base58Encoder(this._alphabet);

  @override
  String convert(Uint8List input) {
    final buffer = StringBuffer();
    final length = input.length;

    int zeroCount = 0;
    for (; zeroCount < length && input[zeroCount] == 0;) {
      zeroCount++;
    }
    final data = input.sublist(zeroCount);
    final size = data.length * 138 ~/ 100 + 1;
    final output = Uint8List(size);
    final maxIndex = size - 1;
    for (final byte in data) {
      for (int carry = byte, i = 0; i < maxIndex || carry != 0; i++) {
        carry = carry + 256 * (0xFF & output[i]);
        output[i] = (carry % 58) & 0xFF;
        carry = carry ~/ 58;
      }
    }
    if (zeroCount > 0) buffer.write(_alphabet[0] * zeroCount);
    for (final i in output.reversed.skipWhile((e) => e == 0)) {
      buffer.write(_alphabet[i]);
    }

    return buffer.toString();
  }

  static String encode(List<int> dataBytes, [Base58Alphabets base58alphabets = Base58Alphabets.bitcoin]) {
    final alphabet = Base58Const.alphabets[base58alphabets]!;
    BigInt val = BigintUtil.fromBytes(dataBytes);
    String enc = "";
    while (val > BigInt.zero) {
      final result = BigintUtil.divmod(val, Base58Const.radix);
      val = result.item1;
      final mod = result.item2;
      enc = alphabet[mod.toInt()] + enc;
    }
    int zero = 0;
    for (int byte in dataBytes) {
      if (byte == 0) {
        zero++;
      } else {
        break;
      }
    }
    final int leadingZeros = dataBytes.length - (dataBytes.length - zero);
    return (alphabet[0] * leadingZeros) + enc;
  }

  static String checkEncode(List<int> dataBytes, [Base58Alphabets base58alphabets = Base58Alphabets.bitcoin]) {
    final checksum = Base58Utils.computeChecksum(dataBytes);
    final dataWithChecksum = List<int>.from([...dataBytes, ...checksum]);
    return encode(dataWithChecksum, base58alphabets);
  }
}

class Base58Decoder extends Converter<String, Uint8List> {
  final String _alphabet;
  final List<int> _decodeList;
  const Base58Decoder(this._alphabet, this._decodeList);

  @override
  Uint8List convert(String input) {
    final length = input.length;

    int zeroCount = 0;
    final zero = _alphabet[0];
    for (; zeroCount < length && input[zeroCount] == zero;) {
      zeroCount++;
    }
    final data = input.substring(zeroCount);
    final size = data.length * 733 ~/ 1000 + 1;
    final output = Uint8List(size);
    final maxIndex = size - 1;
    for (final char in data.runes) {
      int carry = _decodeList[char];
      if (carry == -1) {
        throw FormatException(
          'Invalid character detected ${String.fromCharCode(char)}',
        );
      }
      for (int i = 0; i < maxIndex || carry != 0; i++) {
        carry = (carry & 0xFF) + 58 * output[i];
        output[i] = (carry % 256) & 0xFF;
        carry = carry ~/ 256;
      }
    }
    return Uint8List.fromList(
      [...Uint8List(zeroCount), ...output.reversed.skipWhile((e) => e == 0)],
    );
  }

  static List<int> decode(String data, [Base58Alphabets base58alphabets = Base58Alphabets.bitcoin]) {
    final alphabet = Base58Const.alphabets[base58alphabets]!;
    var val = BigInt.zero;

    for (var i = 0; i < data.length; i++) {
      final c = data[data.length - 1 - i];
      final charIndex = alphabet.indexOf(c);
      if (charIndex == -1) {
        throw Exception("Invalid character in Base58 string");
      }
      val += BigInt.from(charIndex) * BigInt.from(Base58Const.radix).pow(i);
    }
    final bytes = BigintUtil.toBytes(val, length: BigintUtil.bitlengthInBytes(val));
    var padLen = 0;
    for (var i = 0; i < data.length; i++) {
      if (data[i] == alphabet[0]) {
        padLen++;
      } else {
        break;
      }
    }
    return List<int>.from([...List<int>.filled(padLen, 0), ...bytes]);
  }

  static List<int> checkDecode(String data, [Base58Alphabets base58alphabets = Base58Alphabets.bitcoin]) {
    final decodedBytes = decode(data, base58alphabets);
    final dataBytes = decodedBytes.sublist(0, decodedBytes.length - Base58Const.checksumByteLen);
    final checksumBytes =
    decodedBytes.sublist(decodedBytes.length - Base58Const.checksumByteLen);

    final computedChecksum = Base58Utils.computeChecksum(dataBytes);
    if (!BytesUtil.bytesEqual(checksumBytes, computedChecksum)) {
      throw Exception(
        "Invalid checksum (expected ${BytesUtil.toHexString(computedChecksum)}, got ${BytesUtil.toHexString(checksumBytes)})",
      );
    }
    return dataBytes;
  }
}

class Base58Utils {
  static List<int> computeChecksum(List<int> dataBytes) {
    final doubleSha256Digest = QuickCrypto.sha256DoubleHash(dataBytes);
    return doubleSha256Digest.sublist(0, Base58Const.checksumByteLen);
  }
}

class Base58XmrConst {
  static String get alphabet => Base58Const.alphabets[Base58Alphabets.bitcoin]!;
  static const int blockDecMaxByteLen = 8;
  static const int blockEncMaxByteLen = 11;
  static const List<int> blockEncByteLens = [0, 2, 3, 5, 6, 7, 9, 10, 11];
}

class Base58XmrEncoder {
  static String encode(List<int> dataBytes) {
    String enc = '';
    final dataLen = dataBytes.length;
    const blockDecLen = Base58XmrConst.blockDecMaxByteLen;
    final totBlockCnt = dataLen ~/ blockDecLen;
    final lastBlockEncLen = dataLen % blockDecLen;

    for (var i = 0; i < totBlockCnt; i++) {
      final blockEnc = Base58Encoder.encode(dataBytes.sublist(i * blockDecLen, (i + 1) * blockDecLen));
      enc += _pad(blockEnc, Base58XmrConst.blockEncMaxByteLen);
    }

    if (lastBlockEncLen > 0) {
      final blockEnc = Base58Encoder.encode(dataBytes.sublist(totBlockCnt * blockDecLen, totBlockCnt * blockDecLen + lastBlockEncLen));
      enc += _pad(blockEnc, Base58XmrConst.blockEncByteLens[lastBlockEncLen]);
    }
    return enc;
  }

  static String _pad(String encStr, int padLen) {
    return encStr.padLeft(padLen, Base58XmrConst.alphabet[0]);
  }
}

class Base58XmrDecoder {
  static List<int> decode(String dataStr) {
    List<int> dec = List.empty();
    final dataLen = dataStr.length;
    const blockDecLen = Base58XmrConst.blockDecMaxByteLen;
    const blockEncLen = Base58XmrConst.blockEncMaxByteLen;
    final totBlockCnt = dataLen ~/ blockEncLen;
    final lastBlockEncLen = dataLen % blockEncLen;
    final lastBlockDecLen = Base58XmrConst.blockEncByteLens.indexOf(lastBlockEncLen);

    for (var i = 0; i < totBlockCnt; i++) {
      final blockDec = Base58Decoder.decode(dataStr.substring(i * blockEncLen, (i + 1) * blockEncLen));
      dec = List<int>.from([...dec, ..._unPad(blockDec, blockDecLen)]);
    }
    if (lastBlockEncLen > 0) {
      final blockDec = Base58Decoder.decode(dataStr.substring(
          totBlockCnt * blockEncLen, totBlockCnt * blockEncLen + lastBlockEncLen));
      dec = List<int>.from([...dec, ..._unPad(blockDec, lastBlockDecLen)]);
    }
    return dec;
  }

  static List<int> _unPad(List<int> decBytes, int unpadLen) {
    final start = decBytes.length - unpadLen;
    return decBytes.sublist(start);
  }
}
