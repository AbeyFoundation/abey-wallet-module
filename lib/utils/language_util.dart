import 'package:abey_wallet/resources/Strings.en.dart';
import 'package:abey_wallet/resources/Strings.ko.dart';
import 'package:abey_wallet/resources/Strings.zh.dart';
import 'package:abey_wallet/resources/Strings.ja.dart';
import 'package:get/get.dart';

class LanguageUtil extends Translations {
  Map<String, Map<String, String>>? _keys;

  LanguageUtil() {
    _keys = {
      'en': localizedValueEN,
      'zh': localizedValueZH,
      'ja': localizedValueJA,
      'ko': localizedValueKO,
    };
  }

  @override
  Map<String, Map<String, String>> get keys => _keys!;

}