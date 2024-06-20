import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/event/event.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/utils/preferences_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/CustomBehavior.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SetLanguagePage extends StatefulWidget {

  const SetLanguagePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SetLanguagePageState();
  }
}

class SetLanguagePageState extends State<SetLanguagePage> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZColors.KFFFFFFFFTheme(context),
      appBar: AppbarWidget.initAppBar(context, isBack: true,title: ID.MineLanguage.tr,),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              margin: SizeUtil.margin(left: 15,right: 15,top: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(SizeUtil.width(9))),
                color: ZColors.ZFFFFFFFFTheme1(context),
              ),
              child: ScrollConfiguration(
                behavior: CustomBehavior(),
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: Constant.ZLanguages.length,
                    itemBuilder: (context, index) {
                      return getContentItem(context,index);
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getContentItem(BuildContext context, int index) {
    Map<String,String> map = Constant.ZLanguages[index];
    return InkWell(
      onTap: () {
        print('$index');
        PreferencesUtil.putString(Constant.ZLanguage,map["name"]!);
        var local = Locale(map["name"]!);
        Get.updateLocale(local);
        eventBus.fire(ELanguage());
        // Get.back();
      },
      child: SettingLanguageCellWidget(index: index,map: map,),
    );
  }
}

class SettingLanguageCellWidget extends StatelessWidget {
  int? index;
  Map<String,String>? map;

  SettingLanguageCellWidget({this.index,this.map});

  @override
  Widget build(BuildContext context) {
    String current;
    String languageCode = PreferencesUtil.getString(Constant.ZLanguage);
    if (languageCode == null || languageCode.isEmpty) {
      current = 'en';
    } else {
      current = languageCode;
    }

    String name = map!['name']!;
    String content = map!['content']!;

    return Container(
      height: SizeUtil.height(50),
      margin: SizeUtil.margin(top: 5, bottom: 5),
      padding: SizeUtil.padding(top: 5, bottom: 5),
      width: SizeUtil.screenWidth() - SizeUtil.width(30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeUtil.width(15)),
        color: ZColors.KFFF9FAFBTheme(context),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: <Widget>[
                SizedBox(width:  SizeUtil.width(20),),
                Expanded(
                  child: Container(
                    child: Text(
                      content,
                      style: AppTheme.text14(),
                    ),
                  ),
                ),
                Comparable.compare(name, current) == 0 ? Container(
                  child: Icon(
                    Icons.check_circle_outlined,
                    size: SizeUtil.width(25),
                    color: ZColors.ZFFEECC5B,
                  ),
                ) : Container(
                  child: Icon(
                    Icons.check_circle_outlined,
                    size: SizeUtil.width(25),
                    color: ZColors.ZFFCCCCCC,
                  ),
                ),
                SizedBox(width: 20,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
