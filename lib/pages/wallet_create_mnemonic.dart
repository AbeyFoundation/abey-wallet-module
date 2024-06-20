import 'dart:math';

import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/model/coin_model.dart';
import 'package:abey_wallet/model/identity_model.dart';
import 'package:abey_wallet/pages/home.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/chain_util.dart';
import 'package:abey_wallet/utils/common_util.dart';
import 'package:abey_wallet/utils/console_util.dart';
import 'package:abey_wallet/utils/database_util.dart';
import 'package:abey_wallet/utils/preferences_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/vender/chain/chaincore.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:abey_wallet/extension/string_extension.dart';
import 'package:abey_wallet/extension/list_extension.dart';

class WalletCreateMnemonicPage extends StatefulWidget {
  const WalletCreateMnemonicPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WalletCreateMnemonicPageState();
  }
}

class WalletCreateMnemonicPageState extends State<WalletCreateMnemonicPage> {
  IdentityModel? identityModel;
  String? pass;
  String? originalPwd;
  List<CoinModel> coinModelList = [];

  int start = 1;
  int step = 1;
  double _mnemonicTextWidget = 0;
  double _mnemonicTextHeight = 0;
  Map<String, Map<String, dynamic>> _waitChecks = {};
  String _mnemonic = '';
  List<String> _mnemonics = [];
  List<String> _mnemonicsTemp = [];
  List<String> _mnemonicsKeep = [];

  bool isContinue = true;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      if (Get.arguments['identityModel'] != null) {
        identityModel = Get.arguments['identityModel'];
      }
      if (Get.arguments['pass'] != null) {
        pass = Get.arguments['pass'];
      }
      if (Get.arguments['originalPwd'] != null) {
        originalPwd = Get.arguments['originalPwd'];
      }
      if (Get.arguments['chains'] != null) {
        coinModelList = Get.arguments['chains'];
      }
    }

    if (identityModel!.type == 0) {
      start = 1;
      _generateMnemonic();
    } else {
      start = 1;
      if (pass!.isEmptyString() || identityModel!.wid!.isEmptyString()) {
        Get.back();
        return;
      }
      String mnemonic = Get.arguments['mnemonic'];
      _mnemonic = mnemonic;
    }
    step = start;
    int one = Random().nextInt(6);
    int two = Random().nextInt(6) + 6;
    _waitChecks = {
      '$one': {"value": '', "status": false},
      '$two': {"value": '', "status": false},
    };
  }

  _generateMnemonic() async {
    var chain = new AccountChain(chain: "ETH");
    String mnemonicStr = await chain.getMnemonic();
    String randomId = CommonUtil.generateId();

    AlertUtil.showLoadingDialog(context,show: false);
    setState(() {
      _mnemonic = mnemonicStr;
      identityModel!.wid = randomId;
    });
  }

  void backupAction() {
    if (step == 1 && identityModel!.type != 0) {
      Get.back();
      return;
    }
    setState(() {
      step++;
    });
  }

  String popMnemonicsAction() {
    if (_mnemonicsTemp.length == 0) {
      return "";
    }
    int index = Random().nextInt(_mnemonicsTemp.length);
    return _mnemonicsTemp.removeAt(index);
  }

  Future<bool> commitAction(checkIndex) async {
    _waitChecks[checkIndex]!['status'] = true;
    bool isCheckedAll = true;
    _waitChecks.forEach((key, value) {
      if (!value['status']) {
        isCheckedAll = false;
      }
    });
    if (isCheckedAll) {
      isContinue = false;
      if (identityModel!.type == 0) {
        AlertUtil.showLoadingDialog(context,show: true);

        identityModel!.scope = "all";
        await ChainUtil.saveIdentity(context, identityModel!, pass!, mnemonic: _mnemonic, keystorePwd: originalPwd!);
        IdentityModel newIdentity = await DatabaseUtil.create().queryIdentity(identityModel!);
        await ChainUtil.saveCoin(context, newIdentity, 0, coinModelList, pass!, true);

        PreferencesUtil.putString(Constant.CURRENT_WID, identityModel!.wid!);

        Future.delayed(Duration(milliseconds: 500), () {
          AlertUtil.showLoadingDialog(context,show: false);
          Get.offAll(HomePage(), arguments: {"action": "refresh", "wid": identityModel!.wid});
        });
      } else {
        Get.back();
      }
      return true;
    }

    setState(() {
      _waitChecks[checkIndex]!['status'] = true;
    });

    return true;
  }

  @override
  Widget build(BuildContext context) {
    String checkIndex = "";
    int checkIndexInt = 0;
    if (step == 2) {
      _waitChecks.forEach((key, value) {
        if (!value['status']) {
          checkIndex = key;
          try {
            checkIndexInt = int.parse(key);
          } catch (e) {
            print(e);
          }
          return;
        }
      });
    }

    return Scaffold(
      resizeToAvoidBottomInset:false,
      backgroundColor: ZColors.KFFFFFFFFTheme(context),
      appBar: AppbarWidget.initAppBar(context,isBack: true,title: ID.WalletCreateMnemonic.tr,),
      body: step == 1 ? Container(
        margin: SizeUtil.margin(left: 15,right: 15, top: 15,bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              child: Text(
                ID.WalletBackupMnemonic.tr,
                style: AppTheme.text16(),
              ),
            ),
            SizedBox(height: 6,),
            Container(
              child: Text(
                ID.WalletBackupMnemonicTip1.tr,
                style: AppTheme.text14(),
              ),
            ),
            Container(
              alignment: Alignment.center,
              margin: SizeUtil.margin(top: 15, bottom: 15),
              padding: SizeUtil.padding(all: 10),
              decoration: BoxDecoration(
                border: new Border.all(
                  color: ZColors.ZFFF5F5F5Theme(context),
                  width: .1,
                ),
                color: ZColors.ZFFF5F5F5Theme(context),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 5),
                    blurRadius: 10,
                    spreadRadius: 0.1,
                    color: ZColors.ZFFD6D6D6Theme(context),
                  ),
                ],
                borderRadius: SizeUtil.radius(all: 5),
              ),
              child: Wrap(
                children: _createMnemonicTexts(),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: SizeUtil.padding(top: 10, bottom: 10),
              child: Text(
                "* ${ID.WalletBackupMnemonicTip2.tr}",
                style: AppTheme.text12(),
              ),
            ),
            Spacer(),
            Container(
              child: CustomWidget.buildButtonImage(() {
                backupAction();
              },text: ID.WalletBackupMnemonicFinish.tr),
            ),
          ],
        ),
      ) : step == 2 ? Container(
        margin: SizeUtil.margin(left: 15,right: 15, top: 15,bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              child: Text(
                ID.WalletVertifyMnemonic.tr,
                style: AppTheme.text16(),
              ),
            ),
            Container(
              margin: SizeUtil.margin(top: 15, bottom: 15),
              padding: SizeUtil.padding(all: 20),
              decoration: BoxDecoration(
                border: new Border.all(
                  color: ZColors.ZFFF5F5F5Theme(context),
                  width: .1,
                ),
                color: ZColors.ZFFF5F5F5Theme(context),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 5),
                    blurRadius: 10,
                    spreadRadius: 0.1,
                    color: ZColors.ZFFD6D6D6Theme(context),
                  ),
                ],
                borderRadius: SizeUtil.radius(all: 5),
              ),
              child: Text(
                ID.WalletVertifyMnemonicTip1.tr.replaceAll("{%s}", '${checkIndexInt + 1}'),
                style: AppTheme.text16(),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: SizeUtil.padding(top: 10, bottom: 10),
              child: Text(
                "* ${ID.WalletBackupMnemonicTip2.tr}",
                style: AppTheme.text12(),
              ),
            ),

            Container(
              child: Wrap(
                children: _createCheckButton(checkIndex),
              ),
            ),
          ],
        ),
      ) : Container(

      ),
    );
  }

  List<Widget> _createMnemonicTexts() {
    if (_mnemonicTextWidget == 0) {
      _mnemonicTextWidget = (SizeUtil.screenWidth() - SizeUtil.width(70)) / 3;
      _mnemonicTextHeight = SizeUtil.height(40);
    }
    List<Widget> widgets = [];
    try {
      _mnemonics = _mnemonic.split(" ");
      _mnemonicsTemp = _mnemonic.split(" ");
      _mnemonicsKeep = [];
      _mnemonics.forEachWithIndex((index, element) {
        var createMnemonicText = _createMnemonicText(index, element);
        if (createMnemonicText is Widget) {
          widgets.add(createMnemonicText);
        }
      });
    } catch (e) {
      ConsoleUtil.e(e);
    }
    return widgets;
  }

  Widget _createMnemonicText(index, text) {
    if (text is String) {
      text = text.trim();
      if (text != '') {
        if (_waitChecks.containsKey('$index')) {
          _waitChecks['$index']!['value'] = text;
        }
        return Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 1, color: ZColors.ZFFCCCCCCTheme(context))),
          ),
          margin: SizeUtil.margin(all: 2),
          width: _mnemonicTextWidget,
          height: _mnemonicTextHeight,
          child: Stack(
            children: [
              Center(
                child: Text(
                  text,
                  style: AppTheme.text16(),
                  textAlign: TextAlign.center,
                ),
              ),
              Positioned(
                  top: SizeUtil.height(5),
                  child: Text(
                    '${index + 1}',
                    style: AppTheme.text12(),
                  ),
              ),
            ],
          ),
        );
      }
    }
    return Container();
  }

  List<Widget> _createCheckButton(checkIndex) {
    List<Widget> items = [];
    for (int i = 0; i < _mnemonics.length; i++) {
      String value;
      if (_mnemonicsKeep.length != 12) {
        value = popMnemonicsAction();
        _mnemonicsKeep.add(value);
      } else {
        value = _mnemonicsKeep[i];
      }
      items.add(Padding(
        padding: SizeUtil.padding(all: 5),
        child: MaterialButton(
          height: SizeUtil.height(35),
          minWidth: (SizeUtil.screenWidth() - SizeUtil.width(64))/3,
          color: ZColors.ZFFFFFFFFTheme1(context),
          textColor: Colors.grey,
          child: Text(
            "$value",
            style: AppTheme.text14(),
          ),
          onPressed: () async {
            if (isContinue) {
              if (_waitChecks[checkIndex]!['value'] == value) {
                await commitAction(checkIndex);
              } else {
                AlertUtil.showWarnBar(ID.WalletVertifyMnemonicTip2.tr);
              }
            }
          },
        ),
      ));
    }
    return items;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
