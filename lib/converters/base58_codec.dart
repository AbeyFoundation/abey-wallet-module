import 'dart:typed_data' show Uint8List;

import 'package:abey_wallet/converters/base58.dart';

const base58 = Base58CodecBitcoin();

String base58Encode(final Uint8List input) => base58.encode(input);

Uint8List base58Decode(final String encoded) => base58.decode(encoded);