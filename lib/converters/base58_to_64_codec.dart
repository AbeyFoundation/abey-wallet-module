import 'dart:convert' show Codec, Converter, base64;
import 'package:abey_wallet/converters/base58_codec.dart' show base58;

const base58To64 = Base58To64Codec();

String base58To64Encode(final String base58) => base58To64.encode(base58);

String base58To64Decode(final String base64) => base58To64.decode(base64);

class Base58To64Codec extends Codec<String, String> {
  const Base58To64Codec();

  @override
  Converter<String, String> get decoder => const Base58To64Decoder();

  @override
  Converter<String, String> get encoder => const Base58To64Encoder();
}

class Base58To64Encoder extends Converter<String, String> {
  const Base58To64Encoder();
  
  @override
  String convert(final String input) => base64.encode(base58.decode(input));
}

class Base58To64Decoder extends Converter<String, String> {
  const Base58To64Decoder();
  
  @override
  String convert(final String input) => base58.encode(base64.decode(input));
}