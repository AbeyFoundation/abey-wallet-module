import 'dart:io';

import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/common/global.dart';
import 'package:abey_wallet/event/event.dart';
import 'package:abey_wallet/model/coin_model.dart';
import 'package:abey_wallet/model/identity_model.dart';
import 'package:abey_wallet/model/wallet_panel_extent_model.dart';
import 'package:abey_wallet/model/wallet_panel_model.dart';
import 'package:abey_wallet/pages/common_webview.dart';
import 'package:abey_wallet/pages/wallet_chain_add.dart';
import 'package:abey_wallet/pages/wallet_chain_token.dart';
import 'package:abey_wallet/pages/wallet_create.dart';
import 'package:abey_wallet/pages/wallet_token.dart';
import 'package:abey_wallet/pages/wallet_token_receive.dart';
import 'package:abey_wallet/pages/wallet_token_transfer.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/service/api_data.dart';
import 'package:abey_wallet/service/api_manager.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/common_util.dart';
import 'package:abey_wallet/utils/database_util.dart';
import 'package:abey_wallet/utils/preferences_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/extension/string_extension.dart';
import 'package:abey_wallet/extension/list_extension.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:abey_wallet/widget/dialog/common_dialog_widget.dart';
import 'package:abey_wallet/widget/dialog/token_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WalletPageState();
  }
}

class WalletPageController extends GetxController {
  var wid = "".obs;
  Rx<IdentityModel> identityModel = IdentityModel().obs;
  var identityModelList = <IdentityModel>[].obs;
  var coinModelList = <CoinModel>[].obs;
  Rx<WalletIndexModel> walletIndexModel = WalletIndexModel().obs;

  var showGroup = false.obs;
  var groups = <WalletPanelModel>[].obs;
  var contract = "".obs;

  changeWid(data) => wid.value = data;

  changeIdentityModel(data) => identityModel.value = data;

  changeIdentityModelList(data) => identityModelList.value = data;

  changeCoinModelList(data) {
    if (data != null) {
      coinModelList.clear();
      coinModelList.addAll(data);

      List<WalletPanelModel> tmpList = [];
      Map<String, WalletPanelModel> tmpMap = {};
      coinModelList.forEachWithIndex((index, element) {
        if (tmpMap[element.contract] == null) {
          tmpMap[element.contract] = WalletPanelModel();
          tmpMap[element.contract]!.coinModelList = [];
        }
        if (element.contract == element.symbol) {
          tmpMap[element.contract]!.coinModel = element;
        } else {
          tmpMap[element.contract]!.coinModelList!.add(element);
        }
      });
      tmpMap.values.forEach((element) {
        tmpList.add(element);
      });
      changeGroups(tmpList);
    }
  }

  changeWalletIndexModel(data) {
    if (data != null) {
      walletIndexModel.value = data;
      changeCoinModelList(data.items);
    }
  }

  changeShowGroup(data) {
    showGroup.value = data;
  }

  changeGroups(data) {
    groups.value = data;
  }

  changeContract(data) {
    if (data != null) {
      contract.value = data;
    }
  }
}

class WalletPageState extends State<WalletPage> {
  WalletPageController walletPageController = Get.put(WalletPageController());
  EasyRefreshController refreshController = EasyRefreshController();
  String defaultCSUnit = '';

  bool showAssets = true;
  List<WalletPanelExtentModel> walletPanelExtentList = <WalletPanelExtentModel>[];

  List<CoinModel> chainList = [];
  String currentChain = "ABEY";

  CoinModel? coinModel;
  bool isFirst = true;

  @override
  void initState() {
    super.initState();

    eventBus.on<UpdateIdentity>().listen((event) {
      initData();
    });
    eventBus.on<ECurrency>().listen((event) {
      initCoin();
      requestDate();
    });
    eventBus.on<UpdateChain>().listen((event) {
      initCoin();
      requestDate();
    });
    eventBus.on<UpdateBalance>().listen((event) {
      initCoin();
      requestDate();
    });

    initData();
  }

  void initData() async {
    eventBus.fire(UpdateDrawer());
    walletPageController.changeWid(PreferencesUtil.getString(Constant.CURRENT_WID));
    await initIdentity();
    await initCoin();
    changNChain("ABEY");

    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  initIdentity() async {
    var identity = await DatabaseUtil.create().queryCurrentIdentityByWid(walletPageController.wid.value);
    var identityList = await DatabaseUtil.create().queryIdentityList();
    if (identity == null) {
      Get.offAll(WalletCreatePage(), arguments: {"canBack": false});
    } else {
      String wid = identity.wid;
      PreferencesUtil.putString(Constant.CURRENT_WID, wid);
      walletPageController.changeIdentityModel(identity);
      walletPageController.changeIdentityModelList(identityList);
    }
    if (mounted) {
      setState(() {

      });
    }
  }

  initCoin() async {
    defaultCSUnit = Constant.CS_UNITS[Global.CS]!;
    List<CoinModel> coinModelList = await DatabaseUtil.create().queryCoinList(new CoinModel(wid: walletPageController.wid.value, contract: currentChain));
    walletPageController.changeCoinModelList(coinModelList);
    List<CoinModel> coinModelList2 = await DatabaseUtil.create().queryCoinList(new CoinModel(wid: walletPageController.wid.value));
    Global.CURRENT_CONIS = coinModelList2;
    initWalletPanelExtentList();
  }

  requestDate() async {
    if (isFirst) {
      isFirst = false;
    } else {
      AlertUtil.showLoadingDialog(context,show: true);
    }
    ApiData apiData = await ApiManager.postWalletContractIndex(data: {
      "wid": walletPageController.wid.value,
      "contract": currentChain,
    });
    if (!isFirst) {
      AlertUtil.showLoadingDialog(context,show: false);
    }
    if (apiData.code == 0) {
      WalletIndexModel walletIndexModel = WalletIndexModel.fromJson(apiData.data);
      if (walletIndexModel != null) {
        await DatabaseUtil.create().updateCoinList(walletIndexModel.items!);
        List<CoinModel> coinList = await DatabaseUtil.create().queryCoinList(new CoinModel(wid: walletPageController.wid.value, contract: currentChain));
        walletIndexModel.items = coinList;
        List<CoinModel> coinList2 = await DatabaseUtil.create().queryCoinList(new CoinModel(wid: walletPageController.wid.value));
        Global.CURRENT_CONIS = coinList2;
        walletPageController.changeWalletIndexModel(walletIndexModel);
        initWalletPanelExtentList();
        if (mounted) {
          setState(() {});
        }
      }
    } else {
      AlertUtil.showWarnBar(ID.CommonNetworkError.tr);
    }
  }

  void initWalletPanelExtentList() {
    walletPanelExtentList.clear();
    List<WalletPanelExtentModel> tempItems = <WalletPanelExtentModel>[];
    walletPageController.groups.value.forEach((homePanelItem) {
      List<Widget> bodyItems = [];
      Color color = homePanelItem.coinModel?.color != null && homePanelItem.coinModel?.color?.isNotEmptyString() ? '${homePanelItem.coinModel?.color}'.toColor() : ZColors.ZFFEECC5B;

      homePanelItem.coinModelList?.forEach((element) {
        bodyItems.add(createPanelCoin(element, diver: true, main: false, color: color));
      });
      tempItems.add(WalletPanelExtentModel(
        coinModel: homePanelItem.coinModel,
        body: Container(
          padding: EdgeInsets.all(0),
          margin: EdgeInsets.all(0),
          width: double.infinity,
          child: Column(
            children: bodyItems,
          ),
        ),
        isExpanded: false,
      ));
    });
    walletPanelExtentList = tempItems;
  }

  String fixChainName(name) {
    if (name == 'BNB') {
      return 'BSC';
    }
    if (name == 'MATIC') {
      return 'MATIC';
    }
    if (name == 'TRX') {
      return 'TRON';
    }
    return name;
  }

  void topButtonAction(String title) {
    switch (title) {
      case "transfer":
        if (walletPageController.coinModelList.length > 0) {
          showDialog(useSafeArea:false, context: context, builder: (builder) {
            return TokenDialogWidget(chainList: walletPageController.coinModelList, coinCallback: (data) async {
              if (data != null) {
                coinModel = data;
                Get.back();

                if (coinModel != null) {
                  Get.to(WalletTokenTransferPage(), arguments: {
                    "coinModel": coinModel,
                  });
                }
              } else {
                Get.back();
              }
            });
          });
        }
        break;
      case "receive":
        if (walletPageController.coinModelList.length > 0) {
          Get.to(WalletTokenReceivePage(), arguments: {"coinModel": walletPageController.coinModelList[0]});
        }
        break;
      case "swap":
        DiscoverDappModel discoverDappModel = new DiscoverDappModel(chain: "ABEY", coin: "", desc: "XSwap", icon: "https://files.abeychain.com/image/xswap.png", url: "https://app.xswap.com/#/swap", name: "XSWAP");
        Get.to(CommonWebviewPage(), arguments: {
          "url": discoverDappModel.url,
          "dapp": discoverDappModel
        });
        break;
      default:
        break;
    }
  }

  void onAssetsAction() async {
    List<CoinModel> coinModelList = await DatabaseUtil.create().queryCoinList(new CoinModel(wid: walletPageController.wid.value));
    if (coinModelList != null) {
      chainList.clear();
      coinModelList.forEach((element) {
        if (element.contract == element.symbol) {
          chainList.add(element);
        }
      });
      if (chainList.length > 0) {
        assetsChainAction();
      }
    }
  }

  void assetsChainAction() {
    List<Widget> widgets = createChainList();
    showDialog(
        useSafeArea: false,
        context: context,
        builder: (context) {
          return CommonDialogWidget(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  ID.WalletSelectChainTip.tr,
                  style: AppTheme.text14(fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: SizeUtil.width(30),
                ),
                GridView.builder(
                    padding: EdgeInsets.only(left: SizeUtil.width(10), right: SizeUtil.width(10)),
                    shrinkWrap: true,
                    controller: new ScrollController(keepScrollOffset: false),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widgets.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: SizeUtil.width(5),
                      crossAxisSpacing: SizeUtil.width(5),
                      childAspectRatio: 1 / 1.05,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return widgets[index];
                    }),
                SizedBox(
                  height: SizeUtil.width(30),
                ),
                Divider(
                  thickness: SizeUtil.height(.5),
                  color: ZColors.ZFFF2F2F2Theme(context),
                  height: SizeUtil.height(.5),
                ),
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    padding: SizeUtil.padding(top: 15, bottom: 5),
                    width: SizeUtil.screenWidth(),
                    child: Center(
                      child: Text(
                        ID.CommonCancel.tr,
                        style: AppTheme.text14(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  List<Widget> createChainList() {
    List<Widget> items = [];
    for (int i = 0; i < chainList.length; i++) {
      CoinModel item = chainList[i];
      String chainName = CommonUtil.getChainName(item.chainName!);
      items.add(InkWell(
        onTap: () async {
          Get.back();
          changNChain(item.contract!);
        },
        child:  Container(
          decoration: (walletPageController.contract.value.isNotEmptyString() && walletPageController.contract.value == item.contract) ? BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: ZColors.ZFFF5CA40, width: 1),
              color: ZColors.ZFFFAFAFATheme(context)
          ):null,
          child: Stack(
            children: [
              Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomWidget.buildNetworkImage(context, item.icon!, SizeUtil.width(36), SizeUtil.width(36), SizeUtil.width(4)),
                      SizedBox(
                        height: SizeUtil.width(6),
                      ),
                      Text(
                        chainName,
                        textAlign: TextAlign.center,
                        style: AppTheme.text11(),
                      ),
                    ],
                  )
              ),
            ],
          ),
        ),
      ));
    }
    items.add(InkWell(
      onTap: () async {
        Get.back();
        Get.to(WalletChainAddPage(),arguments: {
          'pass':"",
          "identityModel": walletPageController.identityModel.value,
        });
      },
      child: Container(
        decoration: null,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    Constant.Assets_Images + 'wallet_add.png',
                    width: SizeUtil.width(36),
                    height: SizeUtil.width(36),
                  ),
                  SizedBox(
                    height: SizeUtil.width(6),
                  ),
                  Text(
                    ID.WalletAddChain.tr,
                    style:AppTheme.text11(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
    return items;
  }

  void changNChain(String contract) async {
    currentChain = contract;
    walletPageController.changeContract(contract);
    requestDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZColors.KFFFFFFFFTheme(context),
      appBar: AppbarWidget.initAppBar(context, isBack: false, titleWidget: InkWell(
        onTap: () {
          onAssetsAction();
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 40,
              decoration: BoxDecoration(
                border: new Border.all(color: ZColors.KFFA0A0A8Theme(Get.context!), width: 1,),
                borderRadius: SizeUtil.radius(all: 20),
              ),
              child: Row(
                children: [
                  SizedBox(width: 20,),
                  Text(
                    CommonUtil.getChainName(currentChain),
                    style: AppTheme.text16(),
                  ),
                  SizedBox(width: 4,),
                  Image.asset(
                    Constant.Assets_Images + "common_arrow_down_14x8.png",
                    width: SizeUtil.width(14),
                    height: SizeUtil.width(8),
                  ),
                  SizedBox(width: 20,),
                ],
              ),
            ),
          ],
        ),
      ), widget: Builder(
        builder: (context) {
          return Container(
            width: 44,
            height: 44,
          );
        },
      )),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: ZColors.KFFFFFFFFTheme(context),
              child: appContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget appContent() {
    return EasyRefresh(
      header: MaterialHeader(),
      onRefresh: () async {
        await requestDate();
      },
      controller: refreshController,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Obx(() => createHeader()),
            createHeaderButton(),
            createAssets(),
            Container(
              child: Obx(
                    () =>  walletPageController.coinModelList.length > 0
                    ? Column(
                      children: createList(),
                    ) : Container(),
              ),
            ),
            Container(
              height: SizeUtil.width(20),
            )
          ],
        ),
      ),
    );
  }

  Widget createHeader() {
    return Container(
      width: SizeUtil.screenWidth() - SizeUtil.width(20),
      height: (SizeUtil.screenWidth() - SizeUtil.width(20))/294*97,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              child: Image.asset(
                Constant.Assets_Images + (Theme.of(context).brightness == Brightness.dark ? 'wallet_card_back_dark.png' : 'wallet_card_back.png'),
                width: SizeUtil.screenWidth(),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Positioned(
            left: SizeUtil.screenWidth() - SizeUtil.width(108),
            right: SizeUtil.width(15),
            top: SizeUtil.width(14),
            bottom: SizeUtil.width(18),
            child: Container(
              child: Image.asset(
                Constant.Assets_Images + 'wallet_card_right.png',
                width: SizeUtil.screenWidth(),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Container(
            padding: SizeUtil.padding(left: 15, right: 15, top: 7, bottom: 7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    CommonUtil.getChainName(currentChain),
                    style: AppTheme.text14(color: ZColors.ZFFFFFFFF),
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      Text(
                        '${ID.WalletAllAssets.tr}${walletPageController.identityModel.value.name != null ? '(${walletPageController.identityModel.value.name ?? ''})' : ''}',
                        style: AppTheme.text14(color: ZColors.ZFFFFFFFF),
                      ),
                      IconButton(
                          icon: Icon(
                            showAssets ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () => {
                            setState(() => {showAssets = !showAssets})
                          }),
                      Spacer(),
                      SizedBox(width: SizeUtil.width(15),),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    showAssets
                        ? '${walletPageController.walletIndexModel.value != null ? '${walletPageController.walletIndexModel.value.csUnit ?? defaultCSUnit} ${walletPageController.walletIndexModel.value.csAmount ?? '0.00'}' : ""}'
                        : "****",
                    style: AppTheme.text20(
                      color: ZColors.ZFFFFFFFF,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget createHeaderButton() {
    if (!(Platform.isIOS || Platform.isMacOS) || (Global.IS_WHEEL)) {
      return Container(
        margin: SizeUtil.margin(top: 14, left: 10, right: 10),
        height: SizeUtil.width(62),
        decoration: BoxDecoration(
          color: ZColors.KFFF9FAFBTheme(context),
          borderRadius: BorderRadius.all(Radius.circular(8.5)),
        ),
        child: Row(
          children: [
            Spacer(),
            getTopButton(context, "home_chain_transfer.png", ID.WalletTransfer.tr, () {
              topButtonAction("transfer");
            }),
            Spacer(),
            getTopButton(context, "home_chain_receive.png", ID.WalletReceive.tr, () {
              topButtonAction("receive");
            }),
            Spacer(),
            currentChain == "ABEY" ? getTopButton(context, "home_chain_trade.png", ID.WalletSwap.tr, () {
              topButtonAction("swap");
            }) : Container(),
            currentChain == "ABEY" ? Spacer() : Container(),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  getTopButton(BuildContext context, String icon, String title, VoidCallback callback) {
    return InkWell(
      onTap: () {
        callback();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: SizeUtil.width(42),
            height: SizeUtil.width(20),
            decoration: BoxDecoration(
              color: ZColors.KFFFCFDFDTheme(context),
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            child: Container(
              width: SizeUtil.width(14),
              height: SizeUtil.width(14),
              alignment: Alignment.center,
              child: Image.asset(
                Constant.Assets_Images + icon,
                fit: BoxFit.scaleDown,
                width: SizeUtil.width(14),
                height: SizeUtil.width(14),
              ),
            ),
          ),
          SizedBox(height: SizeUtil.width(5),),
          Container(
            width: SizeUtil.width(80),
            height: SizeUtil.width(20),
            alignment: Alignment.center,
            child: Text(
              title,
              style: AppTheme.text14(),
            ),
          ),
        ],
      ),
    );
  }

  Widget createAssets() {
    return Container(
      padding: SizeUtil.padding(left: 20, right: 7, top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Token",
            style: AppTheme.text16(),
          ),
          Spacer(),
          Container(
            child: Stack(
              children: [
                IconButton(
                    icon: Icon(Icons.add),
                    color: ZColors.ZFF2D4067Theme(context),
                    onPressed: () async {
                      var result = await Get.to(WalletChainTokenPage(), arguments: {"identityModel": walletPageController.identityModel.value});
                    }),
                Positioned(
                  top: SizeUtil.height(8),
                  right: SizeUtil.width(8),
                  child: CustomWidget.buildPoint(context, size: SizeUtil.height(5)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget createChainGroups() {
    return ExpansionPanelList(
      elevation: 0,
      expandedHeaderPadding: SizeUtil.padding(all: 0),
      expansionCallback: (int panelIndex, bool isExpanded) {
        setState(() {
          walletPanelExtentList[panelIndex].isExpanded = !isExpanded;
        });
      },
      children: walletPanelExtentList.map((WalletPanelExtentModel item) {
        return ExpansionPanel(
          backgroundColor:ZColors.ZFFFFFFFFTheme1(context),
          isExpanded: item.isExpanded!,
          body: item.body!,
          headerBuilder: (BuildContext context, bool isExpanded) {
            return Container(
              child: createPanelCoin(item.coinModel!),
            );
          },
        );
      }).toList(),
    );
  }

  List<Widget> createList() {
    List<Widget> items = [];
    for (int i = 0; i < walletPageController.coinModelList.length; i++) {
      CoinModel item = walletPageController.coinModelList[i];
      items.add(InkWell(
        onTap: () async {
          item.csUnit = item.csUnit!.isEmptyString() ? defaultCSUnit : item.csUnit;
          await Get.to(WalletTokenPage(), arguments: {"data": item});
        },
        child: Container(
          margin: SizeUtil.margin(left: 13, right: 13, top: 6, bottom: 6),
          decoration: BoxDecoration(
            color: ZColors.KFFF9FAFBTheme(context),
            borderRadius: SizeUtil.radius(all: 10),
          ),

          child: Column(
            children: [
              Container(
                padding: SizeUtil.padding(left: 10, right: 10, top: 10, bottom: 10),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: SizeUtil.padding(all: 4),
                          width: SizeUtil.width(44),
                          height: SizeUtil.width(44),
                          decoration: new BoxDecoration(
                              border: new Border.all(color: ZColors.ZFFEEEEEE, width: 0.5),
                              color: Colors.white,
                              borderRadius: new BorderRadius.circular(SizeUtil.width(44)),
                          ),
                          child: CustomWidget.buildNetworkImage(context, item.icon!, SizeUtil.width(36), SizeUtil.width(36), SizeUtil.width(18))
                        ),
                      ],
                    ),
                    SizedBox(width: 10,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.symbol!,
                          style: AppTheme.text16(fontWeight: FontWeight.w600),
                        ),
                        Padding(
                          padding: SizeUtil.padding(top: 5),
                          child: Text(
                            showAssets
                                ? '≈${item.csUnit!.isEmptyString() ? defaultCSUnit : item.csUnit}${item.price!.isEmptyString() ? '0.00' : item.price}'
                                : "****",
                            style: AppTheme.text12(),
                          ),
                        )
                      ],
                    ),
                    Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          showAssets
                              ? item.balance!.isNotEmptyString()
                                  ? item.balance!
                                  : ""
                              : "****",
                          style: AppTheme.text16(fontWeight: FontWeight.w600, color: ZColors.KFF232855Theme(context)),
                        ),
                        Padding(
                          padding: SizeUtil.padding(top: 5),
                          child: Text(
                            showAssets
                                ? '≈${item.csUnit!.isEmptyString() ? defaultCSUnit : item.csUnit}${item.totalPrice!.isEmptyString() ? '0.00' : item.totalPrice}'
                                : "****",
                            style: AppTheme.text12(),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: ZColors.ZFFF2F2F2Theme(context),
              )
            ],
          ),
        ),
      ));
    }
    return items;
  }

  Widget createPanelCoin(CoinModel coinModel, {bool diver: false, bool main: true, Color color: ZColors.ZFFEECC5B}) {
    if (coinModel == null) {
      return Container(
        height: 0,
      );
    }
    return InkWell(
      onTap: () async {
        coinModel.csUnit = coinModel.csUnit!.isEmptyString() ? defaultCSUnit : coinModel.csUnit;
        await Get.to(WalletTokenPage(), arguments: {"data": coinModel});
      },
      child: Stack(
        children: [
          Container(
            color: main ? ZColors.ZFFFFFFFFTheme1(context) : ZColors.ZFFFAFAFATheme(context),
            child: Column(
              children: [
                Container(
                  padding: SizeUtil.padding(left: 10, right: main ? 0 : SizeUtil.width(35), top: 10, bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        padding: SizeUtil.padding(all: 4),
                        width: SizeUtil.width(44),
                        height: SizeUtil.width(44),
                        decoration: new BoxDecoration(
                            border: new Border.all(color: ZColors.ZFFEEEEEE, width: 0.5),
                            color: Colors.white,
                            borderRadius: new BorderRadius.circular(SizeUtil.width(44))),
                        child: CustomWidget.buildNetworkImage(context, coinModel.icon!, SizeUtil.width(36), SizeUtil.width(36), SizeUtil.width(18))
                      ),
                      SizedBox(width: 10,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coinModel.symbol!,
                            style: AppTheme.text16(fontWeight: FontWeight.w600),
                          ),
                          Padding(
                            padding: SizeUtil.padding(top: 5),
                            child: Text(
                              showAssets
                                  ? '≈${coinModel.csUnit!.isEmptyString() ? defaultCSUnit : coinModel.csUnit}${coinModel.price!.isEmptyString() ? '0.00' : coinModel.price}'
                                  : "****",
                              style: AppTheme.text12(),
                            ),
                          )
                        ],
                      ),
                      Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            showAssets ? coinModel.balance! : "****",
                            style: AppTheme.text16(fontWeight: FontWeight.w600),
                          ),
                          Padding(
                            padding: SizeUtil.padding(top: 5),
                            child: Text(
                              showAssets
                                  ? '≈${coinModel.csUnit!.isEmptyString() ? defaultCSUnit : coinModel.csUnit}${coinModel.totalPrice!.isEmptyString() ? '0.00' : coinModel.totalPrice}'
                                  : "****",
                              style: AppTheme.text12(),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                diver
                    ? Divider(
                        height: 1,
                      )
                    : Container()
              ],
            ),
          ),
          main
              ? Container()
              : Positioned(
                  bottom: SizeUtil.width(5),
                  left: SizeUtil.width(40),
                  child: Container(
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.all(Radius.circular(2))),
                    padding: SizeUtil.padding(left: 3, right: 3, top: 1, bottom: 1),
                    child: Text(
                      '${fixChainName(coinModel.contract)}',
                      style: TextStyle(fontSize: SizeUtil.sp(6), color: Colors.white),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
