import 'dart:convert';

import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/event/event.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/service/api_data.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/chain_evm_util.dart';
import 'package:abey_wallet/utils/chain_util.dart';
import 'package:abey_wallet/utils/preferences_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:abey_wallet/extension/string_extension.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SetAddressAddPage extends StatefulWidget {
  const SetAddressAddPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SetAddressAddPageState();
  }
}

class SetAddressAddPageState extends State<SetAddressAddPage> {
  AddressModel? oriAddress;
  AddressModelList addressModelList = AddressModelList();

  TextEditingController _nameEC = TextEditingController();
  TextEditingController _addressEC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameEC.text = "";
    _addressEC.text = "";

    if (Get.arguments != null) {
      oriAddress = Get.arguments["oriAddress"];
      if (oriAddress != null) {
        _nameEC.text = oriAddress?.name ?? "";
        _addressEC.text = oriAddress?.address ?? "";

        if (mounted) {
          setState(() {

          });
        }
      }
    }

    String addressS = PreferencesUtil.getString(Constant.ZAddressBook, defValue: "");
    if (addressS.isNotEmptyString()) {
      addressModelList = AddressModelList.fromJson(json.decode(addressS));
    }
  }

  void addAction() async {
    if(_nameEC.text.trim().isEmptyString()) {
      AlertUtil.showWarnBar(ID.MineAddressTipOne.tr);
      return;
    }
    if(_addressEC.text.trim().isEmptyString()) {
      AlertUtil.showWarnBar(ID.MineAddressTipTwo.tr);
      return;
    } else {
      // String isAddress = await ChainUtil.vertityAddress(context, "ETH", _addressEC.text.trim().toLowerCase());
      String isAddress = await ChainEvmUtil.verityAddress(_addressEC.text.trim().toLowerCase()).toString();
      if (isAddress == "false") {
        AlertUtil.showWarnBar(ID.MineAddressTipTwo.tr);
        return;
      }
    }
    if (oriAddress != null) {
      if (addressModelList != null && addressModelList.addressList != null && addressModelList.addressList!.length > 0) {
        for (AddressModel addressModel in addressModelList.addressList!) {
          if (addressModel.address == oriAddress?.address) {
            addressModel.name = _nameEC.text.trim();
            addressModel.address = _addressEC.text.trim();
          }
        }
      }
    } else {
      if (addressModelList != null && addressModelList.addressList != null && addressModelList.addressList!.length > 0) {
        for (AddressModel addressModel in addressModelList.addressList!) {
          if (addressModel.address == _addressEC.text.trim().toLowerCase()) {
            AlertUtil.showWarnBar(ID.MineAddressTipThree.tr);
            return;
          }
        }
        AddressModel addressModel = AddressModel(name: _nameEC.text.trim(), address: _addressEC.text.trim().toLowerCase());
        addressModelList.addressList?.add(addressModel);
      } else {
        addressModelList = AddressModelList();
        List<AddressModel> addressList = [];
        AddressModel addressModel = AddressModel(name: _nameEC.text.trim(), address: _addressEC.text.trim().toLowerCase());
        addressList.add(addressModel);
        addressModelList.addressList = addressList;
      }
    }

    String jsonS = json.encode(addressModelList.toJson());
    PreferencesUtil.putString(Constant.ZAddressBook, jsonS);

    eventBus.fire(UpdateAddressBook());
    Get.back();
  }

  void deleteAction() {
    if (oriAddress != null && addressModelList != null && addressModelList.addressList != null && addressModelList.addressList!.length > 0) {
      List<AddressModel> addressList = [];
      for (AddressModel addressModel in addressModelList.addressList!) {
        if (addressModel.address == oriAddress?.address) {
        } else {
          addressList.add(addressModel);
        }
      }
      addressModelList.addressList = addressList;
      String jsonS = json.encode(addressModelList.toJson());
      PreferencesUtil.putString(Constant.ZAddressBook, jsonS);

      eventBus.fire(UpdateAddressBook());
      Get.back();
    }
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
      child:Scaffold(
        resizeToAvoidBottomInset:false,
        backgroundColor: ZColors.KFFFFFFFFTheme(context),
        appBar: AppbarWidget.initAppBar(context,isBack: true,title: ID.MineAddressAddress.tr,),
        body: Column(
          children: [
            Container(
              margin: SizeUtil.margin(all: 15),
              padding: SizeUtil.padding(top: 17, bottom: 17),
              width: SizeUtil.screenWidth() - SizeUtil.width(26),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SizeUtil.width(15)),
                color: ZColors.KFFF9FAFBTheme(context),
              ),
              child: Column(
                children: _createContent(),
              ),
            ),
            Spacer(),
            Container(
              margin: EdgeInsets.only(left: 20,right: 20),
              child: CustomWidget.buildButtonImage(() {
                addAction();
              },text: ID.CommonSave.tr),
            ),

            oriAddress != null ? SizedBox(height: SizeUtil.width(20),) : Container(),

            oriAddress != null ? MaterialButton(
              onPressed: () {
                deleteAction();
              },
              color: ZColors.ZFFFFFFFF,
              minWidth: SizeUtil.width(300),
              height: SizeUtil.width(45),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: ZColors.ZFFEECC5B,
                  width: 1,
                  style: BorderStyle.solid,
                ),
                borderRadius: SizeUtil.radius(all: 6),
              ),
              child: Text(
                ID.MineAddressDelete.tr,
                style: AppTheme.text16(color: ZColors.ZFFEECC5B, fontWeight: FontWeight.w600),
              ),
            ) : Container(),

            SizedBox(height: SizeUtil.width(40),)
          ],
        ),
      ),
    );
  }

  List<Widget> _createContent() {
    List<Widget> views =[
      CustomWidget.buildCardX(CustomWidget.buildInputName(ID.MineAddressName.tr,_nameEC,)),
      CustomWidget.buildCardX(CustomWidget.buildInputAddress(ID.MineAddressAddress.tr, _addressEC,)),
    ];
    return views;
  }

  @override
  void dispose() {
    super.dispose();
  }
}