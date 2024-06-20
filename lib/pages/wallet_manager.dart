import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/callback.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/event/event.dart';
import 'package:abey_wallet/model/coin_model.dart';
import 'package:abey_wallet/model/identity_model.dart';
import 'package:abey_wallet/pages/wallet_set.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/service/api_data.dart';
import 'package:abey_wallet/service/api_manager.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/common_util.dart';
import 'package:abey_wallet/utils/database_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:abey_wallet/widget/dialog/common_dialog_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class WalletManagerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletManagerPageState();
  }
}

class WalletManagerPageState extends State<WalletManagerPage> {
  IdentityModel? identityModel;
  List<CoinModel> chainList = [];

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      if (Get.arguments['identityModel'] != null) {
        identityModel = Get.arguments['identityModel'];
      }
      getChainList();
    }
  }

  Future<bool> getChainList() async {
    if (identityModel != null) {
      List<CoinModel> chainList = [];
      CoinModel coinModel = new CoinModel(wid: identityModel!.wid);
      List<CoinModel> coinList = await DatabaseUtil.create().queryCoinList(coinModel);
      if (coinList != null && coinList.length > 0) {
        coinList.forEach((element) {
          if (element.symbol == element.contract) {
            chainList.add(element);
          }
        });
        if (mounted) {
          setState(() {
            this.chainList = chainList;
          });
        }
      }
    }
    return true;
  }

  void setAction() async {
    await Get.to(WalletSetPage(),arguments: {"identityModel": identityModel});
    await getChainList();
  }

  Future<bool> deleteCoinModel(CoinModel coinModel) async {
    AlertUtil.showLoadingDialog(context,show: true);
    await DatabaseUtil.create().deleteCoin(coinModel);
    ApiData apiData = await ApiManager.postWalletDeleteChain(data:{
      "wid": identityModel!.wid,
      "contract": coinModel.contract
    });
    await DatabaseUtil.create().deleteCoin(coinModel);
    await getChainList();
    eventBus.fire(UpdateChain());
    AlertUtil.showLoadingDialog(context,show: false);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZColors.KFFFFFFFFTheme(context),
      appBar: AppbarWidget.initAppBar(context, isBack: true, title: ID.WalletManager.tr, widget: Builder(
        builder: (context) {
          return SizedBox(
            child: IconButton(
              icon:Icon(Icons.settings,color: ZColors.ZFF2D4067Theme(context),),
              onPressed: () {
                setAction();
              },
            ),
          );
        },
      )),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: buildChainList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildChainList() {
    return Container(
      child: ListView.builder(
        itemCount: chainList.length,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return getContentItem(context, index);
        },
      ),
    );
  }

  Widget getContentItem(BuildContext context,int index) {
    CoinModel coinModel = chainList[index];
    return InkWell(
      onTap: () {
        if (coinModel != null) {
          Clipboard.setData(ClipboardData(text: coinModel.address));
          AlertUtil.showTipsBar(ID.CommonClipboard.tr);
        }
      },
      child: WalletManagerCellWidget(index: index,model: coinModel, voidCallback: () {
        showActionDialog(coinModel);
      }),
    );
  }

  showActionDialog(CoinModel coinModel) async{
    return await showDialog(
        useSafeArea:false,
        context: context,
        builder: (context) {
          return CommonDialogWidget(
            child: Container(
              child: Column(
                children: [
                  InkWell(
                      onTap: () async {
                        await deleteCoinModel(coinModel);
                        Get.back();

                      },
                      child: Container(
                        height: 44,
                        child: Text(
                          ID.WalletTokenDelete.tr,
                          style: AppTheme.text14(),
                        ),
                      ),
                  ),
                  Divider(height: 1,color: ZColors.ZFFF2F2F2Theme(context),)
                ],
              ),
            ),
          );
        },
    );
  }
}

class WalletManagerCellWidget extends StatelessWidget {
  int? index;
  CoinModel? model;
  VoidCallback? voidCallback;

  WalletManagerCellWidget({this.index,this.model, this.voidCallback});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeUtil.width(60),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(width: SizeUtil.width(15),),
                Container(
                  padding: SizeUtil.margin(all: 4),
                  width: SizeUtil.width(40),
                  height: SizeUtil.width(40),
                  decoration: new BoxDecoration(
                      color: ZColors.ZFFFFFFFFTheme1(context),
                      borderRadius: new BorderRadius.circular(SizeUtil.width(20)),
                  ),
                  child: CustomWidget.buildNetworkImage(context, model!.icon!, SizeUtil.width(32), SizeUtil.width(32), SizeUtil.width(16))
                ),
                SizedBox(width: SizeUtil.width(15),),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding:SizeUtil.padding(bottom: 4),
                      child: Text(model!.symbol!,style: AppTheme.text14(fontWeight: FontWeight.w600),overflow: TextOverflow.ellipsis),
                    ),
                    Text(CommonUtil.formatAddress(model!.address!),style: AppTheme.text12(),textAlign: TextAlign.center,overflow: TextOverflow.ellipsis),
                  ],
                ),),
                SizedBox(width: 50,),
                model!.symbol!.compareTo("ABEY") != 0 ?
                Container(
                    child: IconButton(icon: Icon(Icons.more_horiz_outlined,color: ZColors.ZFF2D4067Theme(context),),onPressed: () async {
                      voidCallback!();
                    },)
                ) : Container(),
              ],
            ),
          ),
          Container(
            color: ZColors.ZFFCCCCCC,
            height: SizeUtil.height(0.5),
          ),
        ],
      ),
    );
  }

}