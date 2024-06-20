import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/common/global.dart';
import 'package:abey_wallet/pages/common_pdf.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:abey_wallet/widget/dialog/version_update_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SetAboutPage extends StatefulWidget {

  const SetAboutPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SetAboutPageState();
  }
}

class SetAboutPageState extends State<SetAboutPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZColors.KFFFFFFFFTheme(context),
      appBar: AppbarWidget.initAppBar(context, isBack: true, title: ID.MineAbout.tr,),
      body: Container(
        child: appContent(),
      ),
    );
  }

  Widget appContent() {
    return Column(
      children: <Widget>[
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

        Container(
          margin: SizeUtil.margin(left: 15,right: 15,top: 12),
          padding: SizeUtil.padding(all: 20),
          decoration: BoxDecoration(
            border: new Border.all(color: Colors.grey[200]!, width: 1,),
            borderRadius: SizeUtil.radius(all: 10),
            color: ZColors.KFFF9FAFBTheme(context),
          ),
          child: Text(
            ID.MineAboutInfo.tr,
            style: AppTheme.text14(),
          ),
        ),

        SizedBox(height: SizeUtil.width(10),),

        Container(
          margin: SizeUtil.margin(left: 15,right: 15,top: 12),
          decoration: BoxDecoration(
            borderRadius: SizeUtil.radius(all: 9),
            color: ZColors.KFFF9FAFBTheme(context),
          ),
          child: InkWell(
            onTap: () {
              Get.to(CommonPdfPage(), arguments: {"url": Global.PAGE_AGREEMENT});
            },
            child: getContentNormal(ID.MineAboutProperty.tr,),
          ),
        ),

        Container(
          margin: SizeUtil.margin(left: 15,right: 15,top: 12),
          decoration: BoxDecoration(
            borderRadius: SizeUtil.radius(all: 9),
            color: ZColors.KFFF9FAFBTheme(context),
          ),
          child: InkWell(
            onTap: () {
              Future.delayed(Duration(seconds: 1),() async {
                await checkUpdate(context,(data){},isAbout: true);
              });
            },
            child: getContentNormal(ID.MineAboutVersion.tr,),
          ),
        ),
      ],
    );
  }

  getContentNormal(String label) {
    return  Container(
      height: SizeUtil.height(45),
      child:Row(
        children: <Widget>[
          SizedBox(width: SizeUtil.width(20),),
          Container(
            child: Text(
              label,
              style: AppTheme.text14(),
            ),
          ),
          Spacer(),
          Container(
            margin: SizeUtil.margin(left: 10,right: 14),
            child: Icon(Icons.arrow_forward_ios,size: SizeUtil.width(14),color: ZColors.ZFF2D4067Theme(context),),
          )
        ],
      ),
    );
  }
}