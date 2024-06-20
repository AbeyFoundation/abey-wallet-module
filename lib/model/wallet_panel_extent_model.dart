import 'package:abey_wallet/model/coin_model.dart';
import 'package:flutter/material.dart';

class WalletPanelExtentModel {
  final CoinModel? coinModel;
  final Widget? body;
  bool? isExpanded = false;

  WalletPanelExtentModel({this.coinModel, this.body, this.isExpanded = false});
}