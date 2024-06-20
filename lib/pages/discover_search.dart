import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/common/global.dart';
import 'package:abey_wallet/model/coin_model.dart';
import 'package:abey_wallet/model/identity_model.dart';
import 'package:abey_wallet/pages/common_webview.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/service/api_data.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/database_util.dart';
import 'package:abey_wallet/utils/preferences_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:abey_wallet/widget/dialog/common_dialog_widget.dart';
import 'package:abey_wallet/widget/dialog/discover_Identity_dialog_widget.dart';
import 'package:abey_wallet/widget/dialog/loading_dialog_widget.dart';
import 'package:abey_wallet/widget/status_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:abey_wallet/extension/string_extension.dart';
import 'package:sticky_headers/sticky_headers.dart';

class DiscoverSearchPage extends StatefulWidget {
  const DiscoverSearchPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DiscoverSearchPageState();
  }
}

class DiscoverSearchPageController extends GetxController {
  var showEmpty = false.obs;
  var showLoading = false.obs;
  var showClear = false.obs;
  var showSearchLoading = false.obs;
  var searchItems = [].obs;
  var items = <DiscoverDappModel>[].obs;

  var showHistLabel = false.obs;
  var showHistList = <String>[].obs;

  setHistList(data) {
    if (data == null) {
      data = [];
    }
    List<String> temp = [];
    data.forEach((el) {
      temp.add(el);
    });
    showHistList.clear();
    showHistList.addAll(temp);
    showHistLabel.value = data.length > 0;
  }

  setSearchItems(data) {
    if (data == null) {
      data = [];
    }
    searchItems.clear();
    searchItems.addAll(data);
    showSearchLoading.value = false;
    changeShowEmpty(show: data.length == 0);
  }

  appendItems(data, {bool renew = false}) {
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

  setSearchLoading({show: true}) {
    showSearchLoading.value = show;
  }

  changeShowClear(bool show) {
    if (showClear.value != show) {
      showClear.value = show;
    }
  }

  changeShowEmpty({bool show = true}) {
    showEmpty.value = show;
  }
}

class DiscoverSearchPageState extends State<DiscoverSearchPage> {
  IdentityModel? identityModel;

  TextEditingController searchEC = TextEditingController();
  EasyRefreshController refreshRC = EasyRefreshController();
  DiscoverSearchPageController discoverSearchPC = Get.put(DiscoverSearchPageController());
  ScrollController scrollController = ScrollController();
  bool needRefresh = false;

  @override
  void initState() {
    super.initState();

    initIdentity();
    querySearchHistory();
  }

  void initIdentity() async {
    String wid = PreferencesUtil.getString(Constant.CURRENT_WID);
    identityModel = await DatabaseUtil.create().queryCurrentIdentityByWid(wid);
  }

  void querySearchHistory() {
    List<String> history = PreferencesUtil.getStringList(Constant.ZDiscoverSearchHistory);
    discoverSearchPC.setHistList(history);
  }

  searchAction() async {
    if (searchEC.text.isEmptyString()) {
      AlertUtil.showWarnBar(ID.DiscoverSearchTip1.tr);
      return;
    }
    appendSearchHistory();
    if (searchEC.text.startsWith("http://") || searchEC.text.startsWith("https://")) {
      showChoiceChainDialog();
      return true;
    } else {
      AlertUtil.showWarnBar(ID.DiscoverSearchTip.tr);
      return;
    }
  }

  void appendSearchHistory() {
    List<String> history = PreferencesUtil.getStringList(Constant.ZDiscoverSearchHistory);
    bool changed = false;
    if (history == null) {
      history = [searchEC.text];
      changed = true;
    } else if (!history.contains(searchEC.text)) {
      history.add(searchEC.text);
      changed = true;
    }
    if (changed) {
      if (history.length > 10) {
        history = []..addAll(history.getRange(history.length - 11, history.length - 1));
      }
      PreferencesUtil.putStringList(Constant.ZDiscoverSearchHistory, history);
      discoverSearchPC.setHistList(history);
    }
  }

  void showChoiceChainDialog() async {
    List<CoinModel> chains = Global.SUPORT_CHAINS;
    List<Widget> items = [];
    chains.forEach((item) {
      items.add(Material(
        child: InkWell(
          onTap: () async {
            Get.back();
            await showDialog(
                useSafeArea: false,
                context: context,
                builder: (builder) {
                  return DiscoverIdentityDialogWidget(
                    icon: item.icon!,
                    name: searchEC.text,
                    chain: item.contract!,
                    callback: (result) async {
                      Get.back();
                      if (result) {
                        Get.to(CommonWebviewPage(), arguments: {
                          "url": searchEC.text,
                          "dapp": DiscoverDappModel.fromJson({
                            "icon": item.icon,
                            "coin": item.contract,
                            "chain": item.contract,
                            "name": searchEC.text,
                            "url": searchEC.text,
                          })
                        });
                      }
                    },
                  );
                });
          },
          child: Container(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: SizeUtil.padding(all: 5),
                      margin: SizeUtil.margin(left: 14, right: 14, top: 10, bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: ZColors.ZFFFAFAFA),
                        borderRadius: BorderRadius.all(Radius.circular(SizeUtil.width(50))),
                        boxShadow: [BoxShadow(color: Colors.black12, offset: Offset(0, 1.0), blurRadius: 1, spreadRadius: 0)],
                      ),
                      child: CustomWidget.buildNetworkImage(context, item.icon!, SizeUtil.width(38), SizeUtil.width(38), SizeUtil.width(4))
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.symbol!,
                            style: AppTheme.text16(),
                          ),
                          Text(item.name!),
                        ],
                      ),
                    )
                  ],
                ),
                Divider(
                  height: 1,
                )
              ],
            ),
          ),
        ),
      ));
    });

    return await showDialog(
        useSafeArea: false,
        context: context,
        builder: (context) {
          return CommonDialogWidget(
            padding: SizeUtil.padding(top: 10, bottom: 40),
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    child: Text(
                      ID.WalletSelectChainTip.tr,
                      style: Theme.of(context).primaryTextTheme.headline6,
                    ),
                  )
                ]..addAll(items),
              ),
            ),
          );
        });
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
      child: WillPopScope(
        onWillPop: () {
          return Future.value(true);
        },
        child: Scaffold(
            backgroundColor: ZColors.KFFFFFFFFTheme(context),
            appBar: AppBar(
              leading: Container(
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_outlined,
                    size: SizeUtil.width(20),
                    color: ZColors.ZFF2D4067Theme(context),
                  ),
                  onPressed: () {
                    if (needRefresh) {
                      Get.back(result: {"action": Constant.ZDiscoverSearchRefresh});
                    } else {
                      Get.back();
                    }
                  },
                ),
              ),
              backgroundColor: ZColors.ZFFEECC5B,
              centerTitle: true,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
              titleSpacing: 0,
              title: Container(
                width: SizeUtil.screenWidth(),
                child: TextField(
                  autofocus: false,
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    contentPadding: SizeUtil.padding(all: 0),
                    border: InputBorder.none,
                    filled: false,
                    hintText: ID.DiscoverSearchTip.tr,
                    hintStyle: AppTheme.text12(),
                  ),
                  style: AppTheme.text12(color: ZColors.ZFFFFFFFF, fontWeight: FontWeight.w600),
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.left,
                  controller: searchEC,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (text) {
                    FocusScope.of(context).requestFocus(FocusNode());
                    searchAction();
                  },
                  onChanged: (text) {
                    discoverSearchPC.changeShowClear(text.isNotEmptyString());
                  },
                ),
              ),
              actions: [
                Builder(builder: (context) {
                  return Container(
                    padding: SizeUtil.padding(top: 10, bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Obx(() => !discoverSearchPC.showClear.value
                            ? Container()
                            : Container(
                                width: SizeUtil.width(25),
                                height: SizeUtil.width(25),
                                alignment: Alignment.center,
                                child: IconButton(
                                    icon: Icon(Icons.clear, size: SizeUtil.width(20),color: ZColors.ZFF2D4067Theme(context),),
                                    padding: SizeUtil.padding(),
                                    onPressed: () {
                                      searchEC.text = '';
                                      discoverSearchPC.changeShowClear(false);
                                    }),
                              ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              await searchAction();
                            },
                            child: Container(
                              padding: SizeUtil.padding(left: 10, right: 10),
                              alignment: Alignment.center,
                              color: Colors.transparent,
                              child: Text(
                                ID.CommonSearch.tr,
                                style: TextStyle(color: Colors.white, backgroundColor: Colors.transparent),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
            body: EasyRefresh(
              header: MaterialHeader(),
              onRefresh: () async {
                if (searchEC.text.isEmptyString()) {
                  refreshRC.finishRefresh();
                  return;
                }
                await searchAction();
                refreshRC.finishRefresh();
                refreshRC.finishRefresh(success: true);
              },
              onLoad: () async {

              },
              controller: refreshRC,
              child: ListView(controller: scrollController, children: [
                Obx(() => discoverSearchPC.showHistLabel.value
                    ? StickyHeader(
                        header: _createLabel(ID.DiscoverSearchHistory.tr, delete: () {
                          PreferencesUtil.putStringList(Constant.ZDiscoverSearchHistory, <String>[]);
                          discoverSearchPC.setHistList(<String>[]);
                        }),
                        content: Container(
                          width: double.infinity,
                          padding: SizeUtil.padding(bottom: 5, top: 5, left: 5, right: 5),
                          child: Wrap(
                            children: _createSearchHistory(),
                          ),
                        ),
                      )
                    : Container(),
                ),
                Obx(
                  () => discoverSearchPC.showEmpty.value
                      ? StickyHeader(
                          header: _createLabel(ID.DiscoverSearchHistory.tr),
                          content: StatusWidget(LoadStatus.empty),
                        )
                      : discoverSearchPC.searchItems.length > 0
                          ? StickyHeader(
                              header: _createLabel(ID.DiscoverSearchHistory.tr),
                              content: _createItems(),
                            )
                          : Container(),
                ),
              ]),
            ),
        ),
      ),
    );
  }

  List<Widget> _createSearchHistory() {
    List<Widget> items = [];
    List<String> urls = discoverSearchPC.showHistList.value;
    urls.forEach((el) {
      items.add(Padding(
        padding: SizeUtil.padding(all: 5),
        child: Material(
          shape: RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: SizeUtil.radius(all: 30),
          ),
          child: InkWell(
            borderRadius: SizeUtil.radius(all: 30),
            child: Container(
              padding: SizeUtil.padding(top: 5, bottom: 5, left: 10, right: 10),
              decoration: BoxDecoration(
                color: ZColors.ZFFFFFFFFTheme1(context),
                borderRadius: SizeUtil.radius(all: 30),
                border: Border.all(color: ZColors.ZFFFAFAFA),
                boxShadow: [BoxShadow(color: Colors.black12, offset: Offset(0, 1.0), blurRadius: 1, spreadRadius: 0)],
              ),
              child: Text(
                "$el",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: AppTheme.text14(),
              ),
            ),
            onTap: () async {
              searchEC.text = el;
              discoverSearchPC.changeShowClear(true);
              searchAction();
            },
          ),
        ),
      ));
    });
    return items;
  }

  Widget _createLabel(label, {VoidCallback? delete}) {
    return Container(
      color: ZColors.ZFFFFFFFFTheme1(context),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            height: SizeUtil.height(30),
            padding: SizeUtil.padding(left: 14, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(label),
                Spacer(),
                delete != null
                    ? Material(
                        color: ZColors.ZFFFFFFFFTheme1(context),
                        child: InkWell(
                          child: Container(
                            width: SizeUtil.width(30),
                            height: SizeUtil.width(30),
                            padding: SizeUtil.padding(all: 5),
                            child: Icon(
                              Icons.delete_forever,
                              size: SizeUtil.width(15),
                              color: ZColors.ZFF2D4067Theme(context),
                            ),
                          ),
                          onTap: delete,
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          Divider(
            height: 1,
          )
        ],
      ),
    );
  }

  Widget _createItems() {
    return discoverSearchPC.showLoading.value
        ? LoadingDialogWidget()
        : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            controller: scrollController,
            itemBuilder: (context, index) {
              DiscoverDappModel item = discoverSearchPC.searchItems[index];
              return _createItem(item, index, 'normal');
            },
            itemCount: discoverSearchPC.searchItems.length,
          );
  }

  Widget _createItem(DiscoverDappModel item, index, type) {
    return Material(
      color: ZColors.ZFFFFFFFFTheme1(context),
      shadowColor: ZColors.ZFFFAFAFA,
      elevation: 1,
      child: InkWell(
        onTap: () async {
          bool hasChain = false;
          Global.CURRENT_CONIS.forEach((element) {
            if (element.contract == item.chain) {
              hasChain = true;
              return;
            }
          });
          if (!hasChain) {
            AlertUtil.showWarnBar((ID.WalletChainAdd.tr).replaceAll('{%s}', item.chain!));
            return;
          }
          bool has = PreferencesUtil.getBool('DAPP:${item.name}');
          if (!has) {
            await showDialog(
                useSafeArea: false,
                context: context,
                builder: (builder) {
                  return DiscoverIdentityDialogWidget(
                    icon: item.icon!,
                    name: item.name!,
                    chain: item.chain!,
                    callback: (result) async {
                      PreferencesUtil.putBool('DAPP:${item.name}', result);
                      Get.back();
                      if (result) {
                        Get.to(CommonWebviewPage(), arguments: {"url": item.url, "dapp": item});
                      }
                    },
                  );
                });
          } else {
            Get.to(CommonWebviewPage(), arguments: {"url": item.url, "dapp": item});
          }
        },
        child: Container(
          padding: SizeUtil.padding(left: 10, right: 10, top: 10, bottom: 10),
          child: Row(
            children: [
              Container(
                margin: SizeUtil.margin(right: 12),
                padding: SizeUtil.padding(all: 5),
                decoration: BoxDecoration(
                  color: ZColors.ZFFFAFAFA,
                  border: Border.all(color: ZColors.ZFFF5F5F5),
                  borderRadius: BorderRadius.all(Radius.circular(6.0)),
                ),
                child: CustomWidget.buildNetworkImage(context, item.icon!, SizeUtil.width(35), SizeUtil.width(35), SizeUtil.width(4))
              ),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "${item.name}",
                            style: AppTheme.text14(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            " (${item.chain})",
                            style: AppTheme.text12(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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
            ],
          ),
        ),
      ),
    );
  }
}
