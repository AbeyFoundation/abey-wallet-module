import 'dart:io';

import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/model/auth_model.dart';
import 'package:abey_wallet/model/coin_model.dart';
import 'package:abey_wallet/model/identity_model.dart';
import 'package:abey_wallet/model/wallet_model.dart';
import 'package:abey_wallet/pages/home.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/chain_util.dart';
import 'package:abey_wallet/utils/common_util.dart';
import 'package:abey_wallet/utils/database_util.dart';
import 'package:abey_wallet/utils/password_util.dart';
import 'package:abey_wallet/utils/preferences_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:abey_wallet/extension/string_extension.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalletRecoveryPage extends StatefulWidget {
  const WalletRecoveryPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WalletRecoveryPageState();
  }
}

class WalletRecoveryPageState extends State<WalletRecoveryPage> {
  WalletListModel? walletListModel;
  WalletIosListModel? walletIosListModel;

  TextEditingController _originalEC = TextEditingController();
  TextEditingController _passwordEC = TextEditingController();
  TextEditingController _password2EC = TextEditingController();

  bool _isShowTips = true;
  AuthModel? _authModel;

  IdentityModel? identityModel;

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      if (Get.arguments != null) {
        if (Get.arguments['walletIosListModel'] != null) {
          walletIosListModel = Get.arguments['walletIosListModel'];
        }
      }
    } else if (Platform.isAndroid) {
      if (Get.arguments != null) {
        if (Get.arguments['walletListModel'] != null) {
          walletListModel = Get.arguments['walletListModel'];
        }
      }
    }

    _originalEC.text = "";
    _passwordEC.text = "";
    _password2EC.text = "";

    _initAuthModel();
  }

  void _initAuthModel() async {
    var data = await DatabaseUtil().queryAuth();
    if (data is AuthModel) {
      if (mounted) {
        setState(() {
          _authModel = data;
        });
      }
    }
  }

  createAction() {
    if (_originalEC.text.isEmptyString()) {
      AlertUtil.showWarnBar(ID.WalletRecoveryPsd.tr);
      return;
    }
    if (_authModel == null) {
      _commit(false);
    } else {
      PasswordUtil.handlePassword(context, (text, goback) {
        String pass = CommonUtil.getTokenId(text);
        if (_authModel!.password != pass) {
          if (goback) {
            Get.back();
          }
          AlertUtil.showWarnBar(ID.WalletCreatePsdTip2.tr);
        } else {
          if (goback) {
            Get.back();
          }
          _commit(true,pass: pass, originalPwd: text);
        }
      });
    }
  }

  void _commit(bool check,{String? pass, String? originalPwd}) async {
    if (!check) {
      if (_passwordEC.text.isEmptyString()) {
        AlertUtil.showWarnBar(ID.WalletCreatePsdTip.tr);
        return;
      }
      if (_passwordEC.text != _password2EC.text) {
        AlertUtil.showWarnBar(ID.WalletCreatePsdTip1.tr);
        return;
      }
      originalPwd = _passwordEC.text;
      pass = CommonUtil.getTokenId(_passwordEC.text);
      DatabaseUtil().insertAuth(AuthModel.fromJson({"type": "pass", "password": pass}));
    } else {
      if (pass!.isEmptyString()) {
        AlertUtil.showWarnBar(ID.WalletCreatePsdTip.tr);
        return;
      }
    }
    AlertUtil.showLoadingDialog(context,show: true);
    if (Platform.isIOS) {
      if (walletIosListModel != null && walletIosListModel!.walletArray != null && walletIosListModel!.walletArray!.length > 0) {
        int wcount = 0;
        for (var walletModel in walletIosListModel!.walletArray!) {
          String mnemonic = "";
          String privateKey = "";
          String tokenType = "private";
          if (walletModel.privateKey!.isNotEmptyString()) {
            privateKey = await CommonUtil.decryptIos(walletModel.privateKey!,_originalEC.text);
            if (privateKey.isNotEmptyString()) {
              tokenType = "private";
            }
          }
          if (walletModel.mnemonic!.isNotEmptyString()) {
            mnemonic = await CommonUtil.decryptIos(walletModel.mnemonic!,_originalEC.text);
            if (mnemonic.isNotEmptyString()) {
              tokenType = "mnemonic";
            }
          }
          try {
            if (privateKey.isNotEmptyString()) {
              wcount = wcount + 1;
              String wid = CommonUtil.generateId();
              IdentityModel identityModel = new IdentityModel(wid: wid, name: walletModel.name, scope: "all", type: 1, tokenType: tokenType);
              List<CoinModel> allChains = [];
              CoinModel coinModel = new CoinModel(name: "ABEY",symbol: "ABEY",contract: "ABEY",icon: "https://qiniu.truescan.network/abey/abey.png");
              allChains.add(coinModel);
              await ChainUtil.saveIdentity(context, identityModel, pass, mnemonic: mnemonic, keystorePwd: originalPwd!,privateKey: privateKey);
              IdentityModel newIdentity = await DatabaseUtil.create().queryIdentity(identityModel);
              await ChainUtil.saveCoin(context, newIdentity, 1, allChains, pass, true);

              this.identityModel = identityModel;
            }
          } catch (e) {
          }
        }
        if (wcount <= 0) {
          AlertUtil.showLoadingDialog(context,show: false);
          AlertUtil.showWarnBar(ID.WalletRecoveryPsdTip.tr);
          return;
        }
      }
    } else if (Platform.isAndroid) {
      if (walletListModel != null && walletListModel!.items != null && walletListModel!.items!.length > 0) {
        int wcount = 0;
        for (var walletModel in walletListModel!.items!) {
          String mnemonic = "";
          String privateKey = "";
          String tokenType = "private";
          if (walletModel.privateKey!.isNotEmptyString()) {
            privateKey = await CommonUtil.decryptTray(walletModel.privateKey!,_originalEC.text);
            tokenType = "private";
          }
          if (walletModel.mnemonic!.isNotEmptyString()) {
            mnemonic = await CommonUtil.decryptTray(walletModel.mnemonic!,_originalEC.text);
            tokenType = "mnemonic";
          }
          try {
            if (privateKey.isNotEmptyString()) {
              wcount = wcount + 1;
              String wid = CommonUtil.generateId();
              IdentityModel identityModel = new IdentityModel(wid: wid, name: walletModel.name, scope: "all", type: 1, tokenType: tokenType);
              List<CoinModel> allChains = [];
              CoinModel coinModel = new CoinModel(name: "ABEY",symbol: "ABEY",contract: "ABEY",icon: "https://qiniu.truescan.network/abey/abey.png");
              allChains.add(coinModel);
              await ChainUtil.saveIdentity(context, identityModel, pass, mnemonic: mnemonic, keystorePwd: originalPwd!,privateKey: privateKey);
              IdentityModel newIdentity = await DatabaseUtil.create().queryIdentity(identityModel);
              await ChainUtil.saveCoin(context, newIdentity, 1, allChains, pass, true);

              this.identityModel = identityModel;
            }
          } catch (e) {
          }
        }
        if (wcount <= 0) {
          AlertUtil.showLoadingDialog(context,show: false);
          AlertUtil.showWarnBar(ID.WalletRecoveryPsdTip.tr);
          return;
        }
      }
    }

    if (this.identityModel != null && this.identityModel!.wid != null) {
      PreferencesUtil.putString(Constant.CURRENT_WID, this.identityModel!.wid!);
      PreferencesUtil.putBool(Constant.WalletOriginal, true);
      Future.delayed(Duration(milliseconds: 1000), () {
        AlertUtil.showLoadingDialog(context,show: false);
        Get.offAll(HomePage(), arguments: {"action": "refresh", "wid": this.identityModel!.wid});
      });
    }
    AlertUtil.showLoadingDialog(context,show: false);
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
      child:Scaffold(
        resizeToAvoidBottomInset:false,
        backgroundColor: ZColors.KFFFFFFFFTheme(context),
        appBar: AppbarWidget.initAppBar(context,isBack: true,title: ID.WalletRecovery.tr,),
        body: Column(
          children: [
            Container(
              width: SizeUtil.screenWidth(),
              child: Column(
                children: _createContent(),
              ),
            ),
            Spacer(),
            Container(
              margin: EdgeInsets.only(left: 20,right: 20, bottom: 40),
              child: CustomWidget.buildButtonImage(() {
                createAction();
              },text: ID.WalletCreateBtn.tr),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _createContent() {
    List<Widget> views =[
      CustomWidget.buildCardX(CustomWidget.buildInput(ID.WalletRecoveryPsd.tr,_originalEC))
    ];
    if (_authModel == null) {
      views.addAll([
        CustomWidget.buildCardX(CustomWidget.buildPassword(ID.WalletCreatePsd.tr, _passwordEC,clicker: (){
          if (_isShowTips) {
            _isShowTips = false;
            AlertUtil.showTipsBar(ID.WalletCreatePsdSave.tr,duration: Duration(seconds: 5));
          }
        })),
        Container(
          margin: SizeUtil.margin(left: 20),
          width: SizeUtil.screenWidth(),
          child: Text(
            ID.WalletCreatePsdTip.tr,
            style: TextStyle(color: ZColors.ZFFEECC5B),
            textAlign: TextAlign.start,
          ),
        ),
        CustomWidget.buildCardX(CustomWidget.buildPassword(ID.WalletCreatePsdOk.tr, _password2EC)),
      ]);
    }
    return views;
  }

  @override
  void dispose() {
    super.dispose();
  }
}