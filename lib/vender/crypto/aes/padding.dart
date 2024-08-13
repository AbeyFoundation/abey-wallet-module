enum PaddingAlgorithm { pkcs7, iso7816, x923 }

class BlockCipherPadding {
  static List<int> pad(List<int> dataToPad, int blockSize, {PaddingAlgorithm style = PaddingAlgorithm.pkcs7}) {
    int paddingLen = blockSize - dataToPad.length % blockSize;
    List<int> padding;
    if (style == PaddingAlgorithm.pkcs7) {
      padding = List<int>.filled(paddingLen, 0);
      for (int i = 0; i < paddingLen; i++) {
        padding[i] = paddingLen;
      }
    } else if (style == PaddingAlgorithm.x923) {
      padding = List<int>.filled(paddingLen, 0);
      for (int i = 0; i < paddingLen - 1; i++) {
        padding[i] = 0;
      }
      padding[paddingLen - 1] = paddingLen;
    } else {
      padding = List<int>.filled(paddingLen, 0);
      padding[0] = 128;
      for (int i = 1; i < paddingLen; i++) {
        padding[i] = 0;
      }
    }
    List<int> result = List<int>.filled(dataToPad.length + paddingLen, 0);
    result.setAll(0, dataToPad);
    result.setAll(dataToPad.length, padding);
    return result;
  }

  static List<int> unpad(List<int> paddedData, int blockSize, {PaddingAlgorithm style = PaddingAlgorithm.pkcs7}) {
    int paddedDataLen = paddedData.length;
    if (paddedDataLen == 0) {
      throw Exception('Zero-length input cannot be unpadded');
    }
    if (paddedDataLen % blockSize != 0) {
      throw Exception('Input data is not padded');
    }
    int paddingLen;
    if (style == PaddingAlgorithm.pkcs7 || style == PaddingAlgorithm.x923) {
      paddingLen = paddedData[paddedDataLen - 1];
      if (paddingLen < 1 || paddingLen > blockSize) {
        throw Exception('incorrect padding');
      }
      if (style == PaddingAlgorithm.pkcs7) {
        for (int i = 1; i <= paddingLen; i++) {
          if (paddedData[paddedDataLen - i] != paddingLen) {
            throw Exception('incorrect padding');
          }
        }
      } else {
        for (int i = 1; i < paddingLen; i++) {
          if (paddedData[paddedDataLen - i - 1] != 0) {
            throw Exception('incorrect padding');
          }
        }
      }
    } else {
      int index = paddedData.lastIndexOf(128);
      if (index < 0) {
        throw Exception('incorrect padding');
      }
      paddingLen = paddedDataLen - index;
      if (paddingLen < 1 || paddingLen > blockSize) {
        throw Exception('incorrect padding');
      }
      for (int i = 1; i < paddingLen; i++) {
        if (paddedData[index + i] != 0) {
          throw Exception('incorrect padding');
        }
      }
    }
    return paddedData.sublist(0, paddedDataLen - paddingLen);
  }
}
