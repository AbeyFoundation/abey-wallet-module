abstract class BlockCipher {
  int get blockSize;
  BlockCipher setKey(List<int> key);
  List<int> encryptBlock(List<int> src, [List<int>? dst]);
  List<int> decryptBlock(List<int> src, [List<int>? dst]);
  BlockCipher clean();
}
