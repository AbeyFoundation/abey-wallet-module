import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/callback.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiscoverIdentityDialogWidget extends StatefulWidget {
  final String? icon;
  final String? name;
  final String? url;
  final String? chain;
  final BoolCallback? callback;

  const DiscoverIdentityDialogWidget({Key? key, this.icon, this.name, this.url, this.chain, this.callback}) : super(key: key);

  @override
  DiscoverIdentityDialogWidgetState createState() => DiscoverIdentityDialogWidgetState();
}

class DiscoverIdentityDialogWidgetState extends State<DiscoverIdentityDialogWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String desc = ID.DiscoverTip.tr.replaceAll("{name}", widget.name!);
    return GestureDetector(
      child: IntrinsicHeight(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: SizeUtil.padding(left: 0, right: 0, bottom: 40, top: 20),
                width: SizeUtil.screenWidth(),
                decoration: BoxDecoration(
                  color: ZColors.ZFFFAFAFATheme(context),
                  borderRadius: BorderRadius.all(Radius.circular(6.0)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Text(
                        ID.WalletAuthorization.tr,
                        style: AppTheme.text16(),
                      ),
                    ),
                    Container(
                      width: SizeUtil.screenWidth(),
                      margin: SizeUtil.margin(all: 14, right: 14),
                      padding: SizeUtil.padding(all: 10),
                      decoration: BoxDecoration(
                        color: ZColors.ZFFFFFFFFTheme1(context),
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: SizeUtil.width(60),
                            height: SizeUtil.width(60),
                            padding: SizeUtil.padding(all: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: ZColors.ZFFF5F5F5),
                              borderRadius: BorderRadius.all(Radius.circular(6.0)),
                            ),
                            child: CustomWidget.buildNetworkImage(context, widget.icon ?? "", SizeUtil.width(50), SizeUtil.width(50), SizeUtil.width(6))
                          ),
                          Container(
                            padding: SizeUtil.padding(left: 10, right: 10, top: 10),
                            child: Text(
                              desc,
                              style: AppTheme.text14(color: ZColors.ZFF2D4067Theme(context)),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: SizeUtil.padding(left: 20, right: 20),
                      width: SizeUtil.screenWidth(),
                      child: Row(
                        children: [
                          Container(
                            width: (SizeUtil.screenWidth() - SizeUtil.width(60))/2,
                            height: 40,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(Constant.Assets_Images + "common_button_empty.png"),
                                    fit: BoxFit.fill
                                )
                            ),
                            child: MaterialButton(
                              onPressed: () {
                                if (widget.callback != null) {
                                  widget.callback!(false);
                                }
                              },
                              minWidth: SizeUtil.width(300),
                              height: SizeUtil.width(45),
                              child: Text(
                                ID.CommonCancel.tr,
                                style: AppTheme.text16(color: ZColors.ZFFB0B0B0, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: SizeUtil.width(20),
                          ),
                          Container(
                            width: (SizeUtil.screenWidth() - SizeUtil.width(60))/2,
                            height: 40,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(Constant.Assets_Images + "common_button_back.png"),
                                    fit: BoxFit.fill
                                )
                            ),
                            child: MaterialButton(
                              onPressed: () {
                                if (widget.callback != null) {
                                  widget.callback!(true);
                                }
                              },
                              minWidth: SizeUtil.width(300),
                              height: SizeUtil.width(45),
                              child: Text(
                                ID.CommonConfirm.tr,
                                style: AppTheme.text16(color: ZColors.ZFFFFFFFF, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
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
