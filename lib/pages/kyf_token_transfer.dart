import 'dart:convert';

import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/event/event.dart';
import 'package:abey_wallet/model/coin_model.dart';
import 'package:abey_wallet/model/identity_model.dart';
import 'package:abey_wallet/pages/common_scan.dart';
import 'package:abey_wallet/pages/wallet_address.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/service/api_data.dart';
import 'package:abey_wallet/service/api_manager.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/chain_evm_util.dart';
import 'package:abey_wallet/utils/chain_util.dart';
import 'package:abey_wallet/utils/common_util.dart';
import 'package:abey_wallet/utils/console_util.dart';
import 'package:abey_wallet/utils/database_util.dart';
import 'package:abey_wallet/utils/password_util.dart';
import 'package:abey_wallet/utils/preferences_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/vender/chain/chain_exp.dart';
import 'package:abey_wallet/vender/chain/chaincore.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:abey_wallet/widget/dialog/transfer_finish_dialog_widget.dart';
import 'package:abey_wallet/widget/dialog/transfer_kyf_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:abey_wallet/extension/string_extension.dart';

class KyfTokenTransferPage extends StatefulWidget {

  const KyfTokenTransferPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return KyfTokenTransferPageState();
  }
}

class KyfTokenTransferPageState extends State<KyfTokenTransferPage> {
  IdentityModel? identityModel;
  KyfModel? kyfModel;
  KyfDetailModel? kyfDetailModel;

  List<CoinModel> chainList = [];
  CoinModel? chainModel;

  TextEditingController _addressEC = TextEditingController();

  String gas_price_str = '0.0000';
  String gas_price = '0.0000';
  String gas_limit = '21000';

  String value = '0';
  String to = '';
  String from = '';
  String hash = '';

  List<WalletFeeModel>? walletFeeModelList;
  WalletFeeModel? walletFeeModel;
  String? nonce;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      if (Get.arguments['identityModel'] != null) {
        identityModel = Get.arguments['identityModel'];
      }
      if (Get.arguments['kyfModel'] != null) {
        kyfModel = Get.arguments['kyfModel'];
      }
      if (Get.arguments['kyfDetailModel'] != null) {
        kyfDetailModel = Get.arguments['kyfDetailModel'];
      }
    }
    initChainModel();

    eventBus.on<UpdateTradeKyf>().listen((event) {
      tradeKyfAction();
    });
  }

  void initChainModel() async {
    List<CoinModel> coinModelList = await DatabaseUtil.create().queryCoinList(new CoinModel(wid: identityModel!.wid));
    if (coinModelList != null) {
      chainList.clear();
      coinModelList.forEach((element) {
        if (element.contract == element.symbol) {
          chainList.add(element);
          if (element.contract == kyfModel?.contract) {
            chainModel = element;
          }
        }
      });
    }
  }

  void tradeKyfAction() {
    Navigator.pop(context);
  }

  Future<bool> requestFees() async {
    var inputData = await requestInput();
    ApiData apiData = await ApiManager.postWalletFees(data: {
      "symbol": kyfModel!.name,
      "contract": kyfModel!.contract,
      "from": kyfModel!.address,
      "to": kyfModel!.contractAddress,
      "value": "0",
      "data": inputData
    });
    if (apiData.code == 0) {
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
    } else {
      AlertUtil.showTipsBar(ID.CommonNetworkError.tr);
    }
    return true;
  }

  Future<bool> requestNonce() async {
    ApiData apiData = await ApiManager.postWalletNonce(data: {"address": kyfModel!.address, "contract": kyfModel!.contract});
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
    return true;
  }

  requestInput() async {
    ApiData apiData = await ApiManager.postKyfTokenData(data: {
      "from": kyfModel!.address,
      "to": to.isEmptyString() ? _addressEC.text : to,
      "value": kyfDetailModel!.tokenId,
      "contract": kyfModel!.contract,
      "contractAddress": kyfModel!.contractAddress
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
      // String isAddress = await ChainUtil.vertityAddress(context, "ETH", _addressEC.text.toLowerCase());
      String isAddress = await ChainEvmUtil.verityAddress(_addressEC.text.toLowerCase()).toString();
      if (isAddress == "false") {
        AlertUtil.showWarnBar(ID.WalletInputReceiveAddress.tr);
        return Future.value(false);
      }
    }
    if (chainModel == null) {
      return Future.value(false);
    }
    return Future.value(true);
  }

  void onTransferAction() async {
    FocusScope.of(context).requestFocus(FocusNode());
    var result = await checkAction();
    if (!result) {
      return;
    }

    await requestFees();
    await showDialog(
        useSafeArea: false,
        context: context,
        builder: (cotext) {
      return TransferKyfDialogWidget(
        coin: kyfModel!.name!,
        from: kyfModel!.address!,
        to: to.isEmptyString() ? _addressEC.text : to,
        contract: kyfModel!.contract ?? kyfModel!.name!,
        contractAddress: kyfModel!.contractAddress!,
        fee: walletFeeModel!,
        callback: () async {
          Get.back();

          await PasswordUtil.handlePassword(context, (text, goback) async {
            await transferAction(text);
          });
        },
      );
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
    String privateKey = await CommonUtil.decrypt(chainModel!.privateKey!, pass);
    await requestNonce();
    var contract = kyfModel!.contract != null ? kyfModel!.contract!.toLowerCase() : "";
    AccountChain chain = getChain(contract)!;
    if (chain == null) {
      AlertUtil.showLoadingDialog(context, show: false);
      AlertUtil.showWarnBar(ID.WalletTransferUnsupport.tr);
      return;
    }
    var signParams = {
      "to": to.isEmptyString() ? _addressEC.text : to,
      "amount": "0",
      "gasPrice": gas_price,
      "gasLimit": gas_limit,
      "privateKey": privateKey,
      "data": '',
      "nonce": nonce!.toInt()
    };
    var params = {
      "from": kyfModel!.address,
      "to": to.isEmptyString() ? _addressEC.text : to,
      "contract": kyfModel!.contract,
      "contractAddress": kyfModel!.contractAddress,
      "value": "0",
      "sign": "",
      "data": ""
    };
    if (kyfModel!.contractAddress!.isNotEmptyString()) {
      signParams['to'] = kyfModel!.contractAddress;
      signParams['amount'] = '0';
      var inputData = await requestInput();
      if (inputData != null && inputData.indexOf("{") >= 0) {
        inputData = json.decode(inputData);
      }
      signParams['data'] = inputData;
      params['data'] = json.encode(inputData);
    }
    ConsoleUtil.i({"signParams": signParams});
    var sign = await chain.signTransaction(signParams);
    params['sign'] = sign;

    String fcmtoken = PreferencesUtil.getString(Constant.FCMToken);
    if (fcmtoken.isNotEmpty) {
      params['tradeId'] = "2";
      String language = PreferencesUtil.getString(Constant.ZLanguage);
      params['lang'] = language.isNotEmpty ? language : 'en';
      params['symbol'] = kyfModel?.name ?? "";
      params['fcmtoken'] = fcmtoken;
    }

    AlertUtil.showLoadingDialog(context, show: false);

    ApiData apiData = await ApiManager.postWalletSend(data: params);
    if (apiData.code == 0) {
      WalletHashModel walletHashModel = WalletHashModel.fromJson(apiData.data);
      if (walletHashModel != null && walletHashModel.hash!.isNotEmptyString()) {
        eventBus.fire(UpdateKyf());
        Get.back();

        await showDialog(
            useSafeArea: false,
            context: context,
            builder: (cotext) {
              return TransferFinishDialogWidget(
                  hash: walletHashModel.hash!,
                  callback: () async {
                    eventBus.fire(UpdateTradeKyf());
                  }
              );
            }
        );

        return;
      }
    }

    await showDialog(
        useSafeArea: false,
        context: context,
        builder: (cotext) {
          return TransferFinishDialogWidget(
              hash: "",
              callback: () async {
                eventBus.fire(UpdateTradeKyf());
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
        appBar: AppbarWidget.initAppBar(context, isBack: true, title: ID.KyfTransfer.tr, widget: Builder(
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
                    CustomWidget.buildCardMargin0(buildInfo()),
                  ],
                ),
              ),
              // _buildButton()
              Container(
                margin: EdgeInsets.only(left: 20,right: 20, top: 30, bottom: 40),
                child: CustomWidget.buildButtonImage(() {
                  onTransferAction();
                },text: ID.KyfTransfer.tr),
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

  Widget buildInfo() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ID.KyfTransfer.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.text14(),
          ),
          SizedBox(
            height: SizeUtil.width(10),
          ),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CustomWidget.buildNetworkImage(context, kyfDetailModel!.img!, SizeUtil.width(58), SizeUtil.width(58), SizeUtil.width(4)),
              ),
              SizedBox(
                width: SizeUtil.width(10),
              ),
              Container(
                width: SizeUtil.screenW - SizeUtil.width(150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kyfDetailModel != null && kyfDetailModel!.name != null ? kyfDetailModel!.name! : "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.text14(),
                    ),
                    SizedBox(
                      height: SizeUtil.width(6),
                    ),
                    Container(
                      child: Text(
                        "Token Id" + " " +
                            (kyfDetailModel != null && kyfDetailModel!.tokenId != null ? kyfDetailModel!.tokenId! : ""),
                        style: AppTheme.text12(),
                      ),
                    ),
                    SizedBox(
                      height: SizeUtil.width(6),
                    ),
                    Row(
                      children: [
                        ClipOval(
                          child: CustomWidget.buildNetworkImage(context, kyfModel!.icon!, SizeUtil.width(14), SizeUtil.width(14), SizeUtil.width(2)),
                        ),
                        SizedBox(
                          width: SizeUtil.width(6),
                        ),
                        Text(
                          kyfModel != null && kyfModel!.chainName != null ? kyfModel!.chainName! : "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.text12(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}