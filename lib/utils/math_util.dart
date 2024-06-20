import 'package:common_utils/common_utils.dart';

class MathUtil {
  num? _start;
  num? current;

  MathUtil({this.current = 0}){
    _start=current;
  }

  static MathUtil startWithStr(String start){
    num temp = NumUtil.getNumByValueStr(start)!;
    return MathUtil(current:temp);
  }
  static MathUtil startWithInt(int start){
    return MathUtil(current: start);
  }
  static MathUtil startWithDouble(double start){
    return MathUtil(current: start);
  }
  static MathUtil start(num start){
    return MathUtil(current: start);
  }

  MathUtil add(num a) {
    current = NumUtil.add(current!, a);
    return this;
  }
  MathUtil addStr(String a) {
    num temp = NumUtil.getNumByValueStr(a)!;
    current = NumUtil.add(current!, temp);
    return this;
  }

  MathUtil subtract(num a) {
    current = NumUtil.subtract(current!, a);
    return this;
  }
  MathUtil subtractStr(String a) {
    num temp = NumUtil.getNumByValueStr(a)!;
    current = NumUtil.subtract(current!, temp);
    return this;
  }

  MathUtil multiply(num a) {
    current = NumUtil.multiply(current!, a);
    return this;
  }
  MathUtil multiplyStr(String a) {
    num temp = NumUtil.getNumByValueStr(a)!;
    current = NumUtil.multiply(current!, temp);
    return this;
  }

  MathUtil divide(num a) {
    current = NumUtil.divide(current!, a);
    return this;
  }
  MathUtil divideStr(String a) {
    num temp = NumUtil.getNumByValueStr(a)!;
    current = NumUtil.divide(current!, temp);
    return this;
  }
  MathUtil reset(){
    current=_start;
    return this;
  }

  @override
  String toString() {
    return current.toString();
  }

  num toNumber() {
    return current!;
  }
}