import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/callback.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/service/api_data.dart';
import 'package:abey_wallet/utils/math_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:abey_wallet/extension/string_extension.dart';

class FeeDialogWidget extends StatefulWidget {
  final String? contract;
  final List<WalletFeeModel>? data;
  final MapCallback? callback;

  const FeeDialogWidget({Key? key, this.data, this.contract, this.callback})
      : super(key: key);

  @override
  FeeDialogWidgetState createState() => FeeDialogWidgetState();
}

class FeeDialogWidgetState extends State<FeeDialogWidget> {
  String gwei = '1000000000';

  bool showAdvance = false;
  String contract = '';
  List<WalletFeeModel>? walletFeeModelList;
  String _coin = 'ETH';
  String gas_price = '0';
  String gas_limit = '0';
  String gasType = 'fast';
  TextEditingController textEC = TextEditingController();

  @override
  void initState() {
    super.initState();
    contract = widget.contract!;
    walletFeeModelList = widget.data;
    walletFeeModelList!.forEach((element) {
      if (element.type == gasType) {
        gas_price = element.gas_price!;
        gas_limit = element.gas_limit!;
      }
    });
    textEC.text = MathUtil.startWithStr(gas_price).multiplyStr(gwei).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _createContent(),
    );
  }

  Widget _createContent() {
    return GestureDetector(
        child: IntrinsicHeight(
          child: Stack(
            children: [
              Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding:
                    SizeUtil.padding(left: 0, right: 0, bottom: 40, top: 20),
                    width: SizeUtil.screenWidth(),
                    decoration: BoxDecoration(
                        color: ZColors.ZFFFAFAFATheme(context),
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Text(
                            ID.WalletTransferFee.tr,
                            style: AppTheme.text16(),
                          ),
                        ),
                        Container(
                          width: SizeUtil.screenWidth(),
                          margin: SizeUtil.margin(all: 14, right: 14),
                          padding: SizeUtil.padding(all: 10),
                          decoration: BoxDecoration(
                              color: ZColors.ZFFFFFFFFTheme1(context),
                              borderRadius: BorderRadius.all(Radius.circular(6.0)),
                          ),
                          child: Column(
                            children: _buildItem(),
                          ),
                        ),
                        Container(
                          margin: SizeUtil.padding(left: 20,right: 20),
                          width: SizeUtil.screenWidth() - SizeUtil.width(40),
                          child: CustomWidget.buildButtonImage(() {
                            if(widget.callback!=null){
                              widget.callback!({"gas_price":gas_price,"gas_limit":gas_limit});
                            }
                          },text: ID.CommonConfirm.tr),
                        ),
                      ],
                    ),
                  ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildTop() {
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
                  style: AppTheme.text14(),
                ),
                Spacer(),
                Text(
                  "$gas" + widget.contract!,
                  style: AppTheme.text14(),
                ),
              ],
            ),
          ),
          Divider(
            height: SizeUtil.height(15),
            color: ZColors.ZFFE0E0E0,
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

  Widget _buildLabel(left, right) {
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

  List<Widget> _buildItem() {
    List<Widget> items = [
      CustomWidget.buildCard(_buildTop()),
      _buildLabel(ID.WalletTransferGasPrice.tr, ID.WalletTransferTradeTime.tr),
    ];
    walletFeeModelList!.forEach((element) {
      items.add(CustomWidget.buildCard(
          _buildGas(element, () {
            setState(() {
              gasType = element.type!;
              gas_limit = element.gas_limit!;
              gas_price = element.gas_price!;
              textEC.text = MathUtil.startWithStr(gas_price).multiplyStr(gwei).toString();
            });
          }),
          margin: SizeUtil.margin(left: 15, right: 15, top: 4),
          padding: SizeUtil.padding(all: 0)));
    });
    items.add(CustomWidget.buildCard(_buildAdvance(),
        margin: SizeUtil.margin(left: 15, right: 15, top: 10),
        padding: SizeUtil.padding(all: 0)),
    );
    return items;
  }

  Widget _buildAdvance() {
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
                // color: Colors.blue,
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
                  suffixText: "GWEI",
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

  Widget _buildGas(WalletFeeModel fee, callback) {
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
                child: fee.type == gasType ? Icon(
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
                      MathUtil.startWithStr(fee.gas_price!).multiplyStr(gwei).toString()+"GWEI",
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

  @override
  void dispose() {
    super.dispose();
  }
}