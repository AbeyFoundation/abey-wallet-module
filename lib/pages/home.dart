import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/global.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/event/event.dart';
import 'package:abey_wallet/model/coin_model.dart';
import 'package:abey_wallet/model/identity_model.dart';
import 'package:abey_wallet/pages/contain.dart';
import 'package:abey_wallet/pages/wallet_create.dart';
import 'package:abey_wallet/pages/wallet_manager.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/service/api_manager.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/database_util.dart';
import 'package:abey_wallet/utils/preferences_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/vender/drawer/drawer_kylin_controller.dart';
import 'package:abey_wallet/extension/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  Widget? screenView;
  bool isOpen = false;

  List<IdentityModel> identityModelList = <IdentityModel>[];

  ContainPage containPage = ContainPage();

  String? action;

  @override
  void initState() {
    screenView = containPage;
    super.initState();
    eventBus.on<EDrawer>().listen((event) {
      drawerAction();
    });
    eventBus.on<UpdateIdentity>().listen((event) {
      drawerClipAction();
    });
    eventBus.on<UpdateChain>().listen((event) {
      drawerClipAction();
    });
    eventBus.on<UpdateDrawer>().listen((event) {
      drawerClipAction();
    });
    eventBus.on<UpdateTokenid>().listen((event) {
      deviceTokenAction(event.tokenid);
    });

    if (Get.arguments != null) {
      if (Get.arguments['action'] != null) {
        action = Get.arguments['action'];
        if (action == "refresh") {
          String fcmtoken = PreferencesUtil.getString(Constant.FCMToken);
          if (fcmtoken.isNotEmpty) {
            deviceTokenAction(fcmtoken);
          }
        }
      }
    }

    drawerClipAction();
  }

  void drawerAction() async {
    _globalKey.currentState!.openEndDrawer();
    identityModelList = await DatabaseUtil.create().queryIdentityList();
    if (mounted) {
      setState(() {

      });
    }
  }

  void drawerClipAction() async {
    identityModelList = await DatabaseUtil.create().queryIdentityList();
    if (mounted) {
      setState(() {

      });
    }
  }

  void changeIdentityModel(IdentityModel identityModel) {
    Get.back();
    if (identityModel == PreferencesUtil.getString(Constant.CURRENT_WID,)) {
      return;
    } else {
      PreferencesUtil.putString(Constant.CURRENT_WID, identityModel.wid!);
      eventBus.fire(UpdateIdentity(identityModel));
    }
  }

  void deviceTokenAction(String tokenid) async {
    identityModelList = await DatabaseUtil.create().queryIdentityList();
    if (identityModelList != null) {
      List<CoinModel> chainList = [];
      for (final identityModel in identityModelList) {
        CoinModel coinModel = new CoinModel(wid: identityModel.wid);
        List<CoinModel> coinList = await DatabaseUtil.create().queryCoinList(coinModel);
        if (coinList != null && coinList.length > 0) {
          coinList.forEach((element) {
            if (element.symbol == element.contract && element.contract == "ABEY") {
              chainList.add(element);
            }
          });
        }
      }
      String addressStr = "";
      for (final coinModel in chainList) {
        if (coinModel.address?.isNotEmptyString()) {
          if (addressStr.length > 0) {
            if (!addressStr.contains(coinModel.address!.toLowerCase())) {
              addressStr = addressStr + "," + (coinModel.address?.toLowerCase() ?? "");
            }
          } else {
            addressStr = (coinModel.address?.toLowerCase() ?? "");
          }
        }
      }
      String language = PreferencesUtil.getString(Constant.ZLanguage);
      ApiManager.postConfigDeviceTokenid(data: {
        "deviceId": Global.DEVICE_ID,
        "tokenId": tokenid,
        "addressStr": addressStr,
        "lang": language.isNotEmpty ? language : 'en'
      });
    }
  }

  void showAlert(String event) {
    if (mounted) {
      AlertUtil.showTipsBar(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ZColors.ZFFEEEEEE,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          key: _globalKey,
          backgroundColor: ZColors.KFFFFFFFFTheme(context),
          body: DrawerKylinController(
            drawerWidth: MediaQuery.of(context).size.width * 0.75,
            identityModelList: identityModelList,
            drawerIsOpen: (isOpen) {
              this.isOpen = isOpen;
              setState(() {

              });
            },
            screenView: screenView!,
          ),
        ),
      ),
    );
  }

  Widget drawerWidget() {
    return Column(
      children: [
        SizedBox(height: SizeUtil.barHeight(),),
        Container(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 12,),
              Image.asset(
                Constant.Assets_Images + "wallet_icon.png",
                width: SizeUtil.width(16),
                height: SizeUtil.width(16),
              ),
              SizedBox(width: 6,),
              Text(
                ID.WalletList.tr,
                style: AppTheme.text16(),
              ),
              Spacer(),
            ],
          ),
        ),
        SizedBox(
          height: SizeUtil.height(10),
        ),
        Expanded(
          child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: identityModelList.length,
              itemBuilder: (context, index) {
                IdentityModel item = identityModelList[index];
                return createWalletItem(item, item.wid == PreferencesUtil.getString(Constant.CURRENT_WID,));
              }),
        ),
        InkWell(
          onTap: () {
            Get.back();
            Get.to(WalletCreatePage(), arguments: {"canBack": true}, transition: Transition.fadeIn);
          },
          child: Container(
            height: SizeUtil.width(44),
            margin: SizeUtil.margin(left: 15, right: 15, bottom: 15, top: 10),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(Constant.Assets_Images + "common_button_back.png"),
                    fit: BoxFit.fill
                )
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  Constant.Assets_Images + "wallet_add2.png",
                  width: SizeUtil.width(26),
                  height: SizeUtil.width(26),
                ),
                SizedBox(width: 5,),
                Text(
                  ID.WalletAdd.tr,
                  style: AppTheme.text16(color: ZColors.ZFFFFFFFF, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget createWalletItem(IdentityModel identity, bool checked) {
    if (identity == null) {
      return Container();
    }
    double itemHeight = SizeUtil.height(50);
    return Container(
      margin: SizeUtil.margin(left: 10, right: 10, bottom: 5, top: 5),
      width: SizeUtil.screenWidth(),
      decoration: new BoxDecoration(
        color: ZColors.ZFFEECC5B,
        borderRadius: new BorderRadius.all(new Radius.circular(SizeUtil.width(17))),
      ),
      child: Row(
        children: [
          Expanded(
              child: Container(
                width: SizeUtil.screenWidth(),
                margin: SizeUtil.margin(right: 10),
                padding: SizeUtil.padding(left: 10, right: 10),
                alignment: Alignment.centerLeft,
                height: itemHeight,
                child: InkWell(
                  onTap: () {
                    changeIdentityModel(identity);
                  },
                  child: Container(
                    width: SizeUtil.screenWidth(),
                    child: Row(
                      children: [
                        Container(
                          width: SizeUtil.width(40),
                          child: checked ? Icon(
                            Icons.check,
                            color: Colors.white,
                          ) : SizedBox(
                            width: 0,
                            height: 0,
                          ),
                        ),
                        Expanded(
                            child: Text(
                              identity.name!,
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.text14(color: ZColors.ZFFFFFFFF, fontWeight: FontWeight.w600),
                            )),
                      ],
                    ),
                  ),
                ),
              )),
          Container(
            height: itemHeight,
            width: itemHeight,
            child: IconButton(
              onPressed: () async {
                Get.back();
                var result = await Get.to(WalletManagerPage(), arguments: {"identityModel": identity});
              },
              icon: Icon(
                Icons.settings,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}