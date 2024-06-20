import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/event/event.dart';
import 'package:abey_wallet/model/coin_model.dart';
import 'package:abey_wallet/model/identity_model.dart';
import 'package:abey_wallet/pages/kyf_chain_token.dart';
import 'package:abey_wallet/pages/kyf_token.dart';
import 'package:abey_wallet/pages/wallet_chain_add.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/service/api_data.dart';
import 'package:abey_wallet/service/api_manager.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/common_util.dart';
import 'package:abey_wallet/utils/database_util.dart';
import 'package:abey_wallet/utils/preferences_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:abey_wallet/widget/dialog/common_dialog_widget.dart';
import 'package:abey_wallet/widget/status_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:abey_wallet/extension/string_extension.dart';

class KyfPage extends StatefulWidget {
  const KyfPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return KyfPageState();
  }
}

class KyfPageController extends GetxController {
  var wid = "".obs;
  Rx<IdentityModel> identityModel = IdentityModel().obs;
  var contract = "".obs;
  var kyfItems = [].obs;

  changeWid(data) => wid.value = data;

  changeIdentityModel(data) => identityModel.value = data;

  changeContract(data) {
    if (data != null) {
      contract.value = data;
    }
  }

  changeKyfItems(data) {
    if (data != null) {
      kyfItems.value = data;
    }
  }
}

class KyfPageState extends State<KyfPage> {
  KyfPageController kyfPageController = Get.put(KyfPageController());
  EasyRefreshController refreshController = EasyRefreshController();

  List<CoinModel> chainList = [];
  String currentChain = "ABEY";

  bool isFirst = true;

  @override
  void initState() {
    super.initState();
    eventBus.on<UpdateIdentity>().listen((event) {
      initData();
    });
    eventBus.on<UpdateKyf>().listen((event) async {
      requestDate();
    });
    eventBus.on<UpdateTradeKyfBack>().listen((event) async {
      tradeActionKyfBack();
    });
    initData();
  }

  void tradeActionKyfBack() {
    requestDate();
  }

  void initData() async {
    kyfPageController.changeWid(PreferencesUtil.getString(Constant.CURRENT_WID));
    await initIdentity();
    changNChain("ABEY");
  }

  Future<bool> initIdentity() async {
    var identity = await DatabaseUtil.create().queryCurrentIdentityByWid(kyfPageController.wid.value);
    kyfPageController.changeIdentityModel(identity);
    if (mounted) {
      setState(() {

      });
    }
    return true;
  }

  Future<bool> requestDate() async {
    if (isFirst) {
      isFirst = false;
    } else {
      AlertUtil.showLoadingDialog(context,show: true);
    }
    ApiData apiData = await ApiManager.postKyfIndex(data:{
      "wid": kyfPageController.wid.value,
      "contract": currentChain
    });
    if (!isFirst) {
      AlertUtil.showLoadingDialog(context,show: false);
    }
    if (apiData.code == 0) {
      KyfListModel kyfListModel = KyfListModel.fromJson(apiData.data);
      if (kyfListModel != null) {
        kyfPageController.changeKyfItems(kyfListModel.items);
        if (mounted) {
          setState(() {

          });
        }
      }
    } else {
      AlertUtil.showTipsBar(ID.CommonNetworkError.tr);
    }
    return true;
  }

  void onAssetsAction() async {
    List<CoinModel> coinModelList = await DatabaseUtil.create().queryCoinList(new CoinModel(wid: kyfPageController.wid.value));
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
                    padding: EdgeInsets.only(
                        left: SizeUtil.width(10), right: SizeUtil.width(10)),
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
          decoration: (kyfPageController.contract.value.isNotEmptyString() && kyfPageController.contract.value == item.contract) ? BoxDecoration(
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
          "identityModel": kyfPageController.identityModel.value,
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
    kyfPageController.changeContract(contract);
    requestDate();
  }

  void onAddAction() {
    var result = Get.to(KyfChainTokenPage(), arguments: {"identityModel": kyfPageController.identityModel.value});
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
      ),
      ),
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
        refreshController.finishRefresh(success: true);
      },
      controller: refreshController,
      child: SingleChildScrollView(
        child: Column(
          children: [
            createAssets(),
            Obx(() => kyfPageController.kyfItems != null && kyfPageController.kyfItems.length > 0
                ? ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return getContentItem(context, index);
              },
              itemCount: kyfPageController.kyfItems != null && kyfPageController.kyfItems.length > 0
                  ? kyfPageController.kyfItems.length
                  : 0,
              padding: EdgeInsets.all(0.0),
            )
                : StatusWidget(LoadStatus.empty),
            ),
          ],
        ),
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
            "NFT",
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
                      onAddAction();
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

  getContentItem(BuildContext context, int index) {
    KyfModel kyfModel = kyfPageController.kyfItems[index];
    return Container(
      margin: SizeUtil.margin(left: 15, right: 15, top: 5, bottom: 5),
      decoration: BoxDecoration(
        borderRadius: SizeUtil.radius(all: 10),
        color: ZColors.KFFF9FAFBTheme(context),
      ),
      child: InkWell(
        onTap: () {
          Get.to(KyfTokenPage(), arguments: {"kyfModel": kyfModel, "identityModel": kyfPageController.identityModel.value});
        },
        child: KyfCellWidget(
          index: index,
          kyfModel: kyfModel,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class KyfCellWidget extends StatelessWidget {
  int? index;
  KyfModel? kyfModel;

  KyfCellWidget({this.index, this.kyfModel});

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeUtil.padding(all: SizeUtil.width(8)),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                margin: SizeUtil.margin(right: 12),
                padding: SizeUtil.padding(all: SizeUtil.width(4)),
                decoration: BoxDecoration(
                  color: ZColors.ZFFF5F5F5,
                  border: Border.all(color: ZColors.ZFFF5F5F5),
                  borderRadius: BorderRadius.all(Radius.circular(6.0)),
                ),
                child: CustomWidget.buildNetworkImage(context, kyfModel!.icon!, SizeUtil.width(35), SizeUtil.width(35), SizeUtil.width(4)),
              ),
            ],
          ),
          Expanded(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${kyfModel!.name}" + (kyfModel != null && kyfModel!.balance != null ? " (${kyfModel!.balance} " + ID.KyfPiece.tr + ")" : "(0 " + ID.KyfPiece.tr + ")"),
                    style: AppTheme.text14(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Container(
                    padding: SizeUtil.padding(top: 5),
                    child: Text(
                      "${kyfModel!.detail}",
                      style: AppTheme.text12(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: SizeUtil.width(12),
            color: ZColors.ZFF2D4067Theme(context),
          ),
        ],
      ),
    );
  }
}
