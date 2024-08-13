import 'package:abey_wallet/vender/crypto/aes/aes.dart';
import 'package:abey_wallet/vender/crypto/aes/padding.dart';

class ECB extends AES {
  ECB(List<int> key) : super(key);

  @override
  List<int> encryptBlock(List<int> src, [List<int>? dst, PaddingAlgorithm? paddingStyle = PaddingAlgorithm.pkcs7]) {
    if (paddingStyle == null) {
      if ((src.length % blockSize) != 0) {
        throw Exception("src size must be a multiple of $blockSize");
      }
    }
    List<int> input = List<int>.from(src);
    if (paddingStyle != null) {
      input = BlockCipherPadding.pad(input, blockSize, style: paddingStyle);
    }

    final out = dst ?? List<int>.filled(input.length, 0);
    if (out.length != input.length) {
      throw Exception("The destination size does not match with source size");
    }
    final numBlocks = input.length ~/ blockSize;
    for (var i = 0; i < numBlocks; i++) {
      final start = i * blockSize;
      final end = (i + 1) * blockSize;
      List<int> block = List<int>.from(input.sublist(start, end));
      final enc = super.encryptBlock(block);
      out.setRange(start, end, enc);
    }
    return out;
  }

  @override
  List<int> decryptBlock(List<int> src, [List<int>? dst, PaddingAlgorithm? paddingStyle = PaddingAlgorithm.pkcs7]) {
    if ((src.length % blockSize) != 0) {
      throw Exception("src size must be a multiple of $blockSize");
    }
    List<int> out = List<int>.filled(src.length, 0);
    final numBlocks = src.length ~/ blockSize;
    for (var i = 0; i < numBlocks; i++) {
      final start = i * blockSize;
      final end = (i + 1) * blockSize;
      final enc = super.decryptBlock(src.sublist(start, end));
      out.setRange(start, end, enc);
    }
    if (paddingStyle != null) {
      out = BlockCipherPadding.unpad(out, blockSize, style: paddingStyle);
    }
    if (dst != null) {
      if (dst.length < out.length) {
        throw Exception("Destination size is small");
      }
      dst.setAll(0, out);
      return dst;
    }
    return out;
  }
}
