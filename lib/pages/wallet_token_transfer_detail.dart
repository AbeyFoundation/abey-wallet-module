import 'dart:io';

import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/global.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/model/coin_model.dart';
import 'package:abey_wallet/pages/common_webview.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/service/api_data.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class WalletTokenTransferDetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletTokenTransferDetailPageState();
  }
}

class WalletTokenTransferDetailPageState extends State<WalletTokenTransferDetailPage> {
  CoinModel? coinModel;
  WalletTokenTransferModel? walletTokenTransferModel;

  String gwei = '1000000000';
  List<String> icons = ['wallet_transfer_success.png','wallet_transfer_fail.png','wallet_transfer_pend.png'];
  int type = 2;//0,1,2

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      if (Get.arguments["walletTokenTransferModel"] != null) {
        walletTokenTransferModel = Get.arguments["walletTokenTransferModel"];
        if (walletTokenTransferModel != null) {
          if (walletTokenTransferModel!.status == 'success') {
            type = 0;
          } else if (walletTokenTransferModel!.status == 'failed') {
            type = 1;
          }
        }
      }
      if (Get.arguments["coinModel"] != null) {
        coinModel = Get.arguments["coinModel"];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZColors.KFFFFFFFFTheme(context),
      appBar: AppbarWidget.initAppBar(context, isBack: true, title: ID.WalletTransferRecord.tr,),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10,),
            CustomWidget.buildCardMargin0(buildTypeCard()),
            CustomWidget.buildCardMargin0(buildAmountCard()),
            CustomWidget.buildCardMargin0(buildInfoCard()),
            CustomWidget.buildCardMargin0(buildDetailCard()),
          ],
        ),
      ),
    );
  }

  Widget buildTypeCard() {
    String text = ID.WalletTransferPending.tr;
    String time = walletTokenTransferModel != null ? walletTokenTransferModel!.time! : '--';
    switch(type){
      case 0:
        text = ID.CommonSuccess.tr;
        break;
      case 1:
        text = ID.CommonFailed.tr;
        break;
      default:
        type=2;
        break;
    }
    return Column(
      children: [
        Image.asset(Constant.Assets_Images + "${icons[type]}",width: SizeUtil.width(42),),
        Padding(padding: SizeUtil.padding(top: 10,bottom: 6),
          child:Text(text,style: AppTheme.text16(fontWeight: FontWeight.w600),),
        ),
        Text(time,style: AppTheme.text12(),),
      ],
    );
  }

  Widget buildAmountCard() {
    return Row(
      children: [
        Text(ID.WalletTransferAmount.tr, style: AppTheme.text14(),),
        Spacer(),
        Text("${walletTokenTransferModel!.type == 'in' ? '+' : '-'}${walletTokenTransferModel!.value} ${coinModel!.symbol}",style: AppTheme.text14(fontWeight: FontWeight.w600),)
      ],
    );
  }

  Widget buildInfoCard() {
    String gas = "";
    if (walletTokenTransferModel!.contract!.toUpperCase() == "TRX") {
      gas = "0";
    } else {
      gas = walletTokenTransferModel!.gas!;
    }

    return Column(
      children: [
        Container(
          padding: SizeUtil.padding(top: 10,bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ID.WalletTransferGas.tr + ":",style: AppTheme.text14(),),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${gas} ${walletTokenTransferModel!.contract??''}',style: AppTheme.text14(fontWeight: FontWeight.w600),),
                  walletTokenTransferModel != null && (walletTokenTransferModel!.contract=='ETH' || walletTokenTransferModel!.contract=='ABEY') ?
                  Text("GasPrice(${walletTokenTransferModel!.gasPrice}GWEI) * Gas(${walletTokenTransferModel!.gasLimit})",style: AppTheme.text14(fontWeight: FontWeight.w600),)
                      :Text('')
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: SizeUtil.padding(top: 10,bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ID.WalletTransferReceiveAddress.tr + ":",style: AppTheme.text14(),),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: walletTokenTransferModel!.to));
                    AlertUtil.showTipsBar(ID.CommonClipboard.tr);
                  },
                  child:Padding(
                    padding: SizeUtil.padding(left: 20,top: 2),
                    child:  Text(walletTokenTransferModel!.to!,
                      style: AppTheme.text14(color: ZColors.ZFFDB8427, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.right,),
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
          padding: SizeUtil.padding(top: 10,bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ID.WalletTransferPayAddress.tr + ":",style: AppTheme.text14(),),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: walletTokenTransferModel!.from));
                    AlertUtil.showTipsBar(ID.CommonClipboard.tr);
                  },
                  child:Padding(
                    padding: SizeUtil.padding(left: 20,top: 2),
                    child:  Text(walletTokenTransferModel!.from!,
                      style: AppTheme.text14(color: ZColors.ZFFDB8427, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.right,),
                  ),
                ),
              )
            ],
          ),
        ),
        Platform.isAndroid || Global.IS_WHEEL == true ? Container(
          padding: SizeUtil.padding(top: 10,bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ID.WalletTransferHash.tr + ":",style: AppTheme.text14(),),
              Expanded(
                child:InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: walletTokenTransferModel!.hash));
                    AlertUtil.showTipsBar(ID.CommonClipboard.tr);
                  },
                  child: Padding(
                    padding: SizeUtil.padding(left: 20,top: 2),
                    child:  Text(walletTokenTransferModel!.hash!,
                      style: AppTheme.text14(color: ZColors.ZFFDB8427, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              )
            ],
          ),
        ) : Container(),
      ],
    );
  }

  Widget buildDetailCard(){
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: (){
        Get.to(CommonWebviewPage(),arguments: {"url":walletTokenTransferModel!.browser});
      },
      child: Row(
        children: [
          Text(ID.WalletTransferLook.tr, style: AppTheme.text14(),),
          Spacer(),
          Icon(Icons.arrow_forward_ios,size: SizeUtil.width(13), color: ZColors.ZFF2D4067Theme(context),)
        ],
      ),
    );
  }
}