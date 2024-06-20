import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/callback.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CopyDialogWidget extends StatefulWidget {
  final String? title;
  final String? text;
  final StringCallback? callback;

  const CopyDialogWidget({Key? key, this.title, this.text, this.callback}) : super(key: key);

  @override
  CopyDialogWidgetState createState() => CopyDialogWidgetState();
}

class CopyDialogWidgetState extends State<CopyDialogWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: IntrinsicHeight(
        child: Container(
          margin: EdgeInsets.only(
            left: SizeUtil.width(15),
            right: SizeUtil.width(15),
          ),
          child: Column(
            children: [
              Spacer(),
              Container(
                padding: SizeUtil.padding(left: 0, right: 0, bottom: 10, top: 10),
                width: SizeUtil.screenWidth(),
                decoration: BoxDecoration(
                  color: ZColors.ZFFFAFAFATheme(context),
                  borderRadius: BorderRadius.all(Radius.circular(6.0)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.title != null
                        ? Container(
                            width: SizeUtil.screenWidth(),
                            padding: SizeUtil.padding(top: 10, left: 20, right: 20, bottom: 10),
                            child: Text(
                              widget.title!,
                              textAlign: TextAlign.left,
                              style: AppTheme.text16(),
                            ),
                          )
                        : Container(),
                    Container(
                      padding: SizeUtil.padding(left: 20, right: 20),
                      child: Text(
                        widget.text!,
                        style: AppTheme.text16(),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20,right: 20, bottom: 10),
                      child: CustomWidget.buildButtonImage(() {
                        if (widget.callback != null) {
                          widget.callback!(widget.text!);
                        }
                      },text: ID.CommonCopy.tr),
                    ),
                  ],
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
