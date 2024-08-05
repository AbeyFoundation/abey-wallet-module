import 'dart:typed_data';

import 'package:abey_wallet/converters/base58.dart';
import 'package:abey_wallet/utils/bytes_util.dart';
import 'package:abey_wallet/utils/int_util.dart';
import 'package:abey_wallet/utils/tuple.dart';

class Ss58Const {
  static const int simpleAccountFormatMaxVal = 63;
  static const int formatMaxVal = 16383;
  static const List<int> reservedFormats = [46, 47];
  static final List<int> checksumPrefix = List<int>.unmodifiable(<int>[83, 83, 53, 56, 80, 82, 69]);

  static int checkBytesLen(int dataBytesLength) {
    return [33, 34].contains(dataBytesLength) ? 2 : 1;
  }
}

class Ss58Utils {
  static List<int> computeChecksum(List<int> dataBytes) {
    final prefixAndData = List<int>.from([...Ss58Const.checksumPrefix, ...dataBytes]);
    return QuickCrypto.blake2b512Hash(prefixAndData).sublist(0, Ss58Const.checkBytesLen(dataBytes.length));
  }
}

class SS58Encoder {
  static String encode(List<int> dataBytes, int ss58Format) {
    if (ss58Format < 0 || ss58Format > Ss58Const.formatMaxVal) {
      throw Exception('Invalid SS58 format ($ss58Format)');
    }
    if (Ss58Const.reservedFormats.contains(ss58Format)) {
      throw Exception('Invalid SS58 format ($ss58Format)');
    }

    List<int> ss58FormatBytes;

    if (ss58Format <= Ss58Const.simpleAccountFormatMaxVal) {
      ss58FormatBytes = IntUtil.toBytes(ss58Format, length: IntUtil.bitlengthInBytes(ss58Format), byteOrder: Endian.little);
    } else {
      ss58FormatBytes = List<int>.from([
        ((ss58Format & 0x00FC) >> 2) | 0x0040,
        (ss58Format >> 8) | ((ss58Format & 0x0003) << 6)
      ]);
    }
    final payload = List<int>.from([...ss58FormatBytes, ...dataBytes]);
    final checksum = Ss58Utils.computeChecksum(payload);
    return Base58Encoder.encode(List<int>.from([...payload, ...checksum]));
  }
}

class SS58Decoder {
  static Tuple<int, List<int>> decode(String dataStr) {
    final decBytes = Base58Decoder.decode(dataStr);

    int ss58Format;
    int ss58FormatLen;

    if ((decBytes[0] & 0x40) != 0) {
      ss58FormatLen = 2;
      ss58Format = ((decBytes[0] & 0x3F) << 2) | (decBytes[1] >> 6) | ((decBytes[1] & 0x3F) << 8);
    } else {
      ss58FormatLen = 1;
      ss58Format = decBytes[0];
    }

    if (Ss58Const.reservedFormats.contains(ss58Format)) {
      throw Exception('Invalid SS58 format ($ss58Format)');
    }
    final int checkSumLength = Ss58Const.checkBytesLen(decBytes.length - ss58FormatLen);
    final dataBytes = List<int>.from(decBytes.sublist(ss58FormatLen, decBytes.length - checkSumLength));
    final checksumBytes = List<int>.unmodifiable(decBytes.sublist(decBytes.length - checkSumLength));
    final checksumBytesGot = Ss58Utils.computeChecksum(decBytes.sublist(0, decBytes.length - checkSumLength));
    if (!BytesUtil.bytesEqual(checksumBytesGot, checksumBytes)) {
      throw Exception(
          'Invalid checksum (expected ${BytesUtil.toHexString(checksumBytesGot)}, '
          'got ${BytesUtil.toHexString(checksumBytes)})');
    }

    return Tuple(ss58Format, dataBytes);
  }
}
