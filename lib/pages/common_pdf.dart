import 'package:abey_wallet/common/zcolor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:get/get.dart';
import 'package:share_extend/share_extend.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class CommonPdfPage extends StatefulWidget {
  const CommonPdfPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CommonPdfPageState();
  }
}

class CommonPdfPageState extends State<CommonPdfPage> {
  String url = "";
  String title = "";

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      if (Get.arguments['url'] != null) {
        url = Get.arguments['url'];
      }
      if (Get.arguments['title'] != null) {
        title = Get.arguments['title'];
      }
    }
  }

  back() async {
    Get.back();
  }

  shareAction() async {
    ShareExtend.share(url, "text");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZColors.KFFFFFFFFTheme(context),
      appBar: AppBar(
        title: Text(title.isNotEmpty ? title : ''),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            size: SizeUtil.width(20),
            color: ZColors.ZFF2D4067Theme(context),
          ),
          onPressed: () {
            back();
          },
        ),
        actions: [
          Builder(builder: (context) {
            return Container(
              padding: SizeUtil.padding(top: 10, bottom: 10, right: 10),
              child: Container(
                height: SizeUtil.height(30),
                decoration: BoxDecoration(
                  color: ZColors.ZFFFFFFFFTheme(context),
                  border: Border.all(color: Colors.grey, width: SizeUtil.width(0.5)),
                  borderRadius:
                  BorderRadius.circular(SizeUtil.width(30)),
                ),
                padding: SizeUtil.padding(left: 7, right: 7),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    InkWell(
                      child: Icon(
                        Icons.share,
                        size: SizeUtil.width(17),
                        color: ZColors.ZFF2D4067Theme(context),
                      ),
                      onTap: () {
                        shareAction();
                      },
                    ),
                    Container(
                      margin: SizeUtil.padding(left: 5, right: 5),
                      height: SizeUtil.width(15),
                      width: SizeUtil.width(1),
                      color: Colors.grey,
                    ),
                    InkWell(
                      child: Icon(
                        Icons.close,
                        size: SizeUtil.width(20),
                        color: ZColors.ZFF2D4067Theme(context),
                      ),
                      onTap: () {
                        Get.back();
                      },
                    ),
                  ],
                ),
              ),
            );
          })
        ],
      ),
      body: Container(
        child: url != null ? SfPdfViewer.network(
          url
        ) : Container(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}