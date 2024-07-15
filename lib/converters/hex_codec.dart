import 'dart:typed_data' show Uint8List;

import 'package:abey_wallet/converters/base16.dart';

const hex = Base16Codec();

String hexEncode(final Uint8List input) => hex.encode(input);

Uint8List hexDecode(final String encoded) => hex.decode(encoded);