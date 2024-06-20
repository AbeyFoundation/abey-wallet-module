import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/global.dart';
import 'package:abey_wallet/model/identity_model.dart';
import 'package:abey_wallet/pages/home.dart';
import 'package:abey_wallet/pages/wallet_create.dart';
import 'package:abey_wallet/utils/database_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/vender/chain/chaincore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplishPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplishPageState();
  }
}

class SplishPageState extends State<SplishPage> {
  bool isFinish = false;

  @override
  void initState() {
    super.initState();

    initAccount();
    SizeUtil.init();
    Future.delayed(Duration(milliseconds: 3000), () {
      _next();
    });
  }

  void initAccount() async {
    ChainCore.install(context,
        ChainConfig(
            'assets/files/core.html',
        ) ,
        callback: () {
        });

    await Global.install(context);
  }

  _next() async {
    List<IdentityModel> identityList = await DatabaseUtil.create().queryIdentityList();
    if (identityList != null && identityList.length > 0) {
      Get.off(HomePage(), transition: Transition.fadeIn);
    } else {
      Get.off(WalletCreatePage(), transition: Transition.fadeIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Global.getPlatform() == "iOS") {
      String image = "750x1334.jpg";
      if (SizeUtil.screenWidth() == 640 && SizeUtil.screenHeight() == 960) {
        image = "640x960.jpg";
      } else if (SizeUtil.screenWidth() == 640 && SizeUtil.screenHeight() == 1136) {
        image = "640x1136.jpg";
      } else if (SizeUtil.screenWidth() == 750 && SizeUtil.screenHeight() == 1334) {
        image = "750x1334.jpg";
      } else if (SizeUtil.screenWidth() == 828 && SizeUtil.screenHeight() == 1792) {
        image = "828x1792.jpg";
      } else if (SizeUtil.screenWidth() == 1125 && SizeUtil.screenHeight() == 2436) {
        image = "1125x2436.jpg";
      } else if (SizeUtil.screenWidth() == 1242 && SizeUtil.screenHeight() == 2208) {
        image = "1242x2208.jpg";
      } else if (SizeUtil.screenWidth() == 1242 && SizeUtil.screenHeight() == 2688) {
        image = "1242x2688.jpg";
      }
      return Scaffold(
        body: Container(
          alignment: Alignment.center,
          width: SizeUtil.screenWidth(),
          height: SizeUtil.screenHeight(),
          child: Image.asset(
            Constant.Assets_Images + image,
            fit: BoxFit.cover,
            width: SizeUtil.screenWidth(),
            height: SizeUtil.screenHeight(),
          ),
        ),
      );
    } else {
      String image = "750x1334.jpg";
      if (SizeUtil.screenWidth()/SizeUtil.screenHeight() < 0.47) {
        image = "1125x2436.jpg";
      } else if (SizeUtil.screenWidth()/SizeUtil.screenHeight() < 0.57) {
        image = "1242x2688.jpg";
      } else if (SizeUtil.screenWidth()/SizeUtil.screenHeight() < 0.67) {
        image = "640x960.jpg";
      }
      return Scaffold(
        body: Container(
          alignment: Alignment.center,
          width: SizeUtil.screenWidth(),
          height: SizeUtil.screenHeight(),
          child: Image.asset(
            Constant.Assets_Images + image,
            fit: BoxFit.cover,
            width: SizeUtil.screenWidth(),
            height: SizeUtil.screenHeight(),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}