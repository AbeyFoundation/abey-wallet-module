import 'dart:async' show Completer, FutureOr;

class SafeCompleter<T> implements Completer<T> {
  SafeCompleter._(this._completer);

  factory SafeCompleter() => SafeCompleter<T>._(Completer<T>());

  factory SafeCompleter.sync() => SafeCompleter<T>._(Completer<T>.sync());

  final Completer<T> _completer;

  @override
  void complete([final FutureOr<T>? value]) {
    if (!isCompleted) _completer.complete(value);
  }

  @override
  void completeError(final Object error, [final StackTrace? stackTrace]) {
    if (!isCompleted) _completer.completeError(error, stackTrace);
  }

  @override
  Future<T> get future => _completer.future;

  @override
  bool get isCompleted => _completer.isCompleted;
}