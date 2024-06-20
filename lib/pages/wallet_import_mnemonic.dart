import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/model/auth_model.dart';
import 'package:abey_wallet/model/coin_model.dart';
import 'package:abey_wallet/model/identity_model.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/pages/home.dart';
import 'package:abey_wallet/pages/wallet_chain.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/chain_util.dart';
import 'package:abey_wallet/utils/common_util.dart';
import 'package:abey_wallet/utils/database_util.dart';
import 'package:abey_wallet/utils/password_util.dart';
import 'package:abey_wallet/utils/preferences_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:abey_wallet/extension/string_extension.dart';

class WalletImportMnemonicPage extends StatefulWidget {
  const WalletImportMnemonicPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WalletImportMnemonicPageState();
  }
}

class WalletImportMnemonicPageState extends State<WalletImportMnemonicPage> {
  TextEditingController _nameEC = TextEditingController();
  TextEditingController _passwordEC = TextEditingController();
  TextEditingController _password2EC = TextEditingController();
  TextEditingController _mnemonicEC = TextEditingController();

  bool _isShowTips = true;
  AuthModel? _authModel;

  @override
  void initState() {
    super.initState();
    _nameEC.text = "";
    _passwordEC.text = "";
    _password2EC.text = "";
    _mnemonicEC.text = "";

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

  void importAction() {
    if (_authModel == null) {
      if (_nameEC.text.isEmptyString()) {
        AlertUtil.showWarnBar(ID.WalletImportNameTip.tr);
        return;
      }
      importCommit(false, password: "", originalPwd: _passwordEC.text);
    } else {
      PasswordUtil.handlePassword(context, (text, goback) {
        String pass = CommonUtil.getTokenId(text);
        if (_authModel!.password != pass) {
          AlertUtil.showWarnBar(ID.WalletCreatePsdTip2.tr);
        } else {
          if (goback) {
            Get.back();
          }
          importCommit(true, password: pass, originalPwd: text);
        }
      });
    }
  }

  void importCommit(bool isCheck,{String? password, String? originalPwd}) async {
    String mnemonic = _mnemonicEC.text.trim().toLowerCase();
    if (mnemonic.isEmptyString()) {
      AlertUtil.showWarnBar(ID.WalletImportMnemonicTip.tr);
      return;
    }
    String name = _nameEC.text;
    if (name.isEmptyString()) {
      AlertUtil.showWarnBar(ID.WalletImportNameTip.tr);
      return;
    }
    if (isCheck) {
      if (password!.isEmptyString()) {
        AlertUtil.showWarnBar(ID.WalletCreatePsdTip.tr);
        return;
      }
    } else {
      if (_passwordEC.text.isEmptyString() || _passwordEC.text.length != 6) {
        AlertUtil.showWarnBar(ID.WalletCreatePsdTip.tr);
        return;
      }
      originalPwd = _passwordEC.text;
      password = CommonUtil.getTokenId(_passwordEC.text);
      if (_authModel == null) {
        if (_passwordEC.text != _password2EC.text) {
          AlertUtil.showWarnBar(ID.WalletCreatePsdTip1.tr);
          return;
        }
        AlertUtil.showLoadingDialog(context,show: true);
        DatabaseUtil.create().insertAuth(AuthModel.fromJson({"type": "pass", "password": password}));
        AlertUtil.showLoadingDialog(context,show: false);
      } else {
        if (password != _authModel!.password) {
          AlertUtil.showWarnBar(ID.WalletCreatePsdTip2.tr);
          return;
        }
      }
    }

    AlertUtil.showLoadingDialog(context,show: true);
    try {
      String privateS = await ChainUtil.getPrivateKeyFromMnemonicEth(context, "ETH", mnemonic);
      if (privateS.isNotEmptyString()) {
        String wid = CommonUtil.generateId();
        IdentityModel identityModel = new IdentityModel(wid: wid, name: _nameEC.text, scope: "all", type: 1, tokenType: "mnemonic");
        var result = await Get.to(WalletChainPage(), arguments: {
          "identityModel": identityModel,
          "pass": password
        });
        if (result == null) {
          AlertUtil.showLoadingDialog(context,show: false);
          AlertUtil.showWarnBar(ID.WalletSelectChainTip.tr);
          return;
        }
        List<CoinModel> allChains = result['chains'];
        List<CoinModel> ethChains = [];
        List<CoinModel> tronChains = [];
        for (var chain in allChains) {
          if (chain.contract!.isNotEmpty && chain.contract == "TRX") {
            tronChains.add(chain);
          } else {
            ethChains.add(chain);
          }
        }

        await ChainUtil.saveIdentity(context, identityModel, password, mnemonic: mnemonic, keystorePwd: originalPwd!);
        IdentityModel newIdentity = await DatabaseUtil.create().queryIdentity(identityModel);
        List<String> descAddresses = await ChainUtil.saveCoin(context, newIdentity, 1, allChains, password, true);
        if (descAddresses == null || descAddresses.length == 0) {
          await DatabaseUtil.create().deleteIdentity(identityModel);
          AlertUtil.showLoadingDialog(context,show: false);
          AlertUtil.showWarnBar(ID.WalletImportMnemonicError.tr);
          return;
        }

        PreferencesUtil.putString(Constant.CURRENT_WID, identityModel.wid!);

        Future.delayed(Duration(milliseconds: 2000), () {
          AlertUtil.showLoadingDialog(context,show: false);
          Get.offAll(HomePage(), arguments: {"action": "refresh", "wid": identityModel.wid});
        });

      } else {
        AlertUtil.showLoadingDialog(context,show: false);
        AlertUtil.showWarnBar(ID.WalletImportMnemonicError.tr);
      }
    } catch (e) {
      AlertUtil.showLoadingDialog(context,show: false);
      AlertUtil.showWarnBar(ID.WalletImportMnemonicError.tr);
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
        resizeToAvoidBottomInset:false,
        backgroundColor: ZColors.KFFFFFFFFTheme(context),
        appBar: AppbarWidget.initAppBar(context,isBack: true,title: ID.WalletImportMnemonic.tr,),
        body: Container(
          child: Column(
            children: [
              Container(
                margin: SizeUtil.margin(all: 15),
                padding: SizeUtil.padding(top: 17, bottom: 17),
                width: SizeUtil.screenWidth() - SizeUtil.width(26),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SizeUtil.width(15)),
                  color: ZColors.KFFF9FAFBTheme(context),
                ),
                child: Column(
                  children: _createContent(),
                ),
              ),
              Spacer(),
              Container(
                margin: EdgeInsets.only(left: 20,right: 20, bottom: 40),
                child: CustomWidget.buildButtonImage(() {
                  importAction();
                },text: ID.WalletImport.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _createContent() {
    List<Widget> views =[
      CustomWidget.buildCardX(CustomWidget.buildInputName(ID.WalletCreateName.tr,_nameEC))
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
    views.addAll([
      CustomWidget.buildCardX(CustomWidget.buildTextArea1(ID.WalletImportMnemonic.tr, _mnemonicEC, callback: (text) {

      }, suffixIcon: IconButton(icon: Icon(Icons.close), onPressed: () {
        _mnemonicEC.clear();
      })),),
    ]);

    return views;
  }

  @override
  void dispose() {
    super.dispose();
  }
}