import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/callback.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/common/global.dart';
import 'package:abey_wallet/event/event.dart';
import 'package:abey_wallet/model/auth_model.dart';
import 'package:abey_wallet/model/coin_model.dart';
import 'package:abey_wallet/model/identity_model.dart';
import 'package:abey_wallet/pages/wallet_chain_add.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/service/api_data.dart';
import 'package:abey_wallet/service/api_manager.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/chain_util.dart';
import 'package:abey_wallet/utils/common_util.dart';
import 'package:abey_wallet/utils/database_util.dart';
import 'package:abey_wallet/utils/password_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/utils/toast_util.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:abey_wallet/widget/dialog/loading_dialog_widget.dart';
import 'package:abey_wallet/widget/status_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:abey_wallet/extension/string_extension.dart';

class WalletChainTokenPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletChainTokenPageState();
  }
}

class WalletChainTokenController extends GetxController {
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

class WalletChainTokenPageState extends State<WalletChainTokenPage> {
  IdentityModel? identityModel;

  WalletChainTokenController walletChainTokenController = Get.put(WalletChainTokenController());

  TextEditingController searchController = TextEditingController();
  Map<String,List<CoinModel>> tempData={};

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      if (Get.arguments['identityModel'] != null) {
        identityModel = Get.arguments['identityModel'];
      }
    }

    Future<dynamic>.delayed(const Duration(milliseconds: 400), () async {
      if (Global.SUPORT_CHAINS.isNotEmpty) {
        walletChainTokenController.changeChainList(Global.SUPORT_CHAINS);
        walletChainTokenController.changeChain(Global.SUPORT_CHAINS[0]);
        requestChainToken(Global.SUPORT_CHAINS[0]);
      }
    });
  }

  void requestChainToken(CoinModel coinModel) async {
    if(tempData[coinModel.contract]!=null){
      walletChainTokenController.changeItems(tempData[coinModel.contract], renew: true);
    }
    ApiData apiData = await ApiManager.postWalletHotList(data: {'wid': identityModel!.wid, "contract": coinModel.contract});
    if (apiData.code == 0) {
      WalletChainTokenListModel walletChainTokenListModel = WalletChainTokenListModel.fromJson(apiData.data);
      if (walletChainTokenListModel != null) {
        tempData[coinModel.contract!] = walletChainTokenListModel.items!;
        if(coinModel.contract == walletChainTokenController.chain.value.contract){
          walletChainTokenController.changeItems(walletChainTokenListModel.items, renew: true);
        }
      }
    }
  }

  void requestSearchCoins() async {
    if (searchController.text.isEmptyString()) {
      return;
    }
    walletChainTokenController.changeShowSearch(true);
    walletChainTokenController.changeShowSearchLoading();
  }

  Future<bool> requestAddCoin(CoinModel coin) async {
    if (!checkContract(coin)) {
      AlertUtil.showWarnBar((ID.WalletChainAdd.tr).replaceAll('{%s}', coin.contract!));
      return true;
    }
    await PasswordUtil.handlePassword(context, (text, goback) async {
      String pass = text;
      pass = CommonUtil.getTokenId(text);
      AuthModel auth = await DatabaseUtil.create().queryAuth();
      if (auth.password != pass) {
        AlertUtil.showWarnBar(ID.CommonPassword.tr);
        return Future.value(null);
      } else {
        if (goback) {
          Get.back();
        }
        ApiData apiData = await ApiManager.postWalletAdd(data: {
          "wid": identityModel!.wid,
          "symbol": coin.symbol,
          "contract": coin.contract,
          "contractAddress": coin.contractAddress,
          "assetName": coin.assetName != null ? coin.assetName : "",
        });
        if (apiData.code == 0) {
          await ChainUtil.saveCoin(context, identityModel!, 0, [coin], pass, false);
          AlertUtil.showTipsBar(ID.WalletAddSuccess.tr);
          if (walletChainTokenController.showSearch.value) {
            requestSearchCoins();
          }
          requestChainToken(walletChainTokenController.chain.value);
          eventBus.fire(UpdateChain());
        } else {
          AlertUtil.showWarnBar(ID.CommonNetworkError.tr);
        }
      }
    });
    return true;
  }

  bool checkContract(CoinModel coin) {
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
            CoinModel coinModel = walletChainTokenController.chainList[index];
            return ChainCellWidget(coinModel, () {
              walletChainTokenController.changeChain(coinModel);
              requestChainToken(coinModel);
            });
          },
          itemCount: walletChainTokenController.chainList.length,
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
        child:  walletChainTokenController.items.length > 0 ? ListView.builder(
          itemBuilder: (context, index) {
            CoinModel item = walletChainTokenController.items[index];
            return createItem(item, index, 'normal');
          },
          itemCount: walletChainTokenController.items.length,
        ) : StatusWidget(LoadStatus.empty),
      );
    });
  }

  Widget createItem(CoinModel coin, index, type) {
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
                              '${coin.symbol}',
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
              coin.isHas == null || coin.isHas == false ? IconButton(
                icon: Icon(
                  Icons.add,
                  color: ZColors.ZFF939CB0Theme(context),
                ),
                onPressed: () async {
                  await requestAddCoin(coin);
                },
              ) : IconButton(
                onPressed: () {

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
      return walletChainTokenController.showSearch.value ? Container(
        height: double.infinity,
        width: double.infinity,
        child: walletChainTokenController.showSearchLoading.value
            ? LoadingDialogWidget()
            : walletChainTokenController.searchItems.length > 0
            ? ListView.builder(
          itemBuilder: (context, index) {
            CoinModel item = walletChainTokenController.searchItems[index];
            return createItem(item, index, 'search');
          },
          itemCount: walletChainTokenController.searchItems.length,
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
