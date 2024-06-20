import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/event/event.dart';
import 'package:abey_wallet/model/coin_model.dart';
import 'package:abey_wallet/model/identity_model.dart';
import 'package:abey_wallet/pages/kyf_token_detail.dart';
import 'package:abey_wallet/pages/kyf_token_receive.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/service/api_data.dart';
import 'package:abey_wallet/service/api_manager.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:abey_wallet/widget/dialog/common_dialog_widget.dart';
import 'package:abey_wallet/widget/dialog/loading_dialog_widget.dart';
import 'package:abey_wallet/widget/status_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';

class KyfTokenPage extends StatefulWidget {

  const KyfTokenPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return KyfTokenPageState();
  }
}

class KyfTokenController extends GetxController {
  var kyfTokenItems = <KyfDetailModel>[].obs;
  var isLoading = false.obs;
  var loadingText = 'loading...'.obs;
  var pageIndex = 1.obs;
  var noMore = false.obs;
  var isFirstLoading = false.obs;

  changeKyfTokenItems(data, {bool renew = false}) {
    if (renew) {
      if (data == null) {
        data = [];
      }
      kyfTokenItems.value.clear();
      kyfTokenItems.value = data;
    } else {
      if (data != null && data.length > 0) {
        kyfTokenItems.addAll(data);
      }
    }
    isLoading.value = false;
    if (data.length == 0 || data.length < 30) {
      changeNoMore(true);
    }
  }

  changeLoading(data) {
    isLoading.value = data;
  }

  changeNoMore(data) {
    noMore.value = data;
  }
}

class KyfTokenPageState extends State<KyfTokenPage> {
  IdentityModel? identityModel;
  KyfModel? kyfModel;

  KyfTokenController kyfTokenController = Get.put(KyfTokenController());
  EasyRefreshController refreshController = EasyRefreshController();

  CoinModel? coinModel;
  bool requesting = false;

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
      requestDate();
    }
    eventBus.on<UpdateTradeKyfBack>().listen((event) async {
      tradeActionKyfBack();
    });
  }

  void tradeActionKyfBack() {
    requestDate();
  }

  void requestDate() async {
    if (requesting == false) {
      requesting = true;
    } else {
      return;
    }
    ApiData apiData = await ApiManager.postKyfIndex(data:{
      "wid": identityModel!.wid,
      "contract": kyfModel!.contract
    });
    if (apiData.code == 0) {
      KyfListModel kyfListModel = KyfListModel.fromJson(apiData.data);
      if (kyfListModel != null) {
        for (int i = 0;i < kyfListModel.items!.length; i++) {
          KyfModel model = kyfListModel.items![i];
          if (kyfModel!.contractAddress == model.contractAddress) {
            kyfModel = model;
          }
        }
        if (mounted) {
          setState(() {

          });
        }
      }
    }
    ApiData apiData2 = await ApiManager.postKyfDetail(data:{
      "wid": identityModel!.wid,
      "contract": kyfModel!.contract,
      "contractAddress": kyfModel!.contractAddress,
      "page": kyfTokenController.pageIndex.value,
      "size": 30,
    });
    requesting = false;
    if (apiData2.code == 0) {
      KyfDetailListModel kyfDetailListModel = KyfDetailListModel.fromJson(apiData2.data);
      if (kyfDetailListModel != null) {
        kyfTokenController.changeKyfTokenItems(kyfDetailListModel.items, renew: kyfTokenController.pageIndex.value == 1);
        kyfTokenController.pageIndex.value += 1;
      }
    } else {
      AlertUtil.showTipsBar(ID.CommonNetworkError.tr);
    }
  }

  Future<bool> hideAction() async {
    AlertUtil.showLoadingDialog(context, show: true);
    ApiData apiData = await ApiManager.postKyfHide(data: {
      "wid": identityModel!.wid,
      "contract": kyfModel!.contract,
      "contractAddress": kyfModel!.contractAddress
    });
    if (apiData.code == 0) {
    }
    AlertUtil.showLoadingDialog(context, show: false);

    eventBus.fire(UpdateKyf());
    Get.back();
    return true;
  }

  void showActionDialog() {
    showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) {
        return CommonDialogWidget(
          child: Container(
            child: Column(
              children: [
                InkWell(
                  onTap: () async {
                    Get.back();
                    await hideAction();
                  },
                  child: Container(
                    height: 44,
                    child: Text(
                      ID.WalletTokenDelete.tr,
                      style: AppTheme.text14(),
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  color: ZColors.ZFFF5F5F5,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZColors.KFFFFFFFFTheme(context),
      appBar: AppbarWidget.initAppBar(context, isBack: true, title: kyfModel!.name!, widget: Builder(
        builder: (context) {
          return SizedBox(
            child: IconButton(
              icon: Icon(
                Icons.more_horiz_outlined,
                color: ZColors.ZFF2D4067Theme(context),
              ),
              onPressed: () {
                showActionDialog();
              },
            ),
          );
        },
      )),
      body: Container(
        child: appContent(),
      ),
    );
  }

  Widget appContent() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Padding(
              padding: SizeUtil.padding(left: 10, right: 10),
              child: EasyRefresh(
                header: MaterialHeader(),
                onRefresh: () async {
                  if (mounted) {
                    kyfTokenController.changeNoMore(false);
                    kyfTokenController.pageIndex.value = 1;
                    requestDate();
                  }
                },
                  onLoad: () async {
                    requestDate();
                  },
                controller: refreshController,
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      actions: <Widget>[],
                      automaticallyImplyLeading: false,
                      floating: false,
                      centerTitle: true,
                      backgroundColor: ZColors.KFFFFFFFFTheme(context),
                      foregroundColor: ZColors.ZFFFFFFFFTheme(context),
                      expandedHeight: SizeUtil.width(160),//220
                      flexibleSpace: FlexibleSpaceBar(
                        background: createHeader(),
                      ),
                    ),
                    Obx(() {
                      if (kyfTokenController.isFirstLoading.value) {
                        return SliverToBoxAdapter(
                          child: Container(
                            height: SizeUtil.screenWidth(),
                            width: SizeUtil.screenWidth(),
                            child: LoadingDialogWidget(),
                          ),
                        );
                      } else {
                        return kyfTokenController.kyfTokenItems.length < 1
                            ? SliverToBoxAdapter(child: StatusWidget(LoadStatus.empty))
                            : SliverGrid(
                          delegate: SliverChildBuilderDelegate((BuildContext context, int position) {
                            return getItemContainer(kyfTokenController.kyfTokenItems[position]);
                          },
                            childCount: kyfTokenController.kyfTokenItems.length,
                          ),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: SizeUtil.width(10.0),
                              crossAxisSpacing: SizeUtil.width(10.0),
                              childAspectRatio: 0.7
                          ),
                        );
                      }
                    }),
                    Obx(() => SliverToBoxAdapter(
                      child: Visibility(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Center(
                            child: Text(
                              kyfTokenController.loadingText.value,
                              style: AppTheme.text12(),
                            ),
                          ),
                        ),
                        visible: kyfTokenController.isLoading.value,
                      ),
                    )), //Visibility),
                  ],
                )
              )
          ),
        ),
        Padding(
            padding: SizeUtil.padding(left: 10, right: 10, bottom: 15),
            child: CustomWidget.buildButtonImage(() {
              if (kyfModel != null) {
                Get.to(KyfTokenReceivePage(), arguments: {"kyfModel": kyfModel});
              }
            },text: ID.KyfReceive.tr)
        ),
      ],
    );
  }

  Widget createHeader() {
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: SizeUtil.width(10),
          ),
          Hero(
            tag: "${kyfModel!.contract}${kyfModel!.contractAddress}_icon",
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: new BoxDecoration(
                color: ZColors.ZFFF3F4F6Theme(context),
                borderRadius: new BorderRadius.circular(SizeUtil.width(5),),
              ),
              child: CustomWidget.buildNetworkImage(context, kyfModel!.icon!, SizeUtil.width(60), SizeUtil.width(60), SizeUtil.width(10)),
            ),
          ),
          SizedBox(
            height: SizeUtil.width(12),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: "${kyfModel!.contract}${kyfModel!.contractAddress}_title",
                child: Text(
                  kyfModel != null && kyfModel!.name != null ? kyfModel!.name! : "",
                  style: AppTheme.text14(),
                ),
              ),
              SizedBox(
                width: SizeUtil.width(5),
              ),
              Text(
                "(" + (kyfModel != null && kyfModel!.balance != null ? kyfModel!.balance! : "0") + " " + ID.KyfPiece.tr + ")",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.text14(),
              ),
            ],
          ),
          SizedBox(
            height: SizeUtil.width(6),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                (kyfModel != null && kyfModel!.madeby != null ? kyfModel!.madeby! : ""),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.text12(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getItemContainer(KyfDetailModel item) {
    double height = SizeUtil.width(2004);
    return GestureDetector(
      onTap: () {
        Get.to(KyfTokenDetailPage(), arguments: {
          "identityModel": identityModel,
          "kyfModel": kyfModel,
          "kyfDetailModel": item,
        });
      },
      child: Container(
        height: height,
        width: double.infinity,
        decoration: new BoxDecoration(
          color: ZColors.KFFF9FAFBTheme(context),
          borderRadius: new BorderRadius.circular(SizeUtil.width(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.only(left: 5, top: 5, right: 5),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(SizeUtil.width(10))),
                  child: Hero(
                    tag: item.id.toString() + "_" + (item.img ?? "common_placeholder.png"),
                    child: CustomWidget.buildNetworkImage(context, item.img!, double.infinity, double.infinity, SizeUtil.width(10)),
                  ),
                ),
              ),
            ),
            Container(
              padding: SizeUtil.padding(left: 10, right: 10, top: 10),
              child: Text(
                item != null && item.name != null ? item.name! : "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.text12(),
              ),
            ),
            Container(
              padding: SizeUtil.padding(left: 10, right: 10, bottom: 10, top: 2),
              child: Text(
                ID.KyfTokenId.tr + ' ' + (item != null && item.tokenId != null ? item.tokenId! : ""),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.text12(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}