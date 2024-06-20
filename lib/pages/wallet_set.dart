import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/event/event.dart';
import 'package:abey_wallet/model/coin_model.dart';
import 'package:abey_wallet/model/identity_model.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/pages/home.dart';
import 'package:abey_wallet/pages/wallet_create.dart';
import 'package:abey_wallet/pages/wallet_mnemonic_backup.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/common_util.dart';
import 'package:abey_wallet/utils/database_util.dart';
import 'package:abey_wallet/utils/password_util.dart';
import 'package:abey_wallet/utils/preferences_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:abey_wallet/widget/dialog/common_dialog_widget.dart';
import 'package:abey_wallet/widget/dialog/copy_dialog_widget.dart';
import 'package:abey_wallet/widget/dialog/copy_warm_dialog_widget.dart';
import 'package:abey_wallet/widget/dialog/input_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:abey_wallet/extension/string_extension.dart';

class WalletSetPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletSetPageState();
  }
}

class WalletSetPageState extends State<WalletSetPage> {
  IdentityModel? identityModel;
  List<CoinModel> chainList = [];

  bool hasMnemonic = false;
  bool hasKeystore = true;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      if (Get.arguments['identityModel'] != null) {
        identityModel = Get.arguments['identityModel'];
        hasMnemonic = identityModel!.tokenType == 'mnemonic';
        hasKeystore = identityModel!.tokenType == 'keystore';
      }
      getChainList();
    }
  }

  void getChainList() async {
    if (identityModel != null) {
      List<CoinModel> chainList = [];
      CoinModel coinModel = new CoinModel(wid: identityModel!.wid);
      List<CoinModel> coinList = await DatabaseUtil.create().queryCoinList(coinModel);
      if (coinList != null && coinList.length > 0) {
        coinList.forEach((element) {
          if (element.symbol == element.contract) {
            chainList.add(element);
          }
        });
        if (mounted) {
          setState(() {
            this.chainList = chainList;
          });
        }
      }
    }
  }

  void modifyNameAction(String title) {
    showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) {
        return InputDialogWidget(
          title: title,
          text: identityModel != null ? identityModel!.name! : "",
          callback: (text) async {
            if (text.isEmptyString() || text == identityModel!.name) {
              return;
            }
            AlertUtil.showLoadingDialog(context, show: true);
            identityModel!.name = text;
            await DatabaseUtil.create().updateIdentity(identityModel!);
            AlertUtil.showLoadingDialog(context, show: false);
            eventBus.fire(UpdateIdentity(identityModel!));
            Get.back(result: {"action": 'refresh'});
          },
        );
      },
    );
  }

  void checkMnemonic() {
    PasswordUtil.handlePassword(context, (text, goback) async {
      String pass = CommonUtil.getTokenId(text);
      var auth = await DatabaseUtil.create().queryAuth();
      if(pass!=auth.password){
        AlertUtil.showWarnBar(ID.CommonPassword.tr);
        return;
      }
      String result = await CommonUtil.decrypt(identityModel!.mnemonic!,pass);
      if (goback) {
        Get.back();
      }
      await showDialog(
          useSafeArea:false,
          context: context, builder: (context){
        return CopyWarmDialogWidget();
      });
      Get.to(WalletMnemonicBackupPage(),arguments: {
      "identityModel":identityModel,
      "mnemonic":result,
      });
    });
  }

  void checkPrivate() {
    showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) {
        return CommonDialogWidget(
          child: Container(
            child: Column(
              children: createChainList(1),
            ),
          ),
        );
      },
    );
  }

  void checkKeystore() {
    showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) {
        return CommonDialogWidget(
          child: Container(
            child: Column(
              children: createChainList(2),
            ),
          ),
        );
      },
    );
  }

  void deleteAction() {
    PasswordUtil.handlePassword(context, (text, goback) async {
      String pass = CommonUtil.getTokenId(text);
      var auth = await DatabaseUtil.create().queryAuth();
      if(pass!=auth.password){
        AlertUtil.showWarnBar(ID.CommonPassword.tr);
        return;
      }
      if (goback) {
        Get.back();
      }
      AlertUtil.showLoadingDialog(context,show: true);
      await DatabaseUtil.create().deleteIdentity(identityModel!);
      String wid = PreferencesUtil.getString(Constant.CURRENT_WID);
      if (wid == identityModel!.wid) {
        wid = "";
        var item = await DatabaseUtil.create().queryIdentityFirst();
        if (item != null) {
          wid = item.wid;
        }
        PreferencesUtil.putString(Constant.CURRENT_WID, wid);
      }
      AlertUtil.showLoadingDialog(context,show: false);
      if (wid.isNotEmptyString()) {
        Get.offAll(HomePage());
      } else {
        Get.off(WalletCreatePage(), transition: Transition.fadeIn);
      }
    });
  }

  List<Widget> createChainList(int type) {
    List<Widget> items = [];
    for (int i = 0; i < chainList.length; i++) {
      CoinModel item = chainList[i];
      String chainName = "";
      if (item.contract == "ETH") {
        chainName = "Ethereum";
      } else if (item.contract == "BNB") {
        chainName = "BSC";
      } else if (item.contract == "MATIC") {
        chainName = "Polygon";
      } else if (item.contract == "TRUE") {
        chainName = "TrueChain";
      } else if (item.contract == "TRX") {
        chainName = "Tron";
      } else if (item.contract == "ABEY") {
        chainName = "ABEY";
      } else if (item.contract == "MAP") {
        chainName = "MAP";
      }
      items.add(InkWell(
        onTap: () async {
          Get.back();
          if (type == 1) {
            showPrivateAction(item.contract!);
          } else if (type == 2) {
            showKeystoreAction(item.contract!);
          } else if (type == 3) {
            showMnemonicAction();
          }
        },
        child: Container(
          height: SizeUtil.height(40),
          child: Center(
            child: Text(chainName, style: AppTheme.text14()),
          ),
        ),
      ));
      items.add(Divider(
        height: 1,
        color: ZColors.ZFFF2F2F2Theme(context),
      ));
    }
    items.add(
      InkWell(
        onTap: () async {
          Get.back();
        },
        child: Container(
          height: SizeUtil.height(40),
          child: Center(
            child: Text(
              ID.CommonCancel.tr,
              style: AppTheme.text14(),
            ),
          ),
        ),
      ),
    );
    return items;
  }

  void showMnemonicAction() {
    PasswordUtil.handlePassword(context, (text, goback) async {
      String pass = CommonUtil.getTokenId(text);
      var auth = await DatabaseUtil.create().queryAuth();
      if (pass != auth.password) {
        AlertUtil.showWarnBar(ID.CommonPassword.tr);
        return;
      }
      String result = await CommonUtil.decrypt(identityModel!.mnemonic!, pass);
      if (goback) {
        Get.back();
      }
      await showDialog(
        useSafeArea: false,
        context: context,
        builder: (context) {
          return CopyWarmDialogWidget();
        },
      );
      Get.to(WalletMnemonicBackupPage(), arguments: {
        "identityModel": identityModel,
        "mnemonic": result,
      });
    });
  }

  void showPrivateAction(String contract) {
    if (contract.toUpperCase() == "TRX") {
      PasswordUtil.handlePassword(context, (text, goback) async {
        String pass = CommonUtil.getTokenId(text);
        var auth = await DatabaseUtil.create().queryAuth();
        if (pass != auth.password) {
          AlertUtil.showWarnBar(ID.CommonPassword.tr);
          return;
        }
        String result = await CommonUtil.decrypt(identityModel!.privateKeyTrx!, pass);
        if (goback) {
          Get.back();
        }
        showDialog(
          useSafeArea: false,
          context: context,
          builder: (context) {
            return CopyDialogWidget(
              title: ID.WalletImportPrivatekey.tr,
              text: result,
              callback: (text) {
                Get.back();
                Clipboard.setData(ClipboardData(text: text));
                AlertUtil.showTipsBar(ID.CommonClipboard.tr);
              },
            );
          },
        );
      });
    } else {
      PasswordUtil.handlePassword(context, (text, goback) async {
        String pass = CommonUtil.getTokenId(text);
        var auth = await DatabaseUtil.create().queryAuth();
        if (pass != auth.password) {
          AlertUtil.showWarnBar(ID.CommonPassword.tr);
          return;
        }
        String result = await CommonUtil.decrypt(identityModel!.privateKey!, pass);
        if (goback) {
          Get.back();
        }
        showDialog(
          useSafeArea: false,
          context: context,
          builder: (context) {
            return CopyDialogWidget(
              title: ID.WalletImportPrivatekey.tr,
              text: result,
              callback: (text) {
                Get.back();
                Clipboard.setData(ClipboardData(text: text));
                AlertUtil.showTipsBar(ID.CommonClipboard.tr);
              },
            );
          },
        );
      });
    }
  }

  void showKeystoreAction(String contract) {
    if (contract.toUpperCase() == "TRX") {
      AlertUtil.showWarnBar(ID.WalletTronExportTip.tr);
    } else {
      PasswordUtil.handlePassword(context, (text, goback) async {
        String pass = CommonUtil.getTokenId(text);
        var auth = await DatabaseUtil.create().queryAuth();
        if (pass != auth.password) {
          AlertUtil.showWarnBar(ID.CommonPassword.tr);
          return;
        }
        String result = await CommonUtil.decrypt(identityModel!.keystore!, pass);
        if (goback) {
          Get.back();
        }
        showDialog(
          useSafeArea: false,
          context: context,
          builder: (context) {
            return CopyDialogWidget(
              title: ID.WalletImportKeystore.tr,
              text: result,
              callback: (text) {
                Get.back();
                Clipboard.setData(ClipboardData(text: text));
                AlertUtil.showTipsBar(ID.CommonClipboard.tr);
              },
            );
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZColors.KFFFFFFFFTheme(context),
      appBar: AppbarWidget.initAppBar(context, isBack: true, title: "${identityModel != null && identityModel!.name!.isNotEmptyString() ? identityModel!.name : ''}"),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: ListView.builder(
                  itemCount: hasMnemonic == true ? 4 : 3,
                  itemBuilder: (context, index) {
                    return getContentItem(context, index);
                  },
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20,right: 20),
              child: CustomWidget.buildButtonImage(() {
                deleteAction();
              },text: ID.WalletDelete.tr),
            ),
            Container(
              padding: SizeUtil.padding(all: 20),
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: identityModel!.wid ?? ''));
                  AlertUtil.showTipsBar(ID.CommonClipboard.tr);
                },
                child: Text(
                    "id:${identityModel != null ? identityModel!.wid : ''}",
                    style: AppTheme.text12(),
                ),
              ),
            ),
            SizedBox(
              height: SizeUtil.height(20),
            ),
          ],
        ),
      ),
    );
  }

  Widget getContentItem(BuildContext context, int index) {
    String title = "";
    if (hasMnemonic == true) {
      switch (index) {
        case 0:
          title = ID.WalletModifyName.tr;
          break;
        case 1:
          title = ID.WalletLookMnemonic.tr;
          break;
        case 2:
          title = ID.WalletLookPrivate.tr;
          break;
        case 3:
          title = ID.WalletLookKeystore.tr;
          break;
      }
    } else {
      switch (index) {
        case 0:
          title = ID.WalletModifyName.tr;
          break;
        case 1:
          title = ID.WalletLookPrivate.tr;
          break;
        case 2:
          title = ID.WalletLookKeystore.tr;
          break;
      }
    }
    return InkWell(
      onTap: () {
        if (hasMnemonic == true) {
          switch (index) {
            case 0:
              modifyNameAction(title);
              break;
            case 1:
              checkMnemonic();
              break;
            case 2:
              checkPrivate();
              break;
            case 3:
              checkKeystore();
              break;
          }
        } else {
          switch (index) {
            case 0:
              modifyNameAction(title);
              break;
            case 1:
              checkPrivate();
              break;
            case 2:
              checkKeystore();
              break;
          }
        }
      },
      child: WalletSetCellWidget(index: index, title: title),
    );
  }
}

class WalletSetCellWidget extends StatelessWidget {
  int? index;
  String? title;

  WalletSetCellWidget({this.index, this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeUtil.width(50),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(width: 15,),
                Text(
                  title!,
                  style: AppTheme.text14(),
                ),
                Spacer(),
                Icon(
                  Icons.arrow_forward_ios_sharp,
                  size: SizeUtil.width(15),
                  color: ZColors.ZFF2D4067Theme(context),
                ),
                SizedBox(width: 15,),
              ],
            ),
          ),
          Container(
            color: ZColors.ZFFEEEEEE,
            height: SizeUtil.height(0.5),
          ),
        ],
      ),
    );
  }
}
