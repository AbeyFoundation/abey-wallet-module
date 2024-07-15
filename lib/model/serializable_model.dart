abstract class Serializable with SerializableMixin {
  const Serializable();
}

mixin SerializableMixin {
  static UnimplementedError _unimplementedError(final String method) => UnimplementedError('Derived classes of [SerializableMixin] must implement [$method].');

  static Object fromJson(final dynamic json) => throw _unimplementedError('fromJson');

  static Object? tryFromJson(final dynamic json) => _unimplementedError('tryFromJson');

  dynamic toJson();
}