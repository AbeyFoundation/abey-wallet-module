import 'dart:math' as math;
import 'package:abey_wallet/utils/bytes_util.dart';

class UUIDUtil {
  static String generateUUIDv4() {
    final random = math.Random.secure();

    final bytes = List<int>.generate(16, (i) {
      if (i == 6) {
        return (random.nextInt(16) & 0x0f) | 0x40;
      } else if (i == 8) {
        return (random.nextInt(4) & 0x03) | 0x08;
      } else {
        return random.nextInt(256);
      }
    });

    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final List<String> hexBytes = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).toList();

    return '${hexBytes.sublist(0, 4).join('')}-${hexBytes.sublist(4, 6).join('')}-'
        '${hexBytes.sublist(6, 8).join('')}-${hexBytes.sublist(8, 10).join('')}-'
        '${hexBytes.sublist(10).join('')}';
  }

  static List<int> toBuffer(String uuidString, {bool validate = true}) {
    if (validate && !isValidUUIDv4(uuidString)) {
      throw Exception("invalid uuid string." + {"uuid": uuidString}.toString());
    }
    final buffer = List<int>.filled(16, 0);
    final cleanUuidString = uuidString.replaceAll('-', '');
    final bytes = BytesUtil.fromHexString(cleanUuidString);
    for (var i = 0; i < 16; i++) {
      buffer[i] = bytes[i];
    }
    return buffer;
  }

  static String fromBuffer(List<int> buffer) {
    if (buffer.length != 16) {
      throw Exception('Invalid buffer length. UUIDv4 buffers must be 16 bytes long.');
    }
    final List<String> hexBytes = buffer.map((byte) => byte.toRadixString(16).padLeft(2, '0')).toList();
    return '${hexBytes.sublist(0, 4).join('')}-${hexBytes.sublist(4, 6).join('')}-${hexBytes.sublist(6, 8).join('')}-${hexBytes.sublist(8, 10).join('')}-${hexBytes.sublist(10).join('')}';
  }

  static final _pattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );

  static bool isValidUUIDv4(String uuid) {
    return _pattern.hasMatch(uuid);
  }
}
