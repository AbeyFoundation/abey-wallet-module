import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CopyWarmDialogWidget extends StatefulWidget {
  const CopyWarmDialogWidget({Key? key}) : super(key: key);

  @override
  CopyWarmDialogWidgetState createState() => CopyWarmDialogWidgetState();
}

class CopyWarmDialogController extends GetxController {
  var dismiss = true.obs;

  onDismiss() => {dismiss.value = false, dismiss.refresh()};

  onShow() => {dismiss.value = true, dismiss.refresh()};
}

class CopyWarmDialogWidgetState extends State<CopyWarmDialogWidget> {
  CopyWarmDialogController? boardController;

  @override
  void initState() {
    super.initState();
    try {
      boardController = Get.find(tag: "CopyBoard");
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    boardController?.onShow();
    return GestureDetector(
      child: IntrinsicHeight(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: SizeUtil.padding(left: 0, right: 0, bottom: 20, top: 10),
                width: SizeUtil.screenWidth(),
                decoration: BoxDecoration(
                  color: ZColors.ZFFFAFAFATheme(context),
                  borderRadius: BorderRadius.all(Radius.circular(6.0)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      margin: SizeUtil.margin(left: 15, right: 15),
                      padding: SizeUtil.padding(top: 5),
                      child: Column(
                        children: [
                          Container(
                            child: Text(
                              ID.WalletTakeNot.tr,
                              style: AppTheme.text16(fontWeight: FontWeight.w600),
                            ),
                          ),

                          Container(
                            margin: SizeUtil.margin(top: 15,bottom: 10),
                            width: SizeUtil.width(60),
                            height: SizeUtil.width(60),
                            decoration: BoxDecoration(
                              borderRadius: SizeUtil.radius(all: 40),
                              border: Border.all(
                                width: SizeUtil.width(5),
                                style: BorderStyle.solid,
                                color: ZColors.ZFFEECC5B,
                              ),
                            ),
                            child: Icon(
                              Icons.no_photography_rounded,
                              size: SizeUtil.width(45),
                              color: ZColors.ZFFEECC5B,
                            ),
                          ),

                          Container(
                            margin: SizeUtil.margin(left: 30, right: 30, top: 10, bottom: 10),
                            alignment: Alignment.center,
                            child: Text(
                              ID.WalletTakeNotTip.tr,
                              textAlign: TextAlign.center,
                              style: AppTheme.text14(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(),
                    Container(
                      margin: EdgeInsets.only(left: 30,right: 30, bottom: 10),
                      child: CustomWidget.buildButtonImage(() {
                        Get.back();
                      },text: ID.WalletGotIt.tr),
                    ),
                  ],
                ),
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
    boardController?.onDismiss();
  }
}