import 'package:abey_wallet/utils/bytes_util.dart';

class BytesTracker {
  final List<int> _buffer = List.empty(growable: true);

  int get last => _buffer.last;

  List<int> toBytes() {
    return List<int>.from(_buffer);
  }

  void add(List<int> chunk) {
    _buffer.addAll(BytesUtil.toBytes(chunk));
  }
}
