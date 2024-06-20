import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/callback.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/common/global.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:abey_wallet/extension/string_extension.dart';
import 'package:get/get.dart';

class AgreementDialogWidget extends StatefulWidget {
  final BoolCallback? callback;

  const AgreementDialogWidget({Key? key,  this.callback}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AgreementDialogWidgetState();
  }
}

class AgreementDialogWidgetState extends State<AgreementDialogWidget> {
  String? _url;
  bool _checked=false;

  WebViewController? _iosViewController;
  JavascriptChannel? jhostChannel;

  @override
  void initState() {
    super.initState();
    _url = Global.PAGE_AGREEMENT.isNotEmptyString() ? Global.PAGE_AGREEMENT : '';
  }

  void _commit() {
    if(!_checked){
      AlertUtil.showWarnBar(ID.MinePropertySelect.tr);
      return;
    }
    if(widget.callback!=null){
      widget.callback!(_checked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: IntrinsicHeight(
          child: Container(
            margin: EdgeInsets.only(top: 100),
            padding: SizeUtil.padding(left: 0, right: 0, bottom: 40, top: 20),
            width: SizeUtil.screenWidth(),
            decoration: BoxDecoration(
              color: ZColors.ZFFFAFAFATheme(context),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(6.0), topRight: Radius.circular(6.0)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Text(
                    ID.MineAboutProperty.tr,
                    style: AppTheme.text16(),
                  ),
                ),
                Expanded(child:  Container(
                  width: SizeUtil.screenWidth(),
                  margin: SizeUtil.margin(all: 14, right: 14),
                  padding: SizeUtil.padding(all: 10),
                  decoration: BoxDecoration(
                    color: ZColors.ZFFFFFFFF,
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                  ),
                  child: _url != null && _url!.isNotEmpty ? SfPdfViewer.network(
                      _url!
                  ) : Container(),
                ),),

                Container(
                  margin: SizeUtil.margin(left: 30,right: 30,top: 10),
                  width: SizeUtil.screenWidth(),
                  height: 40,
                  child: Row(
                    children: [
                      Material(
                        child: Checkbox(
                            value: _checked,

                            onChanged: (value) {
                              setState(() {
                                _checked = value!;
                              });
                            },
                        ),
                      ),
                      Text(ID.MinePropertyTip.tr,style: AppTheme.text14(),),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20,right: 20,),
                  child: CustomWidget.buildButtonImage(() {
                    _commit();
                  },text: ID.CommonConfirm.tr),
                )
              ],
            ),
          ),
        ),
    );
  }

  Widget _createWebView(){
    Widget  webview = WebView(
      initialUrl: _url,
      javascriptMode: JavascriptMode.unrestricted,
      javascriptChannels: <JavascriptChannel>[].toSet(),
      onWebViewCreated: (WebViewController web) {
        _iosViewController = web;
      },
      onPageFinished: (url) {
      },
    );
    return webview;
  }

  @override
  void dispose() {
    super.dispose();
  }
}