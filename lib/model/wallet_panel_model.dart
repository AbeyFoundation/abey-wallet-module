import 'package:abey_wallet/model/coin_model.dart';

class WalletPanelModel {
  CoinModel? coinModel;
  List<CoinModel>? coinModelList;
  bool? isExpanded = false;

  WalletPanelModel({this.coinModel, this.coinModelList, this.isExpanded = false});
}