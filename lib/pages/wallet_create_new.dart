import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/model/auth_model.dart';
import 'package:abey_wallet/model/identity_model.dart';
import 'package:abey_wallet/pages/wallet_chain.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/common_util.dart';
import 'package:abey_wallet/utils/database_util.dart';
import 'package:abey_wallet/utils/password_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:abey_wallet/extension/string_extension.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class WalletCreateNewPage extends StatefulWidget {
  const WalletCreateNewPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WalletCreateNewPageState();
  }
}

class WalletCreateNewPageState extends State<WalletCreateNewPage> {
  TextEditingController _nameEC = TextEditingController();
  TextEditingController _passwordEC = TextEditingController();
  TextEditingController _password2EC = TextEditingController();

  bool _isShowTips = true;
  AuthModel? _authModel;

  @override
  void initState() {
    super.initState();
    _nameEC.text = "";
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
    if (_nameEC.text.isEmptyString()) {
      AlertUtil.showWarnBar(ID.WalletCreateNameTip.tr);
      return;
    }
    if (_authModel == null) {
      _commit(false);
    } else {
      PasswordUtil.handlePassword(context, (text, goback) {
        String pass = CommonUtil.getTokenId(text);
        if (_authModel?.password != pass) {
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

  void _commit(bool check,{String? pass, String? originalPwd}) {
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
    IdentityModel identityModel = new IdentityModel(name: _nameEC.text,scope: "all",type: 0, tokenType: "mnemonic");
    Get.off(WalletChainPage(), arguments: {
      "identityModel": identityModel,
      "pass": pass,
      "originalPwd": originalPwd
    });
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
        appBar: AppbarWidget.initAppBar(context,isBack: true,title: ID.WalletCreate.tr,),
        body: Column(
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
      CustomWidget.buildCardX(CustomWidget.buildInputName(ID.WalletCreateName.tr,_nameEC,))
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
            style: TextStyle(color: ZColors.ZFFFFD84A),
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