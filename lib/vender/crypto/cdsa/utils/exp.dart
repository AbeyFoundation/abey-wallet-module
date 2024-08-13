class SquareRootError implements Exception {
  @override
  final String message;

  @override
  final Map<String, dynamic>? details;

  const SquareRootError(this.message, {this.details});

  @override
  String toString() {
    return message;
  }
}

class JacobiError implements Exception {
  @override
  final String message;

  @override
  final Map<String, dynamic>? details;

  const JacobiError(this.message, {this.details});

  @override
  String toString() {
    return message;
  }
}
