import 'dart:io';

import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/global.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/event/event.dart';
import 'package:abey_wallet/model/coin_model.dart';
import 'package:abey_wallet/model/wallet_tab_model.dart';
import 'package:abey_wallet/pages/wallet_token_receive.dart';
import 'package:abey_wallet/pages/wallet_token_transfer.dart';
import 'package:abey_wallet/pages/wallet_token_transfer_detail.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/service/api_data.dart';
import 'package:abey_wallet/service/api_manager.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/common_util.dart';
import 'package:abey_wallet/utils/database_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:abey_wallet/widget/dialog/common_dialog_widget.dart';
import 'package:abey_wallet/widget/status_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:abey_wallet/extension/string_extension.dart';
import 'package:get/get.dart';

class WalletTokenPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletTokenPageState();
  }
}

class WalletTokenPageState extends State<WalletTokenPage> with TickerProviderStateMixin {
  CoinModel? coinModel;

  List<WalletTabModel> tabs = [
    new WalletTabModel(name: ID.WalletTapAll.tr, key: "all"),
    new WalletTabModel(name: ID.WalletTapOut.tr, key: "out"),
    new WalletTabModel(name: ID.WalletTapIn.tr, key: "in"),
    new WalletTabModel(name: ID.WalletTapFailed.tr, key: "fail"),
  ];
  TabController? _tabController;
  ScrollController? _scrollViewController;

  String types = "all";

  bool isTron = false;

  EasyRefreshController allController = EasyRefreshController();
  int allPageIndex = 1;
  List<WalletTokenTransferModel> allTransferList = <WalletTokenTransferModel>[];

  EasyRefreshController outController = EasyRefreshController();
  int outPageIndex = 1;
  List<WalletTokenTransferModel> outTransferList = <WalletTokenTransferModel>[];

  EasyRefreshController inController = EasyRefreshController();
  int inPageIndex = 1;
  List<WalletTokenTransferModel> inTransferList = <WalletTokenTransferModel>[];

  EasyRefreshController failedController = EasyRefreshController();
  int failedPageIndex = 1;
  List<WalletTokenTransferModel> failedTransferList = <WalletTokenTransferModel>[];

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      if (Get.arguments['data'] != null) {
        coinModel = Get.arguments['data'];
      }
    }

    _scrollViewController = ScrollController(initialScrollOffset: 0.0);
    _tabController = TabController(initialIndex: 0, length: tabs.length, vsync: this);

    requestData("all");

    eventBus.on<UpdateTrade>().listen((event) async {
      tradeAction();
    });
  }

  void requestBalance() async {
    ApiData apiData = await ApiManager.postWalletBalance(data: {
      "wid": coinModel!.wid,
      "tokenID": coinModel!.tokenID,
    });
    if (apiData.code == 0) {
      WalletIndexModel walletIndexModel = WalletIndexModel.fromJson(apiData.data);
      if (walletIndexModel != null) {
        await DatabaseUtil.create().updateCoinList(walletIndexModel.items!);
        if (walletIndexModel.items != null && walletIndexModel.items!.length > 0) {
          CoinModel item = walletIndexModel.items!.first;
          if (coinModel!.tokenID == item.tokenID) {
            coinModel!.balance = item.balance;
            coinModel!.totalPrice = item.totalPrice;

            eventBus.fire(UpdateBalance());
          }
          if (mounted) {
            setState(() {});
          }
        }
      }
    } else {
      AlertUtil.showWarnBar(ID.CommonNetworkError.tr);
    }
  }

  void tradeAction() {
    requestData(types);
  }

  void requestData(String type) async {
    types = type;
    switch (type) {
      case "all":
        ApiData apiData = await ApiManager.postWalletCoinTransactions(data: {
          "address": coinModel!.address,
          "contract": coinModel!.contract,
          "contractAddress": coinModel!.contractAddress,
          "condition": "all",
          "page": allPageIndex,
          "size": 100
        });
        if (apiData.code == 0) {
          WalletTokenTransferListModel walletTokenTransferListModel =
              WalletTokenTransferListModel.fromJson(apiData.data);
          if (walletTokenTransferListModel != null) {
            if (allPageIndex == 1) {
              allTransferList.clear();
            }
            allTransferList.addAll(walletTokenTransferListModel.items!);
            if (mounted) {
              setState(() {});
            }
          }
        }
        break;
      case "out":
        ApiData apiData = await ApiManager.postWalletCoinTransactions(data: {
          "address": coinModel!.address,
          "contract": coinModel!.contract,
          "contractAddress": coinModel!.contractAddress,
          "condition": "out",
          "page": outPageIndex,
          "size": 100
        });
        if (apiData.code == 0) {
          WalletTokenTransferListModel walletTokenTransferListModel =
              WalletTokenTransferListModel.fromJson(apiData.data);
          if (walletTokenTransferListModel != null) {
            if (outPageIndex == 1) {
              outTransferList.clear();
            }
            outTransferList.addAll(walletTokenTransferListModel.items!);
            if (mounted) {
              setState(() {});
            }
          }
        }
        break;
      case "in":
        ApiData apiData = await ApiManager.postWalletCoinTransactions(data: {
          "address": coinModel!.address,
          "contract": coinModel!.contract,
          "contractAddress": coinModel!.contractAddress,
          "condition": "in",
          "page": inPageIndex,
          "size": 100
        });
        if (apiData.code == 0) {
          WalletTokenTransferListModel walletTokenTransferListModel =
              WalletTokenTransferListModel.fromJson(apiData.data);
          if (walletTokenTransferListModel != null) {
            if (inPageIndex == 1) {
              inTransferList.clear();
            }
            inTransferList.addAll(walletTokenTransferListModel.items!);
            if (mounted) {
              setState(() {});
            }
          }
        }
        break;
      case "failed":
        ApiData apiData = await ApiManager.postWalletCoinTransactions(data: {
          "address": coinModel!.address,
          "contract": coinModel!.contract,
          "contractAddress": coinModel!.contractAddress,
          "condition": "failed",
          "page": failedPageIndex,
          "size": 100
        });
        if (apiData.code == 0) {
          WalletTokenTransferListModel walletTokenTransferListModel =
              WalletTokenTransferListModel.fromJson(apiData.data);
          if (walletTokenTransferListModel != null) {
            if (failedPageIndex == 1) {
              failedTransferList.clear();
            }
            failedTransferList.addAll(walletTokenTransferListModel.items!);
            if (mounted) {
              setState(() {});
            }
          }
        }
        break;
    }
  }

  void hideAction() async {
    AlertUtil.showLoadingDialog(context, show: true);
    ApiData apiData = await ApiManager.postWalletHideCoin(data: {
      "wid": coinModel!.wid,
      "tokenID": coinModel!.tokenID,
    });
    if (apiData.code == 0) {
      await DatabaseUtil.create().deleteCoin(coinModel!);
    }
    AlertUtil.showLoadingDialog(context, show: false);

    eventBus.fire(UpdateChain());
    Get.back();
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
                  onTap: () {
                    Get.back();
                    hideAction();
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
    return Stack(
      children: [
        Positioned(
          top: -1,
          child: Container(
            width: SizeUtil.screenWidth(),
            height: SizeUtil.barHeight() + 56,
            color: ZColors.ZFFEECC5B,
          ),
        ),
        Positioned(
          top: SizeUtil.barHeight() + 55,
          child: Container(
            width: SizeUtil.screenW,
            height: isTron ? SizeUtil.height(215) : SizeUtil.height(140),
            color: ZColors.ZFFEECC5B,
          ),
        ),
        Scaffold(
          backgroundColor: ZColors.KFFFFFFFFTheme(context),
          appBar: AppbarWidget.initAppBar(
            context,
            isBack: true,
            title: coinModel != null && coinModel!.symbol!.isNotEmptyString() ? coinModel!.symbol! : "",
            widget: coinModel != null && coinModel!.symbol != coinModel!.contract!
                ? Builder(
                    builder: (context) {
                      return SizedBox(
                        child: IconButton(
                          icon: Icon(
                            Icons.more_horiz_outlined,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            showActionDialog();
                          },
                        ),
                      );
                    },
                  )
                : Container(),
          ),
          body: (Platform.isIOS || Platform.isMacOS) ? (Global.IS_WHEEL) ? Stack(
            children: [
              Container(
                height: double.infinity,
                padding: EdgeInsets.only(bottom: 80),
                child: _buildContent(),
              ),
              Positioned(bottom: 0, left: 0, child: _createButtons()),
            ],
          ) : Stack(
            children: [
              Container(
                height: double.infinity,
                child: _buildContent(),
              ),
            ],
          ) :Stack(
            children: [
              Container(
                height: double.infinity,
                padding: EdgeInsets.only(bottom: 80),
                child: _buildContent(),
              ),
              Positioned(bottom: 0, left: 0, child: _createButtons()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return NestedScrollView(
      controller: _scrollViewController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            backgroundColor: ZColors.KFFFFFFFFTheme(context),
            pinned: true,
            floating: true,
            expandedHeight: isTron ? SizeUtil.height(215) : SizeUtil.height(180),
            automaticallyImplyLeading: false,
            flexibleSpace: isTron
                ? FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Stack(
                      children: [
                        Container(
                          height: SizeUtil.height(140),
                          width: double.infinity,
                          color: Colors.transparent,
                          child: Column(
                            children: <Widget>[
                              _buildTop(),
                              Container(
                                height: SizeUtil.height(40),
                              )
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.transparent,
                          margin: EdgeInsets.only(left: 7, right: 7, top: SizeUtil.height(105)),
                          height: SizeUtil.height(110),
                          child: Column(
                            children: <Widget>[
                              _buildTron(),
                              Container(
                                height: SizeUtil.height(2),
                                color: Colors.transparent,
                              ),
                              _buildTabBarBg()
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                : FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Container(
                      height: double.infinity,
                      color: Colors.transparent,
                      child: Column(
                        children: <Widget>[_buildTop(), _buildTabBarBg()],
                      ),
                    ),
                  ),
            bottom: PreferredSize(
              preferredSize: Size(SizeUtil.screenWidth(), SizeUtil.height(40)),
              child: Container(
                margin: SizeUtil.margin(left: 10, right: 10),
                child: TabBar(
                  controller: _tabController,
                  labelColor: ZColors.ZFFEECC5B,
                  indicatorColor: ZColors.ZFFEECC5B,
                  indicatorWeight: SizeUtil.height(2),
                  indicatorPadding: SizeUtil.padding(left: 20, right: 20),
                  unselectedLabelColor: ZColors.ZFF939CB0Theme(context),
                  tabs: tabs.map((e) => Tab(
                    text: e.name,
                  )).toList(),
                  onTap: (index) {
                    switch (index) {
                      case 0:
                        {
                          requestData("all");
                        }
                        break;
                      case 1:
                        {
                          requestData("out");
                        }
                        break;
                      case 2:
                        {
                          requestData("in");
                        }
                        break;
                      case 3:
                        {
                          requestData("failed");
                        }
                        break;
                    }
                  },
                ),
              ),
            ),
          )
        ];
      },
      body: Container(
        color: ZColors.ZFFFFFFFFTheme1(context),
        child: TabBarView(controller: _tabController, physics: NeverScrollableScrollPhysics(), children: [
          _buildTrans("all"),
          _buildTrans("out"),
          _buildTrans("in"),
          _buildTrans("failed"),
        ]),
      ),
    );
  }

  Widget _buildTron() {
    return Container(
      margin: SizeUtil.margin(left: 7, right: 7),
      height: SizeUtil.height(68),
      decoration: new BoxDecoration(
        boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 2)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(SizeUtil.width(13))),
        child: Container(
          color: Theme.of(context).appBarTheme.backgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: SizeUtil.width(11)),
                    child: Image(
                      image: AssetImage(
                        Constant.Assets_Images + "common_band.png",
                      ),
                      width: SizeUtil.width(20),
                      height: SizeUtil.width(20),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: SizeUtil.width(6)),
                    child: Text(
                      ID.WalletTrxBand.tr,
                      style: AppTheme.text14(),
                    ),
                  ),
                  Spacer(),
                  Container(
                    child: Text(
                      (int.parse(coinModel!.netLimit != null && coinModel!.netLimit!.isNotEmpty
                                  ? coinModel!.netLimit!
                                  : "0") -
                              int.parse(
                                  coinModel!.netUsed != null && coinModel!.netUsed!.isNotEmpty ? coinModel!.netUsed! : "0"))
                          .toString(),
                      style: AppTheme.text14(),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: SizeUtil.width(15)),
                    child: Text(
                      "/${coinModel!.netLimit != null && coinModel!.netLimit!.isNotEmpty ? coinModel!.netLimit : "0"}",
                      style: AppTheme.text14(color: ZColors.ZFF939CB0Theme(context)),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: SizeUtil.height(4),
              ),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: SizeUtil.width(11)),
                    child: Image(
                      image: AssetImage(
                        Constant.Assets_Images + "common_energy.png",
                      ),
                      width: SizeUtil.width(20),
                      height: SizeUtil.width(20),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: SizeUtil.width(6)),
                    child: Text(
                      ID.WalletTrxEnergy.tr,
                      style: AppTheme.text14(),
                    ),
                  ),
                  Spacer(),
                  Container(
                    child: Text(
                      (int.parse(coinModel!.energyLimit != null && coinModel!.energyLimit!.isNotEmpty
                                  ? coinModel!.energyLimit!
                                  : "0") -
                              int.parse(coinModel!.energyUsed != null && coinModel!.energyUsed!.isNotEmpty
                                  ? coinModel!.energyUsed!
                                  : "0"))
                          .toString(),
                      style: AppTheme.text14(),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: SizeUtil.width(15)),
                    child: Text(
                      ("/${coinModel!.energyLimit != null && coinModel!.energyLimit!.isNotEmpty ? coinModel!.energyLimit : "0"}"),
                      style: AppTheme.text14(color: ZColors.ZFF939CB0Theme(context)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTop() {
    return Expanded(
      flex: 1,
      child: Container(
        margin: SizeUtil.margin(left: 12, right: 12, top: 12, bottom: 12),
        width: SizeUtil.screenWidth() - SizeUtil.width(24),
        decoration: new BoxDecoration(
          borderRadius: BorderRadius.circular(SizeUtil.width(10)),
          color: ZColors.ZFF1F1343,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: Text(
                coinModel != null && coinModel!.balance!.isNotEmptyString() ? coinModel!.balance! : "--",
                style: AppTheme.text30(),
              ),
            ),
            SizedBox(height: SizeUtil.width(8),),
            Container(
              child: Text(
                coinModel != null && coinModel!.csUnit!.isNotEmptyString() && coinModel!.totalPrice!.isNotEmptyString()
                    ? '${coinModel!.csUnit}${coinModel!.totalPrice}'
                    : "--",
                style: AppTheme.text14(color: ZColors.ZFFFFFFFF),
              ),
            ),
            SizedBox(height: SizeUtil.width(10),),
            InkWell(
              onTap: () {
                if (coinModel != null) {
                  Clipboard.setData(ClipboardData(text: coinModel!.address));
                  AlertUtil.showTipsBar(ID.CommonClipboard.tr);
                }
              },
              child: Container(
                margin: SizeUtil.margin(left: 20, right: 20,),
                padding: SizeUtil.padding(left: 10, right: 10, top: 8, bottom: 8),
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.circular(SizeUtil.width(20)),
                  color: ZColors.ZFFFFFFFFTheme1(context),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      CommonUtil.formatAddress("${coinModel != null && coinModel!.address!.isNotEmptyString() ? coinModel!.address : '0x'}"),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.text12(),
                    ),
                    SizedBox(
                      width: SizeUtil.width(10),
                    ),
                    Image.asset(
                      Constant.Assets_Images + "common_copy.png",
                      width: SizeUtil.width(11),
                      height: SizeUtil.width(11),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBarBg() {
    return Container(
      margin: SizeUtil.margin(left: 7, right: 7),
      height: SizeUtil.height(40),
      color: ZColors.KFFFFFFFFTheme(context),
    );
  }

  _createButtons() {
    return Container(
      width: SizeUtil.screenWidth(),
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: (SizeUtil.screenWidth() - SizeUtil.width(70))/2,
            height: 40,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(Constant.Assets_Images + "common_button_empty.png"),
                    fit: BoxFit.fill
                )
            ),
            child: MaterialButton(
              onPressed: () {
                if (coinModel != null) {
                  Get.to(WalletTokenTransferPage(), arguments: {
                    "coinModel": coinModel,
                  });
                }
              },
              minWidth: SizeUtil.width(300),
              height: SizeUtil.width(45),
              child: Text(
                ID.WalletTransfer.tr,
                style: AppTheme.text16(color: ZColors.ZFFB0B0B0, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Container(
            width: (SizeUtil.screenWidth() - SizeUtil.width(70))/2,
            height: 40,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(Constant.Assets_Images + "common_button_back.png"),
                    fit: BoxFit.fill
                )
            ),
            child: MaterialButton(
              onPressed: () {
                if (coinModel != null) {
                  Get.to(WalletTokenReceivePage(), arguments: {"coinModel": coinModel});
                }
              },
              minWidth: SizeUtil.width(300),
              height: SizeUtil.width(45),
              child: Text(
                ID.WalletReceive.tr,
                style: AppTheme.text16(color: ZColors.ZFFFFFFFF, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrans(type) {
    switch (type) {
      case "all":
        return _buildRefresh(_buildTransList(allTransferList), allController, () async {
          allPageIndex = 1;
          requestData("all");
          requestBalance();
        });
      case "out":
        return _buildRefresh(_buildTransList(outTransferList), outController, () async {
          outPageIndex = 1;
          requestData("out");
          requestBalance();
        });
      case "in":
        return _buildRefresh(_buildTransList(inTransferList), inController, () async {
          inPageIndex = 1;
          requestData("in");
          requestBalance();
        });
      case "failed":
        return _buildRefresh(_buildTransList(failedTransferList), failedController, () async {
          failedPageIndex = 1;
          requestData("failed");
          requestBalance();
        });
      default:
        return Container(
          height: 0,
        );
    }
  }

  Widget _buildRefresh(child, EasyRefreshController controller, refreshCallback, {noMore: true, loadCallback}) {
    var refreshView = EasyRefresh(
      header: MaterialHeader(),
      onRefresh: () async {
        await refreshCallback();
        controller.finishRefresh(success: true);
      },
      onLoad: loadCallback != null
          ? () async {
              await loadCallback();
              controller.finishLoad(success: true, noMore: noMore);
            }
          : null,
      controller: controller,
      child: child,
    );
    return refreshView;
  }

  Widget _buildTransList(List<WalletTokenTransferModel> data) {
    if (data == null || data.isEmpty) {
      return StatusWidget(LoadStatus.empty);
    }
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (BuildContext context, int index) {
        WalletTokenTransferModel item = data[index];
        String symbel = "-";
        String iconUrl = Constant.Assets_Images + "wallet_transfer_out.png";
        String address = '';
        if (item.type == 'in') {
          iconUrl = Constant.Assets_Images + "wallet_transfer_in.png";
          symbel = "+";
          address = item.from!;
        } else if (item.type == 'out') {
          iconUrl = Constant.Assets_Images + "wallet_transfer_out.png";
          symbel = "-";
          address = item.to!;
        }
        if (item.status == 'failed') {
          iconUrl = Constant.Assets_Images + "wallet_transfer_pending.png";
        }

        return Container(
          margin: SizeUtil.margin(left: 15, right: 15, top: 5, bottom: 5),
          decoration: BoxDecoration(
            borderRadius: SizeUtil.radius(all: 8),
            color: ZColors.KFFF9FAFBTheme(context),
          ),
          child: InkWell(
            onTap: () {
              Get.to(WalletTokenTransferDetailPage(), arguments: {
                "walletTokenTransferModel": item,
                "coinModel": coinModel,
              });
            },
            child: Container(
              padding: SizeUtil.padding(left: 5, right: 5, top: 10, bottom: 10),
              child: Row(
                children: [
                  Container(
                    padding: SizeUtil.padding(left: 10, right: 10),
                    child: Image.asset(
                      iconUrl,
                      width: SizeUtil.width(25),
                      height: SizeUtil.height(25),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: SizeUtil.padding(right: 13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            CommonUtil.formatAddress(address),
                            style: AppTheme.text14( fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Container(
                            padding: SizeUtil.padding(top: 5),
                            child: Text(
                              "${item.time}",
                              style: AppTheme.text12(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: SizeUtil.padding(right: 10),
                    child: Text(
                      "$symbel ${item.value}",
                      style: AppTheme.text12(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.dispose();
    _scrollViewController!.dispose();
  }
}
