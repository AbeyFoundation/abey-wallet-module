import 'dart:io';

import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/callback.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/common/global.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/service/api_data.dart';
import 'package:abey_wallet/service/api_manager.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/math_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

checkUpdate(BuildContext context, BoolCallback callback, {bool isAbout = false}) async {
  ApiData apiData = await ApiManager.postConfigVersion(data: {
    "wid": "",
  });
  if (apiData.code == 0) {
    ConfigUpdateModel configUpdateModel = ConfigUpdateModel.fromJson(apiData.data);
    if (configUpdateModel != null) {
      callback(configUpdateModel.force != null && configUpdateModel.force == 1 ? true : false);
      if (int.parse(Global.CLIENT_C) < configUpdateModel.vCode!) {
        if (Platform.isIOS) {
          if (Global.IS_WHEEL) {
            return await showUpdateDialog(context, configUpdateModel);
          }
        } else {
          return await showUpdateDialog(context, configUpdateModel);
        }
      } else {
        if (isAbout == true) {
          AlertUtil.showTipsBar(ID.CommonVersionTip.tr);
        }
      }
    }
  } else {}
  return Future.value(apiData);
}

showUpdateDialog(BuildContext context, ConfigUpdateModel configUpdateModel) async {
  return await showDialog(
      useSafeArea: false,
      barrierDismissible: !(configUpdateModel.force != null && configUpdateModel.force == 1 ? true : false),
      context: context,
      builder: (context) {
        return configUpdateModel.force != null && configUpdateModel.force == 1
            ? WillPopScope(
                child: VersionUpdateDialogWidget(
                  configUpdateModel: configUpdateModel,
                ),
                onWillPop: () async {
                  SystemNavigator.pop();
                  return false;
                })
            : VersionUpdateDialogWidget(
                configUpdateModel: configUpdateModel,
              );
      });
}

class VersionUpdateDialogWidget extends StatefulWidget {
  static final String sName = "UpdateVersionDialog";
  final ConfigUpdateModel? configUpdateModel;

  VersionUpdateDialogWidget({Key? key, this.configUpdateModel}) : super(key: key);

  @override
  VersionUpdateDialogWidgetState createState() => new VersionUpdateDialogWidgetState();
}

class VersionUpdateDialogWidgetState extends State<VersionUpdateDialogWidget> {
  ConfigUpdateModel? configUpdateModel;
  var _downloadProgress = 0.0;
  bool isDownLoad = false;
  String updateText = ID.CommonVersionUpdate.tr;

  @override
  void initState() {
    super.initState();
    configUpdateModel = widget.configUpdateModel;
  }

  void updateAction() {
      _openUrl(configUpdateModel!.url!);
  }

  void closeAction() {
    if (configUpdateModel != null && configUpdateModel!.force != null && configUpdateModel!.force == 1) {
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else {
        exit(0);
      }
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Duration insetAnimationDuration = const Duration(milliseconds: 100);
    Curve insetAnimationCurve = Curves.decelerate;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedPadding(
        padding: MediaQuery.of(context).viewInsets + const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
        duration: insetAnimationDuration,
        curve: insetAnimationCurve,
        child: MediaQuery.removeViewInsets(
          removeLeft: true,
          removeTop: true,
          removeRight: true,
          removeBottom: true,
          context: context,
          child: Container(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Stack(
                    children: [
                      Container(
                        margin: SizeUtil.margin(top: 20),
                        width: double.infinity,
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: ZColors.ZFF1F1343,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: SizeUtil.width(147) - SizeUtil.height(20),
                                  ),
                                  Container(
                                    padding: SizeUtil.padding(left: 14, right: 14),
                                    width: double.infinity,
                                    child: Text(
                                      ID.CommonVersionTip1.tr + '(v${configUpdateModel != null && configUpdateModel!.vName != null ? configUpdateModel!.vName : ""})',
                                      style: AppTheme.text18(fontWeight: FontWeight.normal, color: ZColors.ZFFFFFFFF),
                                    ),
                                  ),
                                  SizedBox(height: SizeUtil.height(14)),
                                  Container(
                                    padding: SizeUtil.padding(left: 14, right: 14, top: 4, bottom: 4),
                                    width: double.infinity,
                                    child: Text(
                                      configUpdateModel != null && configUpdateModel!.vNote != null ? configUpdateModel!.vNote! : "",
                                      style: AppTheme.text12(color: ZColors.ZFFA0A0A8),
                                      strutStyle: StrutStyle(),
                                    ),
                                  ),
                                  SizedBox(height: SizeUtil.height(10)),
                                  Divider(
                                    height: 1,
                                    color: ZColors.ZFFA0A0A8,
                                  ),
                                  SizedBox(height: SizeUtil.height(10)),
                                  Container(
                                    width: SizeUtil.screenWidth() - SizeUtil.width(140),
                                    height: 40,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: AssetImage(Constant.Assets_Images + "common_button_back.png"),
                                            fit: BoxFit.fill
                                        )
                                    ),
                                    child: MaterialButton(
                                      onPressed: () {
                                        updateAction();
                                      },
                                      minWidth: SizeUtil.width(300),
                                      height: SizeUtil.width(45),
                                      child: Text(
                                        updateText,
                                        style: AppTheme.text16(color: ZColors.ZFFFFFFFF, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: SizeUtil.height(10)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: SizeUtil.margin(left: (SizeUtil.screenWidth() - 80 - SizeUtil.width(136))/2, right: (SizeUtil.screenWidth() - 80 - SizeUtil.width(136))/2),
                        width: SizeUtil.width(136),
                        child: Image.asset(
                            Constant.Assets_Images + "common_update_version.png",
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      SizedBox(height: SizeUtil.height(15)),
                      IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.white60,
                          ),
                          onPressed: () {
                            closeAction();
                          }),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  set progress(_progress) {
    setState(() {
      _downloadProgress = _progress;
      updateText = ID.CommonVersionTip2.tr + ' ${MathUtil.start(_progress).multiply(100).toString()}%';
      if (_downloadProgress == 1) {
        Navigator.of(context).pop();
        _downloadProgress = 0.0;
      }
    });
  }
}

GlobalKey<VersionUpdateDialogWidgetState> updateDialogKey = GlobalKey();

void _openUrl(String url) async {
  if (Platform.isAndroid && await canLaunch(url)) {
    await (launch(url));
  } else {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
