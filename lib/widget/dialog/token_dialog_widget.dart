import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/callback.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/model/coin_model.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TokenDialogWidget extends StatefulWidget {
  final List<CoinModel>? chainList;
  final CoinModelCallback? coinCallback;

  const TokenDialogWidget({Key? key, this.chainList, this.coinCallback}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TokenDialogWidgetState();
  }
}

class TokenDialogWidgetState extends State<TokenDialogWidget> {

  @override
  void initState() {
    super.initState();
  }

  void tokenItemAction(CoinModel coinModel) {
    if (widget.coinCallback != null) {
      widget.coinCallback!(coinModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: IntrinsicHeight(
        child: Container(
          margin: EdgeInsets.only(top: SizeUtil.screenHeight()/4),
          width: SizeUtil.screenWidth(),
          decoration: BoxDecoration(
            color: ZColors.KFFFFFFFFTheme(context),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Spacer(),
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      margin: SizeUtil.margin(left: 10,top: 10,right: 10,bottom: 10),
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      child: Container(
                        width: SizeUtil.width(24),
                        height: SizeUtil.width(24),
                        padding: EdgeInsets.all(SizeUtil.width(5.5)),
                        decoration: BoxDecoration(
                          color: ZColors.KFFFFFFFFTheme(context),
                          borderRadius: BorderRadius.circular(SizeUtil.width(12)),
                        ),
                        child: Image.asset(
                          Constant.Assets_Images + "common_close.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      createTokens(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget createTokens() {
    return ListView.builder(
      key: PageStorageKey<String>('Token'),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return getTokenItem(context, index);
      },
      itemCount: widget.chainList != null ? widget.chainList?.length : 0,
      padding: EdgeInsets.all(0.0),
    );
  }

  getTokenItem(BuildContext context, int index) {
    if (widget.chainList != null && widget.chainList!.length > index) {
      CoinModel coinModel = widget.chainList![index];
      return Container(
        margin: SizeUtil.margin(left: 20, right: 20, top: 2.5, bottom: 2.5),
        height: SizeUtil.width(54),
        decoration: BoxDecoration(
          color: ZColors.KFFF9FAFBTheme(context),
          borderRadius: SizeUtil.radius(all: 10),
        ),
        child: InkWell(
          onTap: () {
            tokenItemAction(coinModel);
          },
          child: Container(
            child: Row(
              children: [
                Container(
                  margin: SizeUtil.margin(left: SizeUtil.width(12), right: SizeUtil.width(12)),
                  width: SizeUtil.width(30),
                  height: SizeUtil.width(30),
                  child: CustomWidget.buildNetworkImage(context, (coinModel != null && coinModel.icon != null ? coinModel.icon! : ""), SizeUtil.width(30), SizeUtil.width(30), SizeUtil.width(4), placeholder: "common_placeholder_token.png"),
                ),
                Expanded(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          coinModel != null && coinModel.symbol != null ? coinModel.symbol! : "",
                          style: AppTheme.text14(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          coinModel != null && coinModel.balance != null ? coinModel.balance! : "",
                          textAlign: TextAlign.right,
                          style: AppTheme.text14(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

}