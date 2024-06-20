import 'package:abey_wallet/model/coin_model.dart';
import 'package:abey_wallet/service/api_data.dart';

typedef VoidCallback = void Function();
typedef StringCallback = void Function(String data);
typedef NumberCallback = void Function(num data);
typedef BoolCallback = void Function(bool data);
typedef MapCallback = void Function(Map data);
typedef JSCallback = void Function(Map<String,dynamic> data);
typedef PasswordCallback = Function(String data, bool goback);
typedef CoinModelCallback = void Function(CoinModel coinModel);
typedef KyfModelCallback = void Function(KyfModel kyfModel);
