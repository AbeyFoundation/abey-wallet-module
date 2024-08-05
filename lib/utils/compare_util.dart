class CompareUtil {
  static bool iterableIsEqual<T>(Iterable<T>? a, Iterable<T>? b) {
    if (a == null) {
      return b == null;
    }
    if (b == null || a.length != b.length) {
      return false;
    }
    if (identical(a, b)) {
      return true;
    }
    for (int index = 0; index < a.length; index += 1) {
      if (a.elementAt(index) != b.elementAt(index)) {
        return false;
      }
    }
    return true;
  }
}
