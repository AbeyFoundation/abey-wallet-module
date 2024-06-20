extension IntExtension on int {
  toDecimal() {
    int temp=1;
    for (int i = 0; i < this; i++) {
      temp = temp*10;
    }
    return temp;
  }
}