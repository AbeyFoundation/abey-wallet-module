extension ListExtension on List {
  void forEachWithIndex(void function(int index,element)) {
    int index = 0;
    for (var element in this) {
      function(index,element);
      index++;
    }
  }
}