import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/common/global.dart';
import 'package:abey_wallet/model/coin_model.dart';
import 'package:abey_wallet/pages/common_webview.dart';
import 'package:abey_wallet/pages/discover_search.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/service/api_data.dart';
import 'package:abey_wallet/service/api_manager.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/preferences_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:abey_wallet/widget/dialog/discover_Identity_dialog_widget.dart';
import 'package:abey_wallet/widget/status_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';

class DiscoverPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DiscoverPageState();
  }
}

class DiscoverPageController extends GetxController {
  var banners = [].obs;
  var groupItems = {}.obs;

  changeBanners(data) {
    if (data != null) {
      banners.value = data;
    }
  }

  initGroupItems(key) {
    groupItems[key] = [];
  }

  changeGroupItems(key, data, {bool renew = false}) {
    if (groupItems[key] == null) {
      groupItems[key] = [];
    } else {
      // groupItems.clear();
    }
    if (data != null) {
      if (renew) {
        groupItems[key] = data;
      } else {
        groupItems[key].addAll(data);
      }
    } else {
      if (renew) {
        groupItems[key].clear();
      }
    }
  }
}

class DiscoverPageState extends State<DiscoverPage> with TickerProviderStateMixin {
  TabController? _tabController;
  List<CoinModel> tabViews = [];
  List<Widget> tabPages = [];
  int _length1 = 50;
  DateTime lastRefreshTime = DateTime.now();
  double maxDragOffset = SizeUtil.width(100);

  DiscoverPageController discoverPageController = DiscoverPageController();
  EasyRefreshController _refreshController = EasyRefreshController();

  @override
  void initState() {
    super.initState();
    tabViews = Global.SUPORT_DAPPS;
    _tabController = TabController(length: tabViews.length, vsync: this);
    _requestDapps();
  }

  Future<bool> _requestDapps() async {
    ApiData apiData = await ApiManager.postDappDapps(data:{
      "wid": "",
    });
    if (apiData.code == 0) {
      DiscoverDappListModel discoverDappListModel = DiscoverDappListModel.fromJson(apiData.data);
      if (discoverDappListModel != null) {
        discoverDappListModel.groups!.forEach((key, value) {
          discoverPageController.changeGroupItems(key, value, renew: true);
        });
        discoverPageController.changeBanners(discoverDappListModel.banners);
      }
    } else {
      AlertUtil.showWarnBar(ID.CommonNetworkError.tr);
    }
    return true;
  }

  void dappAction(DiscoverDappModel discoverDappModel) async {
    bool hasChain = false;
    Global.CURRENT_CONIS.forEach((element) {
      if (element.contract == discoverDappModel.chain) {
        hasChain = true;
        return;
      }
    });
    if (!hasChain) {
      AlertUtil.showWarnBar((ID.WalletChainAdd.tr).replaceAll('{%s}', discoverDappModel.chain!));
      return;
    }
    bool has = PreferencesUtil.getBool('DAPP:${discoverDappModel.name}');
    if (!has) {
      await showDialog(
          useSafeArea:false,
          context: context,
          builder: (builder) {
            return DiscoverIdentityDialogWidget(
              icon: discoverDappModel.icon!,
              name: discoverDappModel.name!,
              chain: discoverDappModel.chain!,
              callback: (result) async {
                PreferencesUtil.putBool('DAPP:${discoverDappModel.name}', result);
                Get.back();
                if (result) {
                  Get.to(CommonWebviewPage(),
                      arguments: {
                        "url": discoverDappModel.url,
                        "dapp": discoverDappModel
                      });
                }
              },
            );
          });
    } else {
      Get.to(CommonWebviewPage(), arguments: {
        "url": discoverDappModel.url,
        "dapp": discoverDappModel
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    tabViews = Global.SUPORT_DAPPS;
    return Scaffold(
      backgroundColor: ZColors.KFFFFFFFFTheme(context),
      appBar: AppbarWidget.initAppBar(context, isBack: false, title: ID.Discover.tr,
      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            height: 45,
            child: InkWell(
              onTap: (){
                Get.to(DiscoverSearchPage());
              },
              child: Container(
                margin: SizeUtil.padding(left: 15,right: 15),
                width: double.infinity,
                height: SizeUtil.width(35),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color:ZColors.ZFFFAFAFA),
                  borderRadius:
                  BorderRadius.all(Radius.circular(SizeUtil.width(50))),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0, 1.0),
                        blurRadius: 1,
                        spreadRadius: 0
                    )
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 15,),
                    Icon(Icons.search,color: ZColors.ZFFD6D6D6,size: 16,),
                    Expanded(
                      child: Padding(padding: SizeUtil.padding(left: 2),child: Text(ID.DiscoverSearchTip.tr,style: AppTheme.text10(),),),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 45,
            color: Get.isDarkMode ? Colors.black26 : Colors.white,
            alignment: Alignment.topLeft,
            child: TabBar(
              controller: _tabController,
              labelColor: ZColors.ZFFEECC5B,
              indicatorColor: ZColors.ZFFEECC5B,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: SizeUtil.width(2),
              isScrollable: true,
              unselectedLabelColor: ZColors.ZFF939CB0Theme(context),
              tabs: tabViews.map((e) {
                return Tab(text: e.chainName,);
              }).toList(),
            ),
          ),
          Expanded(
              child: TabBarView(
                controller: _tabController,
                children: tabViews.map((e) {
                  return createRefresh(e);
                }).toList(),
              ),
          ),
        ],
      ),
    );
  }

  Widget createRefresh(CoinModel coinModel) {
    var refreshView = EasyRefresh(
        header: MaterialHeader(),
        onRefresh: () async {
          await _requestDapps();
          _refreshController.finishRefresh(success: true);
        },
        controller: _refreshController,
        child: Obx(()=> discoverPageController.groupItems!=null && discoverPageController.groupItems[coinModel.symbol]!=null?ListView.builder(
          key: PageStorageKey<String>('Tab${coinModel.symbol}'),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return getContentItem(context, coinModel, index);
          },
          itemCount: discoverPageController.groupItems.value[coinModel.symbol] != null
              ? discoverPageController.groupItems.value[coinModel.symbol].length
              : 0,
          padding: EdgeInsets.all(0.0),
        ):StatusWidget(LoadStatus.empty))
    );
    return refreshView;
  }

  getContentItem(BuildContext context, CoinModel coinModel, int index) {
    DiscoverDappModel item = discoverPageController.groupItems.value[coinModel.symbol][index];
    return Container(
      margin: SizeUtil.margin(left: 15, right: 15, top: 5, bottom: 5),
      decoration: BoxDecoration(
        borderRadius: SizeUtil.radius(all: 10),
        color: ZColors.KFFF9FAFBTheme(context),
      ),
      child: InkWell(
        onTap: () {
          dappAction(item);
        },
        child: Container(
          padding: SizeUtil.padding(all: SizeUtil.width(8)),
          child: Row(
            children: [
              Container(
                margin: SizeUtil.margin(right: 12),
                padding: SizeUtil.padding(all: SizeUtil.width(4)),
                decoration: BoxDecoration(
                  color: ZColors.ZFFFAFAFA,
                  border: Border.all(color: ZColors.ZFFF5F5F5),
                  borderRadius: BorderRadius.all(Radius.circular(6.0)),
                ),
                child: CustomWidget.buildNetworkImage(context, item.icon!, SizeUtil.width(35), SizeUtil.width(35), SizeUtil.width(4)),
              ),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${item.name}",
                        style: AppTheme.text14(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Container(
                        padding: SizeUtil.padding(top: 5),
                        child: Text(
                          "${item.desc}",
                          style: AppTheme.text12(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios,size: SizeUtil.width(12),color: ZColors.ZFF2D4067Theme(context),),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }
}