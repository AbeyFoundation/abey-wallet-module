import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/model/coin_model.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/service/api_data.dart';
import 'package:abey_wallet/utils/math_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:abey_wallet/extension/string_extension.dart';

class WalletFeePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletFeePageState();
  }
}

class WalletFeePageState extends State<WalletFeePage> {
  String gwei = '1000000000';

  CoinModel? coinModel;
  List<WalletFeeModel>?  walletFeeModelList;

  TextEditingController textEC = TextEditingController();

  String gasType = 'fast';
  String gas_price = '0';
  String gas_price_str = '0';
  String gas_limit = '0';

  bool showAdvance = false;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      if (Get.arguments['coinModel'] != null) {
        coinModel = Get.arguments["coinModel"];
      }
      if (Get.arguments['data'] != null) {
        walletFeeModelList = Get.arguments["data"];
        if (walletFeeModelList != null && walletFeeModelList!.length > 0) {
          walletFeeModelList!.forEach((element) {
            if (element.type == gasType) {
              gas_price_str = element.gas_price_str!;
              gas_price = element.gas_price!;
              gas_limit = element.gas_limit!;

              textEC.text = MathUtil.startWithStr(gas_price).multiplyStr(gwei).toString();
            }
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus!.unfocus();
        }
      },
      onPanDown: (_) {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus!.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: ZColors.KFFFFFFFFTheme(context),
        appBar: AppbarWidget.initAppBar(context, isBack: true,title: ID.WalletTransferFee.tr,),
        body: Container(
          height: double.infinity,
          child: SingleChildScrollView(
            child: Container(
              width: SizeUtil.screenWidth(),
              child: Column(
                children: buildContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildItems() {
    List<Widget> items = [];
    if (walletFeeModelList != null && walletFeeModelList!.length > 0) {
      walletFeeModelList!.forEach((element) {
        items.add(CustomWidget.buildCard(
            buildGas(element, () {
              setState(() {
                gasType = element.type!;
                gas_limit = element.gas_limit!;
                gas_price = element.gas_price!;
                textEC.text = MathUtil.startWithStr(gas_price).multiplyStr(gwei).toString();
              });
            }),
            margin: SizeUtil.margin(left: 12, right: 12, top: 4),
            padding: SizeUtil.padding(all: 0))
        );
      });
    }
    return items;
  }

  List<Widget> buildContent() {
    List<Widget> items = [
      SizedBox(height: 10,),
      Container(
        margin: SizeUtil.margin(left: 12, right: 12),
        padding: SizeUtil.padding(left: 10, right: 10, top: 12, bottom: 12),
        decoration: BoxDecoration(
          color: ZColors.KFFF9FAFBTheme(context),
          border: new Border.all(color: Colors.grey[200]!, width: 1,),
          borderRadius: SizeUtil.radius(all: 10),
        ),
        child: CustomWidget.buildCardMargin0(buildTop()),
      ),
      buildLabel(ID.WalletTransferGasPrice.tr, ID.WalletTransferTradeTime.tr),
    ];
    items.add(Container(
      margin: SizeUtil.margin(left: 12, right: 12, top: 4, bottom: 12),
      padding: SizeUtil.padding(top: 9, bottom: 12),
      decoration: BoxDecoration(
        color: ZColors.KFFF9FAFBTheme(context),
        border: new Border.all(color: Colors.grey[200]!, width: 1,),
        borderRadius: SizeUtil.radius(all: 10),
      ),
      child: Column(
        children: buildItems(),
      ),
    ));
    items.add(Container(
      margin: SizeUtil.margin(left: 12, right: 12, top: 12, bottom: 12),
      padding: SizeUtil.padding(top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: ZColors.KFFF9FAFBTheme(context),
        border: new Border.all(color: Colors.grey[200]!, width: 1,),
        borderRadius: SizeUtil.radius(all: 10),
      ),
      child: CustomWidget.buildCard(buildAdvance()),
    ));
    items.add(buildButton());
    return items;
  }

  Widget buildTop() {
    String gas = MathUtil.startWithStr(gas_limit).multiplyStr(gas_price).toString();
    String gasPrice = MathUtil.startWithStr(gas_price).multiplyStr(gwei).toString();

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            child: Row(
              children: [
                Text(
                  ID.WalletTransferFee.tr,
                  style: AppTheme.text14(fontWeight: FontWeight.w600),
                ),
                Spacer(),
                Text(
                  gas + " " + coinModel!.contract!,
                  style: AppTheme.text14(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Divider(
            height: SizeUtil.height(15),
            color: ZColors.ZFFF2F2F2Theme(context),
          ),
          Container(
            child: Text(
              "Gas Price(${gasPrice}GWEI) * Gas(${gas_limit})",
              textAlign: TextAlign.right,
              style: AppTheme.text12(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLabel(left, right) {
    return Container(
      padding: SizeUtil.padding(left: 20, right: 20, top: 20, bottom: 10),
      child: Row(
        children: [
          Text(
            left,
            style: AppTheme.text14(),
          ),
          Spacer(),
          Text(
            right,
            style: AppTheme.text14(),
          )
        ],
      ),
    );
  }

  Widget buildGas(WalletFeeModel fee, callback) {
    return Material(
      color: ZColors.ZFFFFFFFFTheme(context),
      child: InkWell(
        onTap: () {
          if (callback != null) {
            callback();
          }
        },
        child: Container(
          padding: SizeUtil.padding(all: 5),
          child: Row(
            children: [
              Container(
                width: SizeUtil.width(40),
                height: SizeUtil.width(40),
                child: fee.type == gasType
                    ? Icon(
                  Icons.done,
                  color: ZColors.ZFFEECC5B,
                ) : Container(),
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fee.type!.tr,
                      style: AppTheme.text14(),
                    ),
                    Text(
                      '${MathUtil.startWithStr(fee.gas_price!).multiplyStr(gwei).toString()} GWEI',
                      style: AppTheme.text12(),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Container(
                padding: SizeUtil.padding(right: 10),
                child: Text(
                  "< ${fee.time}${ID.WalletTransferMin.tr}",
                  style: AppTheme.text12(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAdvance() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: ZColors.ZFFFFFFFFTheme(context),
            child: InkWell(
              onTap: () {
                setState(() {
                  showAdvance = !showAdvance;
                });
              },
              child: Container(
                padding: SizeUtil.padding(all: 10),
                width: double.infinity,
                child: Text(
                  ID.WalletTransferAdvance.tr,
                  style: AppTheme.text14(),
                ),
              ),
            ),
          ),
          Divider(
            height: 1,
            color: ZColors.ZFFF2F2F2Theme(context),
          ),
          showAdvance ? Container(
            padding: SizeUtil.padding(left: 15, right: 15),
            child: TextField(
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Colors.transparent,
                  filled: false,
                  suffixText: "GWEI"
              ),
              textAlign: TextAlign.left,
              style: AppTheme.text12(),
              controller: textEC,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
              ],
              onChanged: (text) {
                if (text.isEmptyString()) {
                  text = '0';
                }
                setState(() {
                  gas_price = MathUtil.startWithStr(text).divideStr(gwei).toString();
                });
              },
            ),
          ) : Container(),
        ],
      ),
    );
  }

  Widget buildButton() {
    return Container(
      margin: EdgeInsets.only(left: 20,right: 20, bottom: 40),
      child: CustomWidget.buildButtonImage(() {
        Get.back(result:{"gas_price": gas_price,"gas_price_str": gas_price_str, "gas_limit": gas_limit},closeOverlays:true);
      },text: ID.CommonConfirm.tr),
    );
  }
}