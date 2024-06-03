import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/event/event.dart';
import 'package:abey_wallet/model/coin_model.dart';
import 'package:abey_wallet/model/identity_model.dart';
import 'package:abey_wallet/pages/wallet_create_mnemonic.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/service/api_data.dart';
import 'package:abey_wallet/service/api_manager.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/chain_util.dart';
import 'package:abey_wallet/utils/common_util.dart';
import 'package:abey_wallet/utils/database_util.dart';
import 'package:abey_wallet/utils/password_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:abey_wallet/widget/status_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:abey_wallet/extension/string_extension.dart';

class WalletChainAddPage extends StatefulWidget {
  const WalletChainAddPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WalletChainAddPageState();
  }
}

class WalletChainAddPageState extends State<WalletChainAddPage> {

  List<CoinModel> coinModelList = [];
  IdentityModel? identityModel;
  String? pass;
  int selectCount = 0;

  EasyRefreshController _refreshController = EasyRefreshController();

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      if (Get.arguments['identityModel'] != null) {
        identityModel = Get.arguments['identityModel'];
      }
      if (Get.arguments['pass'] != null) {
        pass = Get.arguments['pass'];
      }
    }

    _getChains();
  }

  _getChains() async {
    ApiData apiData = await ApiManager.postWalletChains(data:{
      "wid": identityModel!.wid,
    });
    if (apiData.code == 0) {
      WalletChainsModel walletChainsModel = WalletChainsModel.fromJson(apiData.data);
      if (walletChainsModel != null) {
        coinModelList = walletChainsModel.tokens!;
        if (mounted) {
          setState(() {

          });
        }
      }
    }
  }

  _commitChecked() async {
    List<CoinModel> checked = [];
    for (var value in coinModelList) {
      if (value.selected!) {
        checked.add(value);
      }
    }
    if (checked.isEmpty) {
      AlertUtil.showWarnBar(ID.WalletSelectChainTip.tr);
      return;
    }
    if (pass!.isEmptyString()) {
      await PasswordUtil.handlePassword(context, (text, goback) async {
        String pass = CommonUtil.getTokenId(text);
        var auth = await DatabaseUtil.create().queryAuth();
        if(pass != auth.password){
          AlertUtil.showWarnBar(ID.CommonPassword.tr);
        } else {
          AlertUtil.showLoadingDialog(context, show: true);
          await ChainUtil.saveCoin(context, identityModel!, identityModel!.type!, checked, pass, true);
          AlertUtil.showLoadingDialog(context, show: false);
          if (goback) {
            Get.back();
          }
        }
      });

      await _getChains();
      eventBus.fire(UpdateChain());
      Get.back();
    } else {
      if (identityModel!.type == 0) {
        Get.to(WalletCreateMnemonicPage(), arguments: {
          "identityModel": identityModel,
          "pass": pass,
          "chains": checked,
        });
      } else if (identityModel!.type == 1) {
        Get.back(result: {'chains': checked});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:false,
      backgroundColor: ZColors.KFFFFFFFFTheme(context),
      appBar: AppbarWidget.initAppBar(context,isBack: true,title: ID.WalletSelectChainMore.tr,),
      body: Column(
        children: [
          Expanded(
              child: Container(
                margin: SizeUtil.margin(left: 15, right: 15),
                padding: SizeUtil.padding(all: 2),
                decoration: BoxDecoration(
                  color: ZColors.KFFF9FAFBTheme(context),
                  borderRadius: SizeUtil.radius(all: 10),
                ),
                child: CustomWidget.buildRefresh(_createCheckList(), _refreshController, coinModelList.length > 0 ? null : StatusWidget(LoadStatus.empty), () async {
                  await _getChains();
                  _refreshController.finishRefresh();
                }),
              ),
          ),
          selectCount > 0 ? Container(
            margin: EdgeInsets.only(left: 20,right: 20, bottom: 40),
            child: CustomWidget.buildButtonImage(() {
              _commitChecked();
            },text: ID.CommonConfirm.tr),
          ) : _confirmButton(),
        ],
      ),
    );
  }

  //多选
  Widget _createCheckList() {
    return ListView.builder(
        itemCount: coinModelList.length,
        itemBuilder: (context, index) {
          CoinModel item = coinModelList[index];
          return Container(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      margin: SizeUtil.margin(all: 10),
                      padding: SizeUtil.padding(all: 3),
                      decoration: new BoxDecoration(
                          color: ZColors.ZFFEEEEEE,
                          borderRadius: new BorderRadius.circular(SizeUtil.width(30)),
                      ),
                      child: CustomWidget.buildNetworkImage(context, item.icon!, SizeUtil.width(30), SizeUtil.width(30), SizeUtil.width(15)),
                    ),
                    Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:SizeUtil.padding(bottom: 4),
                              child: Text(item.symbol!,style: AppTheme.text14(fontWeight: FontWeight.w600),overflow: TextOverflow.ellipsis),
                            ),
                            Text(CommonUtil.getChainName(item.name!),style: AppTheme.text12(),textAlign: TextAlign.center,overflow: TextOverflow.ellipsis),
                          ],
                        )),
                    Checkbox(
                        value: item.selected ?? false,
                        onChanged: !item.canAction! ? null : (val) {
                          if (val!) {
                            selectCount++;
                          } else {
                            selectCount--;
                          }
                          setState(() {
                            item.selected = val;
                          });
                        })
                  ],
                ),
                Divider(
                  height: 1,
                )
              ],
            ),
          );
        });
  }

  Widget _createSingleList() {
    return ListView.builder(
        itemCount: coinModelList.length,
        itemBuilder: (context, index) {
          CoinModel item = coinModelList[index];
          return Material(
            child: InkWell(
              onTap: () async {
                // _commitAppend([item]);
              },
              child: Container(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          child: CustomWidget.buildNetworkImage(context, item.icon!, SizeUtil.width(38), SizeUtil.width(38), SizeUtil.width(19))
                        ),
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.symbol!, style:AppTheme.text14(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                                Text(CommonUtil.getChainName(item.name!), style: AppTheme.text12(),textAlign: TextAlign.center,overflow: TextOverflow.ellipsis),
                              ],
                            ))
                      ],
                    ),
                    Divider(
                      height: 1,
                      color: ZColors.ZFFF2F2F2Theme(context),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _confirmButton() {
    return Container(
      margin: EdgeInsets.only(left: 30,right: 30,top: 20,bottom: 40),
      child: MaterialButton(
        onPressed: selectCount > 0 ? () {
          _commitChecked();
        } : null,
        disabledColor: ZColors.ZFFA2A6B0,
        color: ZColors.ZFFEECC5B,
        minWidth: SizeUtil.width(300),
        height: SizeUtil.width(45),
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: SizeUtil.radius(all: SizeUtil.width(6)),
        ),
        child: Text(
          ID.CommonConfirm.tr,
          style: AppTheme.text16(color: ZColors.ZFFFFFFFF, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}