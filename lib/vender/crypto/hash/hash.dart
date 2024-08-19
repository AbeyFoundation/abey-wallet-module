library hash;

import 'dart:math' as math;

import 'package:abey_wallet/utils/binary_util.dart';
import 'package:abey_wallet/utils/bytes_util.dart';

part 'sha224/sha224.dart';
part 'sha256/sha256.dart';
part 'sha384/sha384.dart';
part 'sha512/sha512.dart';
part 'sha512_256/sh512256.dart';
part 'sha1/sha1.dart';
part 'black2b/black2b.dart';
part 'ridemp/ridemp.dart';
part 'md5/md5.dart';
part 'md4/md4.dart';
part 'keccack/sha3.dart';

part 'xxhash64/xxhash64.dart';

typedef HashFunc = SerializableHash Function();

abstract class Hash {
  int get getDigestLength;
  int get getBlockSize;
  Hash update(List<int> data);
  Hash reset();
  Hash finish(List<int> out);
  List<int> digest();
  void clean();
}

abstract class SerializableHash<T extends HashState> extends Hash {
  HashState saveState();

  SerializableHash restoreState(T savedState);

  void cleanSavedState(T savedState);
}

abstract class HashState {}
