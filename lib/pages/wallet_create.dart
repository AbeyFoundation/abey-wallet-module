import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/model/tray_model.dart';
import 'package:abey_wallet/model/wallet_model.dart';
import 'package:abey_wallet/pages/wallet_create_new.dart';
import 'package:abey_wallet/pages/wallet_import_keystore.dart';
import 'package:abey_wallet/pages/wallet_import_mnemonic.dart';
import 'package:abey_wallet/pages/wallet_import_privatekey.dart';
import 'package:abey_wallet/pages/wallet_recovery.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/utils/preferences_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:abey_wallet/widget/dialog/agreement_dialog_widget.dart';
import 'package:abey_wallet/widget/dialog/common_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swipper/flutter_card_swiper.dart';
import 'package:get/get.dart';

class WalletCreatePage extends StatefulWidget {
  const WalletCreatePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WalletCreatePageState();
  }
}

class WalletCreatePageState extends State<WalletCreatePage> {
  bool canBack = false;

  List<String> images = [Constant.Assets_Images + "wallet_create_01.png",
    Constant.Assets_Images + "wallet_create_02.png",
    Constant.Assets_Images + "wallet_create_03.png",];

  TrayModel? trayModel;
  WalletListModel? walletListModel;
  WalletIosListModel? walletIosListModel;
  bool isWalletOriginal = false;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      if (Get.arguments['canBack'] != null) {
        canBack = Get.arguments['canBack'];
      }
    }
    isWalletOriginal = PreferencesUtil.getBool(Constant.WalletOriginal,defValue: false);
  }

  void createAction() {
    bool isShowProperty = PreferencesUtil.getBool(Constant.ZIsShowProperty);
    if (isShowProperty) {
      Get.to(WalletCreateNewPage());
      return;
    } else {
      showDialog(useSafeArea:false, context: context, builder: (builder) {
        return AgreementDialogWidget(callback: (value){
          Get.back();
          if (value) {
            PreferencesUtil.putBool(Constant.ZIsShowProperty, true);
            Get.to(WalletCreateNewPage());
          }
        },);
      });
    }
  }

  void importAction() {
    bool isShowProperty = PreferencesUtil.getBool(Constant.ZIsShowProperty);
    if (isShowProperty) {
      selectImportAction();
      return;
    } else {
      showDialog(useSafeArea:false, context: context, builder: (builder) {
        return AgreementDialogWidget(callback: (value){
          Get.back();
          if(value){
            PreferencesUtil.putBool(Constant.ZIsShowProperty, true);
            selectImportAction();
          }
        },);
      });
    }
  }

  void selectImportAction() {
    showDialog(
        useSafeArea:false,
        context: context,
        builder: (context) {
          return CommonDialogWidget(
            child: Material(
              child: Column(
                children: [
                  InkWell(
                    onTap: () async {
                      Get.back();
                      Get.to(WalletImportMnemonicPage(),arguments: {});
                    },
                    child: Container(
                      height: SizeUtil.height(40),
                      color: ZColors.KFFFFFFFFTheme(context),
                      child: Center(
                        child: Text(ID.WalletImportMnemonic.tr, style: AppTheme.text14()),
                      ),
                    ),
                  ),
                  Divider(height: 0.5,color: ZColors.ZFFF5F5F5,),
                  InkWell(
                    onTap: () async {
                      Get.back();
                      Get.to(WalletImportPrivatekeyPage(),arguments: {});
                    },
                    child: Container(
                      height: SizeUtil.height(40),
                      color: ZColors.KFFFFFFFFTheme(context),
                      child: Center(
                        child: Text(ID.WalletImportPrivatekey.tr, style: AppTheme.text14()),
                      ),
                    ),
                  ),
                  Divider(height: 0.5,color: ZColors.ZFFF5F5F5,),
                  InkWell(
                    onTap: () async {
                      Get.back();
                      Get.to(WalletImportKeystorePage(),arguments: {});
                    },
                    child: Container(
                      height: SizeUtil.height(40),
                      color: ZColors.KFFFFFFFFTheme(context),
                      child: Center(
                        child: Text(ID.WalletImportKeystore.tr, style: AppTheme.text14()),
                      ),
                    ),
                  ),
                  Divider(height: 0.5,color: ZColors.ZFFF5F5F5,),
                  InkWell(
                    onTap: () async {
                      Get.back();
                    },
                    child: Container(
                      height: SizeUtil.height(40),
                      color: ZColors.KFFFFFFFFTheme(context),
                      child: Center(
                        child: Text(ID.CommonCancel.tr, style: AppTheme.text14()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void RecoveryAction() async {
    bool isShowProperty = PreferencesUtil.getBool(Constant.ZIsShowProperty);
    if (isShowProperty) {
      if (walletIosListModel != null && walletIosListModel!.walletArray != null && walletIosListModel!.walletArray!.length > 0) {
        Get.to(WalletRecoveryPage(), arguments: {
          "walletIosListModel": walletIosListModel,
        });
      } else if (walletListModel != null && walletListModel!.items != null && walletListModel!.items!.length > 0) {
        Get.to(WalletRecoveryPage(), arguments: {
          "walletListModel": walletListModel,
        });
      }
      return;
    } else {
      showDialog(useSafeArea:false, context: context, builder: (builder) {
        return AgreementDialogWidget(callback: (value){
          Get.back();
          if (value) {
            PreferencesUtil.putBool(Constant.ZIsShowProperty, true);
            if (walletIosListModel != null && walletIosListModel!.walletArray != null && walletIosListModel!.walletArray!.length > 0) {
              Get.to(WalletRecoveryPage(), arguments: {
                "walletIosListModel": walletIosListModel,
              });
            } else if (walletListModel != null && walletListModel!.items != null && walletListModel!.items!.length > 0) {
              Get.to(WalletRecoveryPage(), arguments: {
                "walletListModel": walletListModel,
              });
            }
          }
        },);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZColors.KFFFFFFFFTheme(context),
      appBar: AppbarWidget.initAppBar(context,isBack: canBack,title: ID.WalletCreate.tr,),
      body: Container(
        height: SizeUtil.screenHeight(),
        child: Column(
          children: [
            createTop(),
            Spacer(),
            createBottom(),
            SizedBox(height: 50,),
          ],
        ),
      ),
    );
  }

  Widget createTop() {
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15, top: 34),
      width: SizeUtil.screenWidth(),
      height: SizeUtil.screenWidth()/320*250,
      child: images.length > 1 ? Swiper(
        containerWidth: SizeUtil.screenWidth(),
        itemBuilder: (BuildContext context, int index) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage(
                images[index],
              ), fit: BoxFit.cover,),
            ),
          );
        },
        autoplay: true,
        autoplayDelay: 5000,
        itemCount: images.length,
        pagination: new SwiperPagination(builder: DotSwiperPaginationBuilder(
            color: ZColors.KFFB6E3C9Theme(context),
            activeColor: ZColors.KFF0DA34DTheme(context),
        )),
      ) : Container(
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(SizeUtil.width(13)),
          image: DecorationImage(image: AssetImage(
            images[0],
          ), fit: BoxFit.cover,),
        ),
      ),
    );
  }

  Widget createBottom() {
    return Container(
      child: Column(
        children: [
          createCard(context: context, title: ID.WalletCreate.tr, desc: ID.WalletCreateTip.tr, onTap: () {
            createAction();
          },),
          SizedBox(
            height: 10,
          ),
          createCard(context: context, title: ID.WalletImport.tr, desc: ID.WalletImportTip.tr, onTap: () {
            importAction();
          },),
          if (isWalletOriginal == false && ((walletListModel != null && walletListModel!.items != null && walletListModel!.items!.length > 0) || (walletIosListModel != null && walletIosListModel!.walletArray != null && walletIosListModel!.walletArray!.length > 0))) SizedBox(
              height: 10,
            ),
          if (isWalletOriginal == false && ((walletListModel != null && walletListModel!.items != null && walletListModel!.items!.length > 0) || (walletIosListModel != null && walletIosListModel!.walletArray != null && walletIosListModel!.walletArray!.length > 0))) createCard(context: context, title: ID.WalletRecovery.tr, desc: ID.WalletRecoveryTip.tr, onTap: () {
            RecoveryAction();
          },),
        ],
      ),
    );
  }

  Widget createCard({BuildContext? context, String? title, String? desc, GestureTapCallback? onTap,}) {
    return Container(
      margin: SizeUtil.margin(left: 15, right: 15),
      padding: SizeUtil.padding(all: 2),
      decoration: BoxDecoration(
        color: ZColors.KFFF9FAFBTheme(context!),
        // border: new Border.all(color: ZColors.ZFFFFFFFFTheme(context), width: 1,),
        border: new Border.all(color: Colors.grey[200]!, width: 1,),
        borderRadius: SizeUtil.radius(all: 10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:BorderRadius.all(Radius.circular(SizeUtil.width(10))),
        child: Container(
          padding: SizeUtil.padding(all: 15),
          child: Row(
            children: [
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: SizeUtil.padding(bottom: 8),
                        child: Text(
                          title!,
                          style: AppTheme.text18(color: ZColors.KFF033B19Theme(context)),
                        ),
                      ),
                      Padding(
                        padding: SizeUtil.padding(),
                        child: Text(
                          desc!,
                          style: AppTheme.text12(),
                        ),
                      ),
                    ],
                  )
              ),
              Icon(Icons.arrow_forward_ios,size: SizeUtil.width(12),color: ZColors.KFF233054Theme(context),),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}