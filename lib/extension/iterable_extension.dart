import 'package:abey_wallet/model/serializable_model.dart';

extension IterableSerializable on Iterable<SerializableMixin> {
  static List<T> fromJson<T extends SerializableMixin, U>(
    final Iterable json, 
    T Function(U) decode,
  ) => json.cast<U>().map(decode).toList(growable: true);

  static List<T>? tryFromJson<T extends SerializableMixin, U>(
    final Iterable? json, 
    T Function(U) decode,
  ) => json != null ? fromJson(json, decode) : null;

  List<T> toJson<T>() => map<T>((final SerializableMixin object) => object.toJson()).toList(growable: false);
}