import "package:abey_wallet/utils/ntcdcrypto_util.dart";

class NTCUtil {
  static List<String>? sssCreate(String content) {
    try {
      NTC sss = NTC();
      List<String> list = sss.create(2, 3, content, true);
      return list;
    } catch(e) {
      return null;
    }
  }

  static String? sssCombine(List<String> list) {
    try {
      NTC sss = NTC();
      String string = sss.combine(list, true);
      return string;
    } catch(e) {
      return null;
    }
  }
}
