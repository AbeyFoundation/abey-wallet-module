import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/event/event.dart';
import 'package:abey_wallet/model/identity_model.dart';
import 'package:abey_wallet/model/name_value_model.dart';
import 'package:abey_wallet/pages/common_webview.dart';
import 'package:abey_wallet/pages/kyf_token_transfer.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/service/api_data.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:abey_wallet/extension/string_extension.dart';
import 'package:get/get.dart';

class KyfTokenDetailPage extends StatefulWidget {

  const KyfTokenDetailPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return KyfTokenDetailPageState();
  }
}

class KyfTokenDetailPageState extends State<KyfTokenDetailPage> {
  IdentityModel? identityModel;
  KyfModel? kyfModel;
  KyfDetailModel? kyfDetailModel;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      if (Get.arguments['identityModel'] != null) {
        identityModel = Get.arguments['identityModel'];
      }
      if (Get.arguments['kyfModel'] != null) {
        kyfModel = Get.arguments['kyfModel'];
      }
      if (Get.arguments['kyfDetailModel'] != null) {
        kyfDetailModel = Get.arguments['kyfDetailModel'];
      }
    }
    eventBus.on<UpdateTradeKyf>().listen((event) async {
      tradeActionKyf();
    });
  }

  void tradeActionKyf() {
    eventBus.fire(UpdateTradeKyfBack());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZColors.KFFFFFFFFTheme(context),
      appBar: AppbarWidget.initAppBar(context, isBack: true, title: ID.KyfDetail.tr,),
      body: Container(
        child: appContent(),
      ),
    );
  }

  Widget appContent() {
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(
                  height: SizeUtil.width(10),
                ),
                Container(
                  margin: EdgeInsets.only(left: SizeUtil.width(16), right: SizeUtil.width(16)),
                  width: SizeUtil.screenW - SizeUtil.width(32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(SizeUtil.width(16)),
                    color: ZColors.KFFF9FAFBTheme(context),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          createAvatar(),
                          createInfo(),
                        ],
                      ),
                      Positioned(
                          right: SizeUtil.width(16),
                          top: SizeUtil.screenW - SizeUtil.width(108),
                          child: createShowButton(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        kyfModel != null && kyfModel?.banTransfer != null && kyfModel?.banTransfer?.isNotEmptyString() && kyfModel?.banTransfer == "1" ? Container() : Padding(
            padding: SizeUtil.padding(left: 15, right: 15, bottom: 15),
            child: CustomWidget.buildButtonImage(() {
              if (kyfModel != null) {
                Get.to(KyfTokenTransferPage(), arguments: {
                  "identityModel": identityModel,
                  "kyfModel": kyfModel,
                  "kyfDetailModel": kyfDetailModel,
                });
              }
            },text: ID.KyfTransfer.tr)
        ),

      ],
    );
  }

  Widget createAvatar() {
    if (kyfModel != null && kyfModel!.name != null) {
      return createNormalAvatar();
    } else {
      return Container(
        height: 0,
      );
    }
  }

  Widget createNormalAvatar() {
    return Container(
      padding: SizeUtil.padding(all: 10),
      width: SizeUtil.screenW - SizeUtil.width(32),
      height: SizeUtil.screenW - SizeUtil.width(32),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(SizeUtil.width(16))),
        child: Hero(
          tag: kyfDetailModel!.id.toString() + "_" + (kyfDetailModel!.img ?? "common_placeholder.png"),
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: kyfDetailModel != null && kyfDetailModel!.img != null ? kyfDetailModel!.img! : "",
            placeholder: (context, url) => Image.asset(
              Constant.Assets_Images + "common_placeholder.png",
            ),
            errorWidget: (context, url, error) => Image.asset(
              Constant.Assets_Images + "common_placeholder.png",
            ),
          ),
        ),
      ),
    );
  }

  Widget createInfo() {
    return Container(
      padding: SizeUtil.padding(all: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kyfDetailModel != null && kyfDetailModel!.name != null ? kyfDetailModel!.name! : "",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.text14(),
          ),
          SizedBox(
            height: SizeUtil.width(4),
          ),
          Text(
            ID.KyfTokenId.tr + ' ' + (kyfDetailModel != null && kyfDetailModel!.tokenId != null ? kyfDetailModel!.tokenId! : ""),
            style: AppTheme.text14(),
          ),
          Column(
            children: createList(),
          ),
        ],
      ),
    );
  }

  List<Widget> createList() {
    List<Widget> items = [];
    if (kyfDetailModel!.attributes != null && kyfDetailModel!.attributes!.length > 0) {
      items.add(
        Divider(
          thickness: SizeUtil.height(1),
          color: ZColors.ZFFFFFFFF,
          height: SizeUtil.height(24),
        ),
      );
    }
    for (int i = 0; i < kyfDetailModel!.attributes!.length; i++) {
      NameValueModel nameValue = kyfDetailModel!.attributes![i];
      items.add(
        Container(
          padding: SizeUtil.padding(top: 5, bottom: 5),
          child: Row(
            children: [
              Text(
                nameValue != null && nameValue.name != null ? nameValue.name! : "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.text14(),
              ),
              Spacer(),
              Text(
                nameValue != null && nameValue.value != null ? nameValue.value! : "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.text14(),
              ),
            ],
          ),
        ),
      );
    }
    return items;
  }

  Widget createShowButton() {
    return (kyfDetailModel != null && kyfDetailModel!.detail != null && kyfDetailModel!.detail != '') ? GestureDetector(
      onTap: () {
        Get.to(CommonWebviewPage(), arguments: {
          'url': kyfDetailModel != null && kyfDetailModel!.detail != null ? kyfDetailModel!.detail : "",
          "title": kyfDetailModel != null && kyfDetailModel!.name != null ? kyfDetailModel!.name : ""
        });
      },
      child: Container(
        decoration: BoxDecoration(
            color: ZColors.ZFFF5CA40,
            borderRadius: BorderRadius.circular(SizeUtil.width(30)),
            gradient: LinearGradient(
                colors: [ZColors.ZFFF5CA40, ZColors.ZFFF5CA40,ZColors.ZFFF5CA40]
            ),
            boxShadow: [
              BoxShadow(
                  color: ZColors.ZFFF5CA40,
                  offset: Offset(0.0, 0.0),
                  blurRadius: 15.0,
                  spreadRadius: 2.0
              )
            ]),
        alignment: Alignment.center,
        height: SizeUtil.width(60),
        width: SizeUtil.width(60),
        child: Text(
          ID.KyfShow.tr,
          style: AppTheme.text14(),
        ),
      ),
    ) : Container();
  }
}