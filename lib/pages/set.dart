import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/global.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/event/event.dart';
import 'package:abey_wallet/pages/set_about.dart';
import 'package:abey_wallet/pages/set_common.dart';
import 'package:abey_wallet/pages/set_currency.dart';
import 'package:abey_wallet/pages/set_language.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class SetPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SetPageState();
  }
}

class SetPageState extends State<SetPage> with TickerProviderStateMixin {
  List<Map<String,String>>? drawerList;

  @override
  void initState() {
    super.initState();
    eventBus.on<ELanguage>().listen((event) {
      setDrawerListArray();
    });
    setDrawerListArray();
  }

  void setDrawerListArray() {
    drawerList = [
      {
        "labelName": ID.MineLanguage.tr,
        "imageName": Constant.Assets_Images + 'mine_language.png',
      },
      {
        "labelName": ID.MinePrice.tr,
        "imageName": Constant.Assets_Images + 'mine_currency.png',
      },
      {
        "labelName": ID.MineSet.tr,
        "imageName": Constant.Assets_Images + 'mine_set.png',
      },
      {
        "labelName": ID.MineAbout.tr,
        "imageName": Constant.Assets_Images + 'mine_about.png',
      },
      {
        "labelName": ID.MineFeedback.tr,
        "imageName": Constant.Assets_Images + 'mine_feedback.png',
      },
    ];
    if (mounted) {
      setState(() {

      });
    }
  }

  void itemClick(int index) async {
    switch (index) {
      case 0: {
        Get.to(SetLanguagePage(), arguments: {});
      }
      break;
      case 1: {
        Get.to(SetCurrencyPage(), arguments: {});
      }
      break;
      case 2: {
        Get.to(SetCommonPage(), arguments: {});
      }
      break;
      case 3: {
        Get.to(SetAboutPage(), arguments: {});
      }
      break;
      case 4: {
        await launchFeedback("mailto:inquiry@abeychain.com");
      }
      break;
    }
  }

  static Future<Null> launchFeedback(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      AlertUtil.showTipsBar(ID.MineEmailUnistall.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZColors.KFFFFFFFFTheme(context),
      appBar: AppbarWidget.initAppBar(context, isBack: false, title: ID.Mine.tr, ),
      body: appContent(),
    );
  }

  Widget appContent() {
    return Column(
      children: [
        SizedBox(height: 30),
        Image.asset(
          Constant.Assets_Images + "common_icon_70.png",
          width: 70,
          height: 70,
        ),
        SizedBox(height: 15,),
        Container(
          alignment: Alignment.center,
          child: Text(
            Global.zPackageInfo!.version,
            style: AppTheme.text20(),
          ),
        ),
        SizedBox(height: SizeUtil.width(10),),
        Expanded(
          child: Container(
            margin: SizeUtil.margin(left: 15, right: 15, bottom: 15),
            decoration: BoxDecoration(
              borderRadius: SizeUtil.radius(all: 10),
              color: ZColors.KFFF9FAFBTheme(context),
            ),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(0.0),
              itemCount: drawerList?.length,
              itemBuilder: (BuildContext context, int index) {
                return inkwell(drawerList![index], index);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget inkwell(Map<String,String> listData, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.grey.withOpacity(0.1),
        highlightColor: Colors.transparent,
        onTap: () {
          itemClick(index);
        },
        child: Stack(
          children: <Widget>[
            Container(
              height: 60,
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                children: <Widget>[
                  SizedBox(width: 10,),
                  Container(
                    width: 24,
                    height: 24,
                    child: Image.asset(listData["imageName"]!),
                  ),
                  SizedBox(width: 5,),
                  Text(
                    listData["labelName"]!,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: ZColors.ZFF2D4067Theme(context),
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios,size: SizeUtil.width(12),color: ZColors.ZFF2D4067Theme(context),),
                  SizedBox(width: 10,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}