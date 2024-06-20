import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/model/identity_model.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/utils/console_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:abey_wallet/extension/list_extension.dart';

class WalletMnemonicBackupPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletMnemonicBackupPageState();
  }
}

class WalletMnemonicBackupPageState extends State<WalletMnemonicBackupPage> {
  IdentityModel? identityModel;
  String? mnemonic;

  double _mnemonicTextWidget = 0;
  double _mnemonicTextHeight = 0;
  List<String> _mnemonics = [];

  bool isContinue = true;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      if (Get.arguments['identityModel'] != null) {
        identityModel = Get.arguments['identityModel'];
      }
      if (Get.arguments['mnemonic'] != null) {
        mnemonic = Get.arguments['mnemonic'];
      }
    }
  }

  void backupAction() async {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:false,
      backgroundColor: ZColors.KFFFFFFFFTheme(context),
      appBar: AppbarWidget.initAppBar(context,isBack: true,title: ID.WalletManager.tr,),
      body: Container(
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
      _mnemonics = mnemonic!.split(" ");
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
        return Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 1, color: ZColors.ZFFCCCCCC)),
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

  @override
  void dispose() {
    super.dispose();
  }
}