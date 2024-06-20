import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/service/api_data.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:abey_wallet/extension/string_extension.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_extend/share_extend.dart';

class KyfTokenReceivePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return KyfTokenReceivePageState();
  }
}

class KyfTokenReceivePageState extends State<KyfTokenReceivePage> {
  KyfModel? kyfModel;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      if (Get.arguments['kyfModel'] != null) {
        kyfModel = Get.arguments["kyfModel"];
      }
    }
  }

  void shareAction() {
    if (kyfModel != null && kyfModel!.address!.isNotEmptyString()) {
      ShareExtend.share(kyfModel!.address!, "text");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZColors.KFFFFFFFFTheme(context),
      appBar: AppbarWidget.initAppBar(context, isBack: true, title: ID.WalletReceive.tr,),
      body: Container(
        color: ZColors.ZFF1F1343,
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              padding: SizeUtil.padding(top: 10, bottom: 10, left: 14, right: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    Constant.Assets_Images + "wallet_warming.png",
                    width: SizeUtil.width(14),
                  ),
                  Expanded(
                    child: Container(
                      padding: SizeUtil.padding(bottom: 2, left: 8),
                      child: Text(
                        ID.WalletReceiveTip.tr
                            .replaceAll("{##}", kyfModel != null && kyfModel!.contract!.isNotEmptyString() ? kyfModel!.contract! : "##"),
                        style: AppTheme.text12(color: ZColors.ZFFFFFFFF, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: SizeUtil.margin(top: 10),
              width: SizeUtil.width(325),
              height: SizeUtil.height(432),
              decoration: new BoxDecoration(
                color: ZColors.KFFF9FAFBTheme(context),
                borderRadius: new BorderRadius.all(new Radius.circular(SizeUtil.width(10))),
              ),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Padding(
                    padding: SizeUtil.padding(top: 30, bottom: 20),
                    child: Text(
                      '${ID.WalletTransferScan.tr} ${kyfModel != null && kyfModel!.name!.isNotEmptyString() ? kyfModel!.name : ""}',
                      style: AppTheme.text14(),
                    ),
                  ),
                  Container(
                    height: SizeUtil.height(226),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          Constant.Assets_Images + "qrcode_back.png",
                          width: SizeUtil.width(226),
                          height: SizeUtil.width(226),
                        ),
                        Container(
                          margin: EdgeInsets.all(5),
                          color: ZColors.ZFFF9FAFB,
                          child: QrImageView(
                            data: kyfModel != null && kyfModel!.address!.isNotEmptyString() ? kyfModel!.address! : "",
                            version: QrVersions.auto,
                            size: SizeUtil.width(184),
                            gapless: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: SizeUtil.padding(bottom: 10),
                    child: Text(
                      ID.WalletAddress.tr,
                      style: AppTheme.text14(),
                    ),
                  ),
                  Padding(
                    padding: SizeUtil.padding(top: 5, left: 10, right: 10),
                    child: Text(
                      "${kyfModel != null && kyfModel!.address!.isNotEmptyString() ? kyfModel!.address : ''}",
                      textAlign: TextAlign.center,
                      style: AppTheme.text12(),
                    ),
                  ),
                  Container(
                    margin: SizeUtil.margin(top: 30, left: 10, right: 10),
                    child: Flex(
                      children: List.generate((SizeUtil.width(325)/4).floor(), (_) {
                        return SizedBox(
                          width: 2,
                          height: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: ZColors.ZFF0E9F4B),
                          ),
                        );
                      }),
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      direction: Axis.horizontal,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: SizeUtil.padding(bottom: 25, left: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            onTap: shareAction,
                            child: SizedBox(
                              width: SizeUtil.width(50),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    Constant.Assets_Images + "common_share.png",
                                    width: SizeUtil.width(22),
                                    height: SizeUtil.width(22),
                                  ),
                                  SizedBox(height: 4,),
                                  Text(
                                    ID.CommonShare.tr,
                                    style: AppTheme.text14(),
                                  )
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (kyfModel != null) {
                                Clipboard.setData(ClipboardData(text: kyfModel!.address));
                                AlertUtil.showTipsBar(ID.CommonClipboard.tr);
                              }
                            },
                            child: SizedBox(
                              width: SizeUtil.width(50),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    Constant.Assets_Images + "common_copy.png",
                                    width: SizeUtil.width(22),
                                    height: SizeUtil.width(22),
                                  ),
                                  SizedBox(height: 4,),
                                  Text(
                                    ID.CommonCopy.tr,
                                    style: AppTheme.text14(),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
