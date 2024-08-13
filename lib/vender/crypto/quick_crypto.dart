import 'package:abey_wallet/utils/tuple.dart';
import 'package:abey_wallet/vender/crypto/aes/padding.dart';
import 'package:abey_wallet/vender/crypto/crypto.dart';

class QuickCrypto {
  static List<int> sha256Hash(List<int> data) {
    return SHA256.hash(data);
  }

  static List<int> sha256DoubleHash(List<int> data) {
    List<int> tmp = sha256Hash(data);
    return sha256Hash(tmp);
  }

  static const int sha256DigestSize = 32;

  static List<int> pbkdf2DeriveKey(
      {required List<int> password,
      required List<int> salt,
      required int iterations,
      HashFunc? hash,
      int? dklen}) {
    final hashing = (hash ?? () => SHA512());

    return PBKDF2.deriveKey(
        mac: () => HMAC(hashing, password),
        salt: salt,
        iterations: iterations,
        length: dklen ?? hashing().getDigestLength);
  }

  static List<int> hash160(List<int> data) {
    List<int> tmp = SHA256.hash(data);
    return RIPEMD160.hash(tmp);
  }

  static const int hash160DigestSize = 20;

  static List<int> ripemd160Hash(List<int> data) {
    return RIPEMD160.hash(data);
  }

  static List<int> _blake2bHash(
    List<int> data,
    int digestSize, {
    List<int>? key,
    List<int>? salt,
  }) {
    final hash = BLAKE2b.hash(data, digestSize, Blake2bConfig(key: key, salt: salt));
    return hash;
  }

  static const int blake2b512DigestSize = 64;

  static List<int> blake2b512Hash(
    List<int> data, {
    List<int>? key,
    List<int>? salt,
  }) => _blake2bHash(data, blake2b512DigestSize, key: key, salt: salt);

  static const int blake2b256DigestSize = 32;

  static List<int> blake2b256Hash(
    List<int> data, {
    List<int>? key,
    List<int>? salt,
  }) => _blake2bHash(data, blake2b256DigestSize, key: key, salt: salt);

  static const int blake2b224DigestSize = 28;

  static List<int> blake2b224Hash(
    List<int> data, {
    List<int>? key,
    List<int>? salt,
  }) => _blake2bHash(data, blake2b224DigestSize, key: key, salt: salt);

  static const int blake2b160DigestSize = 20;

  static List<int> blake2b160Hash(
    List<int> data, {
    List<int>? key,
    List<int>? salt,
  }) => _blake2bHash(data, blake2b160DigestSize, key: key, salt: salt);

  static const int blake2b128DigestSize = 16;

  static List<int> blake2b128Hash(
    List<int> data, {
    List<int>? key,
    List<int>? salt,
  }) => _blake2bHash(data, blake2b128DigestSize, key: key, salt: salt);

  static const int blake2b40DigestSize = 5;

  static List<int> blake2b40Hash(
    List<int> data, {
    List<int>? key,
    List<int>? salt,
  }) => _blake2bHash(data, blake2b40DigestSize, key: key, salt: salt);

  static const int blake2b32DigestSize = 4;

  static List<int> blake2b32Hash(
    List<int> data, {
    List<int>? key,
    List<int>? salt,
  }) => _blake2bHash(data, blake2b32DigestSize, key: key, salt: salt);

  static List<int> _xxHash(List<int> data, int digestSize) {
    return XXHash64.hash(data, bitlength: digestSize * 8);
  }

  static const int twoX64DigestSize = 8;
  static List<int> twoX64(List<int> data) {
    return _xxHash(data, twoX64DigestSize);
  }

  static const int twoX128DigestSize = 16;
  static List<int> twoX128(List<int> data) {
    return _xxHash(data, twoX128DigestSize);
  }

  static const int twoX256DigestSize = 32;
  static List<int> twoX256(List<int> data) {
    return _xxHash(data, twoX256DigestSize);
  }

  static List<int> sha512256Hash(List<int> data) {
    return SHA512256.hash(data);
  }

  static List<int> sha512Hash(List<int> data) {
    return SHA512.hash(data);
  }

  static const int sha512DeigestLength = SHA512.digestLength;

  static Tuple<List<int>, List<int>> sha512HashHalves(List<int> data) {
    final hash = SHA512.hash(data);
    const halvesLength = sha512DeigestLength ~/ 2;
    return Tuple(hash.sublist(0, halvesLength), hash.sublist(halvesLength));
  }

  static List<int> keccack256Hash(List<int> data) {
    return Keccack.hash(data, 32);
  }

  static List<int> sha3256Hash(List<int> data) {
    return SHA3256.hash(data);
  }

  static const int sha3256DigestSize = 32;

  static List<int> hmacsha256Hash(List<int> key, List<int> data) {
    final hm = HMAC(() => SHA256(), key);
    hm.update(data);
    return hm.digest();
  }

  static List<int> hmacSha512Hash(List<int> key, List<int> data) {
    final hm = HMAC(() => SHA512(), key);
    hm.update(data);
    return hm.digest();
  }

  static const int hmacSha512DigestSize = 64;

  static Tuple<List<int>, List<int>> hmacSha512HashHalves(List<int> key, List<int> data) {
    final bytes = hmacSha512Hash(key, data);
    return Tuple(bytes.sublist(0, hmacSha512DigestSize ~/ 2), bytes.sublist(hmacSha512DigestSize ~/ 2));
  }

  static List<int> aesCbcEncrypt(List<int> key, List<int> data, {PaddingAlgorithm? paddingAlgorithm}) {
    final ecb = ECB(key);
    return ecb.encryptBlock(data, null, paddingAlgorithm);
  }

  static List<int> aesCbcDecrypt(List<int> key, List<int> data, {PaddingAlgorithm? paddingAlgorithm}) {
    final ecb = ECB(key);
    return ecb.decryptBlock(data, null, paddingAlgorithm);
  }

  static List<int> chaCha20Poly1305Decrypt({
    required List<int> key,
    required List<int> nonce,
    required List<int> cipherText,
    List<int>? assocData,
  }) {
    final chacha = ChaCha20Poly1305(key);
    final decrypt = chacha.decrypt(nonce, cipherText, associatedData: assocData);
    if (decrypt != null) {
      return decrypt;
    }
    throw Exception("ChaCha20-Poly1305 decryption fail");
  }

  static List<int> chaCha20Poly1305Encrypt({
    required List<int> key,
    required List<int> nonce,
    required List<int> plainText,
    List<int>? assocData,
  }) {
    final chacha = ChaCha20Poly1305(key);
    return chacha.encrypt(nonce, plainText, associatedData: assocData);
  }

  static const int chacha20Polu1305Taglenght = 16;
  static const int chacha20Polu1305Keysize = 32;
  static FortunaPRNG? _randomGenerator;

  static GenerateRandom _generateRandom = (length) {
    _randomGenerator ??= FortunaPRNG();
    return _randomGenerator!.nextBytes(length);
  };

  static List<int> generateRandom([int size = 32, GenerateRandom? random]) {
    if (random != null) {
      _generateRandom = random;
    }
    final r = _generateRandom(size);
    return r;
  }

  static List<int> processCtr(
      {required List<int> key,
      required List<int> iv,
      required List<int> data}) {
    final CTR ctr = CTR(AES(key), iv);
    final xor = List<int>.filled(data.length, 0);
    ctr.streamXOR(data, xor);
    ctr.clean();
    return xor;
  }
}
