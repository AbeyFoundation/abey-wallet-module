import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/global.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/event/event.dart';
import 'package:abey_wallet/model/coin_model.dart';
import 'package:abey_wallet/model/identity_model.dart';
import 'package:abey_wallet/pages/wallet_chain_add.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/service/api_data.dart';
import 'package:abey_wallet/service/api_manager.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/common_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:abey_wallet/widget/dialog/loading_dialog_widget.dart';
import 'package:abey_wallet/widget/status_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:abey_wallet/extension/string_extension.dart';

class KyfChainTokenPage extends StatefulWidget {

  const KyfChainTokenPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return KyfChainTokenPageState();
  }
}

class KyfChainTokenController extends GetxController {
  var showLoading = false.obs;
  var showSearch = false.obs;
  var showSearchLoading = false.obs;

  var searchItems = [].obs;
  var items = [].obs;

  var chainList = <CoinModel>[].obs;
  Rx<CoinModel> chain = CoinModel().obs;

  changeShowSearch(bool show) {
    showSearch.value = show;
  }

  changeShowSearchLoading() {
    showSearchLoading.value = true;
  }

  changeSearchItems(data) {
    if (data == null) {
      data = [];
    }
    searchItems.value = data;
    showSearchLoading.value = false;
  }

  changeItems(data, {bool renew = false}) {
    if (renew) {
      if (data == null) {
        data = [];
      }
      items.value = data;
      showLoading.value = false;
      return;
    }
    if (data != null && data.length > 0) {
      items.addAll(data);
      showLoading.value = false;
    }
  }

  changeChainList(data) {
    if (data == null) {
      data = [];
    }
    data.forEach((element) {
      element.selected = false;
    });
    chainList.value = data;
  }

  changeChain(CoinModel data) {
    chain.value = data;
    showLoading.value = true;
    List<CoinModel> temp = [];
    chainList.value.forEach((element) {
      if (data == element) {
        element.selected = true;
      } else {
        element.selected = false;
      }
      temp.add(element);
    });
    chainList.value = temp;
  }
}

class KyfChainTokenPageState extends State<KyfChainTokenPage> {
  IdentityModel? identityModel;

  KyfChainTokenController kyfChainTokenController = Get.put(KyfChainTokenController());

  TextEditingController searchController = TextEditingController();
  Map<String,List<KyfHotModel>> tempData={};

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      if (Get.arguments['identityModel'] != null) {
        identityModel = Get.arguments['identityModel'];
      }
    }
    Future<dynamic>.delayed(const Duration(milliseconds: 400), () async {
      if (Global.SUPORT_KYFS.isNotEmpty) {
        kyfChainTokenController.changeChainList(Global.SUPORT_KYFS);
        kyfChainTokenController.changeChain(Global.SUPORT_KYFS[0]);
        requestChainToken(Global.SUPORT_KYFS[0]);
      }
    });
  }

  void requestChainToken(CoinModel coinModel) async {
    if(tempData[coinModel.contract]!=null){
      kyfChainTokenController.changeItems(tempData[coinModel.contract], renew: true);
    }
    ApiData apiData = await ApiManager.postKyfHotList(data: {'wid': identityModel!.wid, "contract": coinModel.contract});
    if (apiData.code == 0) {
      KyfHotListModel kyfHotListModel = KyfHotListModel.fromJson(apiData.data);
      if (kyfHotListModel != null) {
        tempData[coinModel.contract!] = kyfHotListModel.items!;
        if(coinModel.contract == kyfChainTokenController.chain.value.contract){
          kyfChainTokenController.changeItems(kyfHotListModel.items, renew: true);
        }
      }
    }
  }

  void requestSearchCoins() async {
    if (searchController.text.isEmptyString()) {
      return;
    }
    kyfChainTokenController.changeShowSearch(true);
    kyfChainTokenController.changeShowSearchLoading();
  }

  Future<bool> requestAddCoin(KyfHotModel coin) async {
    if (!checkContract(coin)) {
      AlertUtil.showWarnBar((ID.WalletChainAdd.tr).replaceAll('{%s}', coin.contract!));
      return true;
    }

    ApiData apiData = await ApiManager.postKyfAdd(data: {
      "wid": identityModel!.wid,
      "contract": coin.contract,
      "contractAddress": coin.contractAddress,
    });
    if (apiData.code == 0) {
      AlertUtil.showTipsBar(ID.WalletAddSuccess.tr);
      if (kyfChainTokenController.showSearch.value) {
        requestSearchCoins();
      }
      requestChainToken(kyfChainTokenController.chain.value);
      eventBus.fire(UpdateKyf());
    }
    return true;
  }

  bool checkContract(KyfHotModel coin) {
    for (int i = 0; i < Global.CURRENT_CONIS.length; i++) {
      CoinModel item = Global.CURRENT_CONIS[i];
      if (item.symbol == coin.contract) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus!.unfocus();
        }
      },
      onPanDown: (_) {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus!.unfocus();
        }
      },
      child:WillPopScope(
        onWillPop: () {
          return Future.value(true);
        },
        child: Scaffold(
            backgroundColor: ZColors.KFFFFFFFFTheme(context),
            appBar: AppbarWidget.initAppBar(context,isBack: true,title: ID.WalletAddToken.tr,),
            body: Stack(
              children: [
                Container(
                  height: double.infinity,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: SizeUtil.width(44),
                        child: createChains(),
                      ),
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: ZColors.ZFFF2F2F2Theme(context),
                      ),
                      Expanded(
                        child: Container(
                          height: double.infinity,
                          child: Column(
                            children: [
                              Expanded(child: createItems()),
                              createChainAdd()
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                createSearch(),
              ],
            )
        ),
      ),
    );
  }

  Widget createChains() {
    return Obx(() {
      return Container(
        margin: SizeUtil.margin(top: 5, bottom: 5),
        width: double.infinity,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            CoinModel coinModel = kyfChainTokenController.chainList[index];
            return ChainCellWidget(coinModel, () {
              kyfChainTokenController.changeChain(coinModel);
              requestChainToken(coinModel);
            });
          },
          itemCount: kyfChainTokenController.chainList.length,
        ),
      );
    });
  }

  Widget createItems() {
    return Obx(() {
      return Container(
        padding: SizeUtil.padding(bottom: 5),
        width: double.infinity,
        height: double.infinity,
        color: ZColors.ZFFF3F4F6Theme(context),
        child:  kyfChainTokenController.items.length > 0 ? ListView.builder(
          itemBuilder: (context, index) {
            KyfHotModel item = kyfChainTokenController.items[index];
            return createItem(item, index, 'normal');
          },
          itemCount: kyfChainTokenController.items.length,
        ) : StatusWidget(LoadStatus.empty),
      );
    });
  }

  Widget createItem(KyfHotModel coin, index, type) {
    return Material(
      color: ZColors.ZFFF3F4F6Theme(context),
      child: InkWell(
        onTap: () async {
        },
        child: Container(
          padding: SizeUtil.padding(top: 6, bottom: 6, left: 15, right: 15),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.5),
                decoration: new BoxDecoration(
                  color: ZColors.ZFFFFFFFFTheme1(context),
                  borderRadius: new BorderRadius.circular(SizeUtil.width(4),),
                ),
                child: CustomWidget.buildNetworkImage(context, coin.icon!, SizeUtil.width(20), SizeUtil.width(20), SizeUtil.width(10)),
              ),
              Expanded(
                child: Container(
                  margin: SizeUtil.margin(left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${coin.name}',
                            style: AppTheme.text14(),
                          ),
                          Text(
                            type == 'search'
                                ? ' (${coin.name} - ${coin.contract} Token)'
                                : ' (${coin.name})',
                            style: AppTheme.text10(),
                          ),
                        ],
                      ),
                      SizedBox(height: 4,),
                      Text(
                        CommonUtil.formatAddress(coin.contractAddress!),
                        style: AppTheme.text10(),
                      ),
                    ],
                  ),
                ),
              ),
              coin.isHas == null || coin.isHas!.isEmpty ? IconButton(
                icon: Icon(
                  Icons.add,
                  color: ZColors.ZFF939CB0Theme(context),
                ),
                onPressed: () async {
                  await requestAddCoin(coin);
                },
              ) : IconButton(
                onPressed: () async {

                },
                icon: Icon(
                  Icons.done,
                  color: ZColors.ZFFEECC5B,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget createChainAdd() {
    return Container(
      margin: SizeUtil.margin(left: 15,right:15,top: 5,bottom: 15),
      child: InkWell(
        onTap: () async {
          await Get.to(WalletChainAddPage(),arguments: {
            'pass':"",
            "identityModel": identityModel,
          });
        },
        child: Container(
          padding: SizeUtil.padding(top: 10,bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(SizeUtil.width(10))),
            border: Border.all(color: ZColors.ZFFEEEEEE,width: 1),
            color: ZColors.ZFFFFFFFFTheme1(context),
          ),
          child: Row(
            children: [
              SizedBox(width: SizeUtil.width(17),),
              Expanded(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ID.WalletAddChain.tr,style: AppTheme.text14(fontWeight: FontWeight.w600),),
                      SizedBox(height: SizeUtil.height(4),),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomWidget.buildPoint(context,size: SizeUtil.height(6),color: ZColors.ZFFA2A6B0,),
                          SizedBox(width: SizeUtil.width(6),),
                          Expanded(child: Text(ID.WalletSupportChain.tr,
                            style: AppTheme.text12(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Image.asset(
                Constant.Assets_Images + "wallet_add.png",
                width: SizeUtil.width(22),
                height: SizeUtil.width(22),
              ),
              SizedBox(width:SizeUtil.width(15),),
            ],
          ),
        ),
      ),
    );
  }

  Widget createSearch() {
    return Obx(() {
      return kyfChainTokenController.showSearch.value ? Container(
        height: double.infinity,
        width: double.infinity,
        child: kyfChainTokenController.showSearchLoading.value
            ? LoadingDialogWidget()
            : kyfChainTokenController.searchItems.length > 0
            ? ListView.builder(
          itemBuilder: (context, index) {
            KyfHotModel item = kyfChainTokenController.searchItems[index];
            return createItem(item, index, 'search');
          },
          itemCount: kyfChainTokenController.searchItems.length,
        ) : StatusWidget(LoadStatus.empty),
      ) : Container();
    });
  }

}

class ChainCellWidget extends StatelessWidget {
  final CoinModel chain;
  final VoidCallback onPressed;

  ChainCellWidget(this.chain, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: SizeUtil.width(34),
        margin: SizeUtil.margin(left: 5, right: 5),
        decoration: new BoxDecoration(
          color: chain.selected! ? ZColors.ZFFEECC5B : ZColors.ZFFFFFFFFTheme1(context),
          borderRadius: new BorderRadius.circular(SizeUtil.width(20)),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 5,),
            Container(
                width: SizeUtil.width(24),
                height: SizeUtil.width(24),
                decoration: new BoxDecoration(
                  color: ZColors.ZFFF5F5F5,
                  borderRadius: new BorderRadius.circular(SizeUtil.width(12),),
                ),
                child: CustomWidget.buildNetworkImage(context, chain.icon!, SizeUtil.width(24), SizeUtil.width(24), SizeUtil.width(12))
            ),
            SizedBox(width: 5,),
            Text(chain.chainName!.isEmptyString() ? chain.contract! : chain.chainName!,
              style: TextStyle(
                color: chain.selected! ? ZColors.ZFFFFFFFF : ZColors.ZFF2D4067,
                fontSize: SizeUtil.sp(12),
              ),
            ),
            SizedBox(width: 5,),
          ],
        ),
      ),
    );
  }
}
