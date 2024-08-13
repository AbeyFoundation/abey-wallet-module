abstract class AEAD {
  int get nonceLength;
  int get tagLength;
  List<int> encrypt(List<int> nonce, List<int> plaintext, {List<int>? associatedData, List<int>? dst});
  List<int>? decrypt(List<int> nonce, List<int> ciphertext, {List<int>? associatedData, List<int>? dst});
  AEAD clean();
}
