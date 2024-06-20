import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/pages/set_address.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/common_util.dart';
import 'package:abey_wallet/utils/database_util.dart';
import 'package:abey_wallet/utils/localauth_util.dart';
import 'package:abey_wallet/utils/preferences_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:abey_wallet/widget/dialog/password_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:encrypt/encrypt.dart' as ENC;

class SetCommonPage extends StatefulWidget {

  const SetCommonPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SetCommonPageState();
  }
}

class SetCommonPageState extends State<SetCommonPage> {
  bool strOpen = false;

  @override
  void initState() {
    super.initState();
    String str = PreferencesUtil.getString(Constant.WalletLocalAuth);
    if (str != null && str.isNotEmpty) {
      if (str == "true") {
        strOpen = true;
      } else {
        strOpen = false;
      }
    }

  }

  void switchAction() async {
    if (strOpen) {
      await showDialog(
          useSafeArea:false,
          context: context, builder: (context){
        return PasswordDialogWidget(callback: (text) async{
          String pass = CommonUtil.getTokenId(text);
          var auth = await DatabaseUtil.create().queryAuth();
          if (pass != auth.password) {
            Get.back();
            AlertUtil.showWarnBar(ID.CommonPassword.tr);
            return;
          } else {
            strOpen = !(strOpen);
            PreferencesUtil.putString(Constant.WalletLocalAuth,"false");
            if (mounted) {
              setState(() {

              });
            }
            Get.back();
            return;
          }
        },);
      });
    } else {
      bool isSupport = await LocalauthUtil().isSupportBiometrics();
      if (isSupport) {
        await showDialog(
            useSafeArea:false,
            context: context, builder: (context){
          return PasswordDialogWidget(callback: (text) async{
            String pass = CommonUtil.getTokenId(text);
            var auth = await DatabaseUtil.create().queryAuth();
            if (pass != auth.password) {
              Get.back();
              AlertUtil.showWarnBar(ID.CommonPassword.tr);
              return;
            } else {
              final key = ENC.Key.fromUtf8('asdfghjklqwertyuiopzxcvbnm123456');
              final iv = ENC.IV.fromLength(16);
              final encrypter = ENC.Encrypter(ENC.AES(key));
              final encrypted = encrypter.encrypt(text, iv: iv);
              PreferencesUtil.putString(Constant.WalletLocalAuthPwd,encrypted.base64);

              strOpen = !(strOpen);
              PreferencesUtil.putString(Constant.WalletLocalAuth,"true");
              if (mounted) {
                setState(() {

                });
              }
              Get.back();
              return;
            }
          },);
        });
      } else {
        AlertUtil.showWarnBar(ID.CommonDeviceUnsupport.tr);
      }
    }

  }

  void addressAction() {
    Get.to(SetAddressPage(), arguments: {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZColors.KFFFFFFFFTheme(context),
      appBar: AppbarWidget.initAppBar(context, isBack: true,title: ID.MineSet.tr,),
      body: Container(
        child: Column(
          children: <Widget>[
            SizedBox(height: SizeUtil.height(12),),
            Container(
              margin: SizeUtil.margin(left: 15,right: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(SizeUtil.width(9))),
                color: ZColors.KFFF9FAFBTheme(context),
              ),
              child: Column(
                children: [
                  SetItemSwitchWidget(
                    image: "mine_touchid.png",
                    title: ID.MineTouchId.tr,
                    isOpen: strOpen,
                    callback: () => {
                      this.switchAction()
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: SizeUtil.width(12),),
            Container(
              margin: SizeUtil.margin(left: 15,right: 15),
              height: SizeUtil.width(60),//183
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(SizeUtil.width(9))),
                color: ZColors.KFFF9FAFBTheme(context),
              ),
              child: Column(
                children: [
                  SetItemWidget(
                    image: "common_address.png",
                    title: ID.MineAddressBook.tr,
                    callback: () => {
                      this.addressAction()
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SetItemSwitchWidget extends StatelessWidget {
  int? index;

  String? image = "";
  String? title = "";

  bool? isOpen = false;
  VoidCallback? callback;

  SetItemSwitchWidget({this.index,this.image,this.title, this.isOpen, this.callback});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeUtil.width(60),
      child: Row(
        children: [
          SizedBox(width: SizeUtil.width(20),),
          Image.asset(
            Constant.Assets_Images + image!,
            width: SizeUtil.width(27),
            height: SizeUtil.width(28),
          ),
          SizedBox(width: SizeUtil.width(14),),
          Expanded(
            flex: 1,
            child: Container(
              child: Text(
                title!.tr,
                style: AppTheme.text14(),
              ),
            ),
          ),
          SizedBox(width: SizeUtil.width(20),),
          Switch(
            value: isOpen!,
            activeColor: Colors.green,
            onChanged: (value) {
              if (callback != null) {
                callback!();
              }
            },
          ),
          SizedBox(width: SizeUtil.width(10),),
        ],
      ),
    );
  }

}

class SetItemWidget extends StatelessWidget {
  int? index;

  String? image = "";
  String? title = "";

  VoidCallback? callback;

  SetItemWidget({this.index,this.image,this.title, this.callback});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (callback != null) {
          callback!();
        }
      },
      child: Container(
        height: SizeUtil.width(60),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: SizeUtil.width(20),),
            Image.asset(
              Constant.Assets_Images + image!,
              color: Colors.blue,
              width: SizeUtil.width(25),
              height: SizeUtil.width(25),
            ),
            SizedBox(width: SizeUtil.width(14),),
            Expanded(
              flex: 1,
              child: Container(
                child: Text(
                  title!.tr,
                  style: AppTheme.text14(),
                ),
              ),
            ),
            SizedBox(width: SizeUtil.width(20),),
            Container(
              margin: SizeUtil.margin(left: 10,right: 14),
              child: Icon(Icons.arrow_forward_ios,size: SizeUtil.width(14),color: ZColors.ZFF2D4067Theme(context),),
            ),
            SizedBox(width: SizeUtil.width(10),),
          ],
        ),
      ),
    );
  }

}
