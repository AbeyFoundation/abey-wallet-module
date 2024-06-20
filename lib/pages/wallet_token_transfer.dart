import 'dart:convert';

import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/event/event.dart';
import 'package:abey_wallet/model/coin_model.dart';
import 'package:abey_wallet/pages/common_scan.dart';
import 'package:abey_wallet/pages/wallet_address.dart';
import 'package:abey_wallet/pages/wallet_fee.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/service/api_data.dart';
import 'package:abey_wallet/service/api_manager.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/chain_util.dart';
import 'package:abey_wallet/utils/common_util.dart';
import 'package:abey_wallet/utils/console_util.dart';
import 'package:abey_wallet/utils/database_util.dart';
import 'package:abey_wallet/utils/math_util.dart';
import 'package:abey_wallet/utils/password_util.dart';
import 'package:abey_wallet/utils/preferences_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/vender/chain/chain_exp.dart';
import 'package:abey_wallet/vender/chain/chaincore.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:abey_wallet/widget/dialog/transfer_dialog_widget.dart';
import 'package:abey_wallet/widget/dialog/transfer_trx_dialog_widget.dart';
import 'package:abey_wallet/widget/dialog/transfer_finish_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:abey_wallet/extension/string_extension.dart';

class WalletTokenTransferPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletTokenTransferPageState();
  }
}

class WalletTokenTransferPageState extends State<WalletTokenTransferPage> {
  CoinModel? coinModel;

  String gwei = '1000000000';
  String amount = '0.0';

  String coin = '';
  String gas_price_str = '0.0000';
  String gas_price = '0.0000';
  String gas_limit = '21000';

  String csUnit = '';

  String value = '0';
  String to = '';
  String from = '';
  String hash = '';

  bool isTron = false;
  List<WalletFeeModel>? walletFeeModelList;
  WalletFeeModel? walletFeeModel;
  List<WalletFeeTrxModel>? walletFeeTrxModelList;
  WalletFeeTrxModel? walletFeeTrxModel;
  String? nonce;

  TextEditingController _addressEC = TextEditingController();
  TextEditingController _amountEC = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null && Get.arguments["coinModel"] != null) {
      coinModel = Get.arguments["coinModel"];
      if (coinModel!.contract != null && coinModel!.contract!.toUpperCase() == "TRX") {
        isTron = true;
      } else {
        isTron = false;
      }
      coin = coinModel!.symbol!;
      from = coinModel!.address!;
      csUnit = coinModel!.csUnit!;
      amount = coinModel!.balance!;

      requestFees();
    }

    eventBus.on<UpdateTrade>().listen((event) {
      tradeAction();
    });
  }

  void requestFees() async {
    var inputData = "";
    if (coinModel != null && coinModel?.contract != null && coinModel?.contract == "TRX") {
      ApiData apiData = await ApiManager.postWalletFees(data: {
        "symbol": coinModel!.symbol,
        "address": coinModel!.address,
        "contract": coinModel!.contract,
        "contractAddress": coinModel!.contractAddress,
      });
      if (apiData.code == 0) {
        if (coinModel != null && coinModel?.contract != null && coinModel?.contract == "TRX") {
          WalletFeeTrxListModel walletFeeTrxListModel = WalletFeeTrxListModel.fromJson(apiData.data);
          if (walletFeeTrxListModel != null) {
            walletFeeTrxListModel.items!.forEach((element) {
              if (element.type == "general") {
                walletFeeTrxModel = element;
                gas_price_str = walletFeeTrxModel!.gas_price!;
                gas_price = walletFeeTrxModel!.gas_price!;
                gas_limit = walletFeeTrxModel!.gas_limit!;
              }
            });
            this.walletFeeTrxModelList = walletFeeTrxListModel.items;
            if (mounted) {
              setState(() {
              });
            }
          }
        } else {
          WalletFeeListModel walletFeeListModel = WalletFeeListModel.fromJson(apiData.data);
          if (walletFeeListModel != null) {
            walletFeeListModel.items!.forEach((element) {
              if (element.type == "general") {
                walletFeeModel = element;
                gas_price_str = walletFeeModel!.gas_price_str!;
                gas_price = walletFeeModel!.gas_price!;
                gas_limit = walletFeeModel!.gas_limit!;
              }
            });
            this.walletFeeModelList = walletFeeListModel.items;
            if (mounted) {
              setState(() {
              });
            }
          }
        }
      } else {
        AlertUtil.showWarnBar(ID.CommonNetworkError.tr);
      }
    } else {
      if (coinModel!.contractAddress!.isNotEmptyString()) {
        inputData = await requestInputCommon();
        if (inputData != null) {
          if (inputData.indexOf("{") >= 0) {
            inputData = json.decode(inputData);
          }
        } else {
          inputData = "";
        }
      }

      ApiData apiData = await ApiManager.postWalletFees(data: {
        "symbol": coinModel!.symbol,
        "address": coinModel!.address,
        "contract": coinModel!.contract,
        "contractAddress": coinModel!.contractAddress,
        "from": from,
        "to": coinModel!.contractAddress!.isNotEmptyString() ? coinModel!.contractAddress : "",
        "value": "1",
        "data": inputData
      });
      if (apiData.code == 0) {
        if (coinModel != null && coinModel?.contract != null && coinModel?.contract == "TRX") {
          WalletFeeTrxListModel walletFeeTrxListModel = WalletFeeTrxListModel.fromJson(apiData.data);
          if (walletFeeTrxListModel != null) {
            walletFeeTrxListModel.items!.forEach((element) {
              if (element.type == "general") {
                walletFeeTrxModel = element;
                gas_price_str = walletFeeTrxModel!.gas_price!;
                gas_price = walletFeeTrxModel!.gas_price!;
                gas_limit = walletFeeTrxModel!.gas_limit!;
              }
            });
            this.walletFeeTrxModelList = walletFeeTrxListModel.items;
            if (mounted) {
              setState(() {
              });
            }
          }
        } else {
          WalletFeeListModel walletFeeListModel = WalletFeeListModel.fromJson(apiData.data);
          if (walletFeeListModel != null) {
            walletFeeListModel.items!.forEach((element) {
              if (element.type == "general") {
                walletFeeModel = element;
                gas_price_str = walletFeeModel!.gas_price_str!;
                gas_price = walletFeeModel!.gas_price!;
                gas_limit = walletFeeModel!.gas_limit!;
              }
            });
            this.walletFeeModelList = walletFeeListModel.items;
            if (mounted) {
              setState(() {
              });
            }
          }
        }
      } else {
        AlertUtil.showWarnBar(ID.CommonNetworkError.tr);
      }
    }
  }

  void tradeAction() {
    Navigator.pop(context);
  }

  requestNonce() async {
    ApiData apiData = await ApiManager.postWalletNonce(data: {"address": coinModel!.address, "contract": coinModel!.contract});
    if (apiData.code == 0) {
      WalletNonceModel walletNonceModel = WalletNonceModel.fromJson(apiData.data);
      if (walletNonceModel != null) {
        if (mounted) {
          setState(() {
            nonce = walletNonceModel.nonce;
          });
        }
      }
    }
  }

  requestInputCommon() async {
    ApiData apiData = await ApiManager.postWalletTokenData(data: {
      "from": coinModel!.address,
      "value": "1",
      "to": coinModel!.contract == "TRX" ? "TGKxBCededHRec9LBTrWFUxkCqHAqSoeZN" : "0x1a69641f3b12179e2978fE71c3576ED90025cC4f",
      "contract": coinModel!.contract,
      "contractAddress": coinModel!.contractAddress
    });
    if (apiData.code == 0) {
      WalletInputModel walletInputModel = WalletInputModel.fromJson(apiData.data);
      if (walletInputModel != null) {
        return walletInputModel.inputData;
      }
    } else {}
    return "";
  }

  requestInput(value) async {
    ApiData apiData = await ApiManager.postWalletTokenData(data: {
      "from": coinModel!.address,
      "value": value,
      "to": to.isEmptyString() ? _addressEC.text : to,
      "contract": coinModel!.contract,
      "contractAddress": coinModel!.contractAddress
    });
    if (apiData.code == 0) {
      WalletInputModel walletInputModel = WalletInputModel.fromJson(apiData.data);
      if (walletInputModel != null) {
        return walletInputModel.inputData;
      }
    } else {}
    return "";
  }

  void scanAction() {
    Get.to(CommonScanPage(
      callback: (barcode) async {
        barcode = barcode.trim();
        if (barcode.isNotEmptyString()) {
          setState(() {
            to = barcode;
            _addressEC.text = barcode;
            _addressEC.selection = TextSelection.fromPosition(TextPosition(affinity: TextAffinity.downstream, offset: _addressEC.text.length));
          });
        }
      },
    ));
  }

  void selectAddressAction() async {
    var result = await Get.to(WalletAddressPage(), arguments: {});
    if (result != null) {
      String address = result['address'];
      if (address.isNotEmptyString()) {
        if (mounted) {
          setState(() {
            to = address;
            _addressEC.text = address;
            _addressEC.selection = TextSelection.fromPosition(TextPosition(affinity: TextAffinity.downstream, offset: _addressEC.text.length));
          });
        }
      }
    }
  }

  Future checkAction() async {
    if (_addressEC.text.isEmptyString()) {
      AlertUtil.showWarnBar(ID.WalletInputReceiveAddress.tr);
      return Future.value(false);
    }
    if (_addressEC.text.isNotEmptyString()) {
      if (coinModel != null && coinModel?.contract != null && coinModel?.contract == "TRX") {
        if (_addressEC.text != null && _addressEC.text.length == 34 && _addressEC.text.startsWith("T")) {

        } else {
          AlertUtil.showWarnBar(ID.WalletInputReceiveAddress.tr);
          return Future.value(false);
        }
      } else {
        String isAddress = await ChainUtil.vertityAddress(context, "ETH", _addressEC.text.toLowerCase());
        if (isAddress == "false") {
          AlertUtil.showWarnBar(ID.WalletInputReceiveAddress.tr);
          return Future.value(false);
        }
      }
    }
    if (_amountEC.text.isEmptyString()) {
      AlertUtil.showWarnBar(ID.WalletInputAmount.tr);
      return Future.value(false);
    }
    double fee = 0;
    if (coinModel!.symbol == coinModel!.contract) {
      String gas = MathUtil.startWithStr(gas_limit).multiplyStr(gas_price).toString();
      fee = gas.toDouble();
    }

    double transAmount = _amountEC.text.toDouble();
    double balance = amount.toDouble();
    if (transAmount + fee > balance) {
      AlertUtil.showWarnBar(ID.WalletBalanceUnenough.tr);
      return Future.value(false);
    }

    return Future.value(true);
  }

  void transferBtnAction() async {
    var result = await checkAction();
    if (!result) {
      return;
    }
    await showDialog(
        useSafeArea: false,
        context: context,
        builder: (cotext) {
      if (coinModel != null && coinModel?.contract != null && coinModel?.contract == "TRX") {
        return TransferTrxDialogWidget(
          coin: coinModel!.symbol!,
          from: coinModel!.address!,
          to: to.isEmptyString() ? _addressEC.text : to,
          amount: _amountEC.text,
          contract: coinModel!.contract ?? coinModel!.symbol!,
          contractAddress: coinModel!.contractAddress!,
          fee: walletFeeTrxModel != null ? walletFeeTrxModel : new WalletFeeTrxModel(fee: "1"),
          callback: () async {
            Get.back();

            await PasswordUtil.handlePassword(context, (text, goback) async {
              await transferAction(text);
            });
          },
        );
      } else {
        return TransferDialogWidget(
          coin: coinModel!.symbol!,
          from: coinModel!.address!,
          to: to.isEmptyString() ? _addressEC.text : to,
          amount: _amountEC.text,
          contract: coinModel!.contract ?? coinModel!.symbol!,
          contractAddress: coinModel!.contractAddress!,
          fee: walletFeeModel!,
          callback: () async {
            Get.back();

            await PasswordUtil.handlePassword(context, (text, goback) async {
              await transferAction(text);
            });
          },
        );
      }
    },
    );
  }

  Future transferAction(String data) async {
    AlertUtil.showLoadingDialog(context, show: true);
    String pass = CommonUtil.getTokenId(data);
    var auth = await DatabaseUtil.create().queryAuth();
    if (pass != auth.password) {
      AlertUtil.showLoadingDialog(context, show: false);
      AlertUtil.showWarnBar(ID.CommonPassword.tr);
      return;
    }
    var wid = PreferencesUtil.getString(Constant.CURRENT_WID);
    String privateKey = await CommonUtil.decrypt(coinModel!.privateKey!, pass);
    await requestNonce();
    var contract = coinModel!.contract != null ? coinModel!.contract!.toLowerCase() : "";
    AccountChain chain = getChain(contract)!;
    if (chain == null) {
      AlertUtil.showWarnBar(ID.WalletTransferUnsupport.tr);
      return;
    }
    var signParams = {
      "to": to.isEmptyString() ? _addressEC.text : to,
      "amount": _amountEC.text,
      "gasPrice": gas_price,
      "gasLimit": gas_limit,
      "privateKey": privateKey,
      "data": '',
      "nonce": nonce!.toInt(),
      "assetName": coinModel!.assetName != null ? coinModel!.assetName : ""
    };
    var params = {
      "from": from,
      "to": to.isEmptyString() ? _addressEC.text : to,
      "contract": coinModel!.contract,
      "contractAddress": coinModel!.contractAddress,
      "value": _amountEC.text,
      "sign": "",
      "data": "",
      "assetName": coinModel!.assetName != null ? coinModel!.assetName : ""
    };
    if (coinModel!.assetName!.isNotEmptyString()) {
    } else if (coinModel!.contractAddress!.isNotEmptyString()) {
      signParams['to'] = coinModel!.contractAddress;
      signParams['amount'] = '0';
      var inputData = await requestInput(_amountEC.text);
      if (inputData != null && inputData.indexOf("{") >= 0) {
        inputData = json.decode(inputData);
      }
      signParams['contract_address'] = coinModel!.contractAddress;
      signParams['data'] = inputData;
      params['data'] = json.encode(inputData);
    }
    ConsoleUtil.i({"signParams": signParams});
    var sign = await chain.signTransaction(signParams);
    params['sign'] = sign;

    String fcmtoken = PreferencesUtil.getString(Constant.FCMToken);
    if (fcmtoken.isNotEmpty) {
      params['tradeId'] = "1";
      String language = PreferencesUtil.getString(Constant.ZLanguage);
      params['lang'] = language.isNotEmpty ? language : 'en';
      params['symbol'] = coinModel?.symbol ?? coinModel!.contract;
      params['fcmtoken'] = fcmtoken;
    }
    AlertUtil.showLoadingDialog(context, show: false);

    ApiData apiData = await ApiManager.postWalletSend(data: params);
    if (apiData.code == 0) {
      WalletHashModel walletHashModel = WalletHashModel.fromJson(apiData.data);
      if (walletHashModel != null && walletHashModel.hash!.isNotEmptyString()) {
        eventBus.fire(UpdateChain());
        Get.back();
        await showDialog(
            useSafeArea: false,
            context: context,
            builder: (cotext) {
              return TransferFinishDialogWidget(
                  hash: walletHashModel.hash!,
                  callback: () async {
                    eventBus.fire(UpdateTrade());
                  }
              );
            }
        );
        return;
      }
    } else {}
    await showDialog(
        useSafeArea: false,
        context: context,
        builder: (cotext) {
          return TransferFinishDialogWidget(
              hash: "",
              callback: () async {
                eventBus.fire(UpdateTrade());
              }
          );
        }
    );
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
        appBar: AppbarWidget.initAppBar(context, isBack: true, title: ID.WalletTransfer.tr, widget: Builder(
          builder: (context) {
            return SizedBox(
              child: IconButton(
                icon: Image.asset(
                  Constant.Assets_Images + "common_scan.png",
                  width: SizeUtil.width(20),
                ),
                onPressed: () {
                  scanAction();
                },
              ),
            );
          },
        )),
        body: Container(
          width: SizeUtil.screenWidth(),
          child: Column(
            children: [
              Container(
                margin: SizeUtil.margin(all: 13),
                padding: SizeUtil.padding(top: 17, bottom: 17, left: 13, right: 13),
                width: SizeUtil.screenWidth() - SizeUtil.width(26),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SizeUtil.width(15)),
                  color: ZColors.KFFF9FAFBTheme(context),
                ),
                child: Column(
                  children: [
                    CustomWidget.buildCardMargin0(buildToAddress()),
                    CustomWidget.buildCardMargin0(buildAmount()),
                    CustomWidget.buildCardMargin0(isTron ? buildTrxFee() : buildFee(), padding: SizeUtil.padding(all: 0)),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 20,right: 20, top: 30, bottom: 40),
                child: CustomWidget.buildButtonImage(() {
                  transferBtnAction();
                },text: ID.WalletTransfer.tr),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildToAddress() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(ID.WalletTransferReceiveAddress.tr, style: AppTheme.text14(fontWeight: FontWeight.w600)),
                SizedBox(width: SizeUtil.width(10),),
                InkWell(
                  onTap: () {
                    selectAddressAction();
                  },
                  child: Image.asset(
                    Constant.Assets_Images + "common_address.png",
                    color: ZColors.ZFFF5CA40,
                    width: SizeUtil.width(20),
                    height: SizeUtil.width(20),
                  ),
                ),
              ],
            ),
          ),
          Container(
              padding: SizeUtil.padding(top: 5, bottom: 5),
              child: TextField(
                autofocus: false,
                decoration: InputDecoration.collapsed(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  fillColor: Colors.transparent,
                  filled: false,
                  hintText: ID.WalletInputReceiveAddress.tr,
                  hintStyle: AppTheme.text12(),
                ),
                style: AppTheme.text14(fontWeight: FontWeight.w600),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z]'))],
                textAlign: TextAlign.left,
                controller: _addressEC,
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 5,
                onChanged: (text) {
                  if (text.isNotEmptyString()) {
                    to = text;
                  } else {
                    to = '';
                  }
                },
              ),
          ),
        ],
      ),
    );
  }

  Widget buildAmount() {
    String cs = MathUtil.startWithStr(value).multiplyStr(coinModel != null && coinModel!.price!.isNotEmptyString() ? coinModel!.price! : '0').toString();
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Text(ID.WalletTransferAmount.tr, style: AppTheme.text14(fontWeight: FontWeight.w600)),
              Spacer(),
              Text(' $amount ${coin}', style: AppTheme.text14(fontWeight: FontWeight.w600)),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: SizeUtil.padding(top: 5, bottom: 5),
                  width: SizeUtil.screenW - 100,
                  child: TextField(
                    autofocus: false,
                    decoration: InputDecoration.collapsed(
                      fillColor: Colors.transparent,
                      filled: false,
                      hintText: '0.00',
                      hintStyle: AppTheme.text12(),
                    ),
                    style: AppTheme.text14(fontWeight: FontWeight.w600),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    textAlign: TextAlign.left,
                    controller: _amountEC,
                    onChanged: (text) {
                      setState(() {
                        if (text.isNotEmptyString()) {
                          value = text;
                        } else {
                          value = '0';
                        }
                      });
                    },
                  ),
                ),
              ),
              Text('${"≈ $csUnit"} $cs', style: AppTheme.text14()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemo() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ID.WalletTransferRemark.tr,
            style: AppTheme.text14(fontWeight: FontWeight.w600),
          ),
          Container(
            padding: SizeUtil.padding(top: 10, bottom: 10),
            child: TextField(
              autofocus: false,
              decoration: InputDecoration.collapsed(
                fillColor: Colors.transparent,
                filled: false,
                hintText: ID.WalletInputRemark.tr,
                hintStyle: AppTheme.text12(),
              ),
              style: AppTheme.text14(fontWeight: FontWeight.w600),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z]'))],
              textAlign: TextAlign.left,
              controller: _amountEC,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFee() {
    String gas = MathUtil.startWithStr(gas_limit).multiplyStr(gas_price).toString();

    return Material(
      color: ZColors.ZFFFFFFFFTheme1(context),
      borderRadius: SizeUtil.radius(all: 4),
      child: InkWell(
        onTap: () async {
          var result = await Get.to(WalletFeePage(), arguments: {"data": walletFeeModelList, "coinModel": coinModel});
          if (mounted && result != null) {
            setState(() {
              gas_price_str = result['gas_price_str'];
              gas_price = result['gas_price'];
              gas_limit = result['gas_limit'];
              walletFeeModel = WalletFeeModel.fromJson(result);
            });
          }
        },
        radius: SizeUtil.width(10),
        borderRadius: SizeUtil.radius(all: 4),
        child: Container(
          padding: SizeUtil.padding(all: 10),
          child: Row(
            children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ID.WalletTransferFee.tr,
                    style: AppTheme.text14(fontWeight: FontWeight.w600),
                  ),
                  Container(
                    padding: SizeUtil.padding(top: 10, bottom: 5),
                    child: Text(
                      "${gas} ${coinModel!.contract}",
                      style: AppTheme.text12(),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Container(
                    padding: SizeUtil.padding(top: 0, bottom: 5),
                    child: Text(
                      "Gas Price(${gas_price_str}GWEI) * Gas(${gas_limit})",
                      style: AppTheme.text12(),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
              ),
              Icon(
                Icons.arrow_forward_ios_sharp,
                color: ZColors.ZFF2D4067Theme(context),
                size: SizeUtil.width(15),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTrxFee() {
    String gas = walletFeeModel != null && walletFeeModel!.fee != null ? walletFeeModel!.fee! : "1";

    return Material(
      color: ZColors.ZFFFFFFFFTheme1(context),
      borderRadius: SizeUtil.radius(all: 4),
      child: InkWell(
        radius: SizeUtil.width(10),
        borderRadius: SizeUtil.radius(all: 4),
        child: Container(
          padding: SizeUtil.padding(all: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ID.WalletTransferFee.tr,
                      style: AppTheme.text14(fontWeight: FontWeight.w600),
                    ),
                    Container(
                      padding: SizeUtil.padding(top: 10, bottom: 5),
                      child: Text(
                        "${gas} ${coinModel!.contract}",
                        style: AppTheme.text12(),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
