import 'dart:convert';
import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/event/event.dart';
import 'package:abey_wallet/pages/set_address_add.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/service/api_data.dart';
import 'package:abey_wallet/utils/preferences_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/CustomBehavior.dart';
import 'package:abey_wallet/widget/appbar_widget.dart';
import 'package:abey_wallet/widget/status_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:abey_wallet/extension/string_extension.dart';

class SetAddressPage extends StatefulWidget {

  const SetAddressPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SetAddressPageState();
  }
}

class SetAddressPageState extends State<SetAddressPage> {
  AddressModelList addressModelList = AddressModelList();

  @override
  void initState() {
    super.initState();
    eventBus.on<UpdateAddressBook>().listen((event) {
      initAddressBook();
    });
    initAddressBook();
  }

  void initAddressBook() {
    String addressS = PreferencesUtil.getString(Constant.ZAddressBook, defValue: "");
    if (addressS.isNotEmptyString()) {
      addressModelList = AddressModelList.fromJson(json.decode(addressS));
    }
    if (mounted) {
      setState(() {

      });
    }
  }

  void addAction() {
    Get.to(SetAddressAddPage(), arguments: {});
  }

  void selectAddress(AddressModel? addressModel) {
    Get.to(SetAddressAddPage(), arguments: {"oriAddress": addressModel});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ZColors.KFFFFFFFFTheme(context),
      appBar: AppbarWidget.initAppBar(context, isBack: true,title: ID.MineAddressBook.tr, widget: IconButton(
          icon: Icon(Icons.add),
          color: ZColors.ZFF2D4067Theme(context),
          onPressed: () async {
            addAction();
          }),
      ),
      body: Container(
        height: double.infinity,
        margin: SizeUtil.margin(left: 15,right: 15,top: 5, bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(SizeUtil.width(9))),
          color: ZColors.ZFFFFFFFFTheme1(context),
        ),
        child: addressModelList != null && addressModelList.addressList != null && addressModelList.addressList!.length > 0 ? ScrollConfiguration(
          behavior: CustomBehavior(),
          child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: addressModelList != null && addressModelList.addressList != null ? addressModelList.addressList?.length : 0,
              itemBuilder: (context, index) {
                return getContentItem(context,index);
              }),
        ) : StatusWidget(LoadStatus.empty),
      )
    );
  }

  getContentItem(BuildContext context, int index) {
    if (addressModelList != null && addressModelList.addressList != null && addressModelList.addressList!.length > index) {
      AddressModel? addressModel = addressModelList.addressList?[index];
      return InkWell(
        onTap: () {
          print('$index');
          selectAddress(addressModel);
        },
        child: SettingLanguageCellWidget(index: index,addressModel: addressModel,),
      );
    } else {

    }
  }
}

class SettingLanguageCellWidget extends StatelessWidget {
  int? index;
  AddressModel? addressModel;

  SettingLanguageCellWidget({this.index,this.addressModel});

  @override
  Widget build(BuildContext context) {
    String name = addressModel?.name ?? "";
    String address = addressModel?.address ?? "";

    return Container(
      height: SizeUtil.width(60),
      margin: SizeUtil.margin(top: 5, bottom: 5),
      padding: SizeUtil.padding(top: 5, bottom: 5),
      width: SizeUtil.screenWidth() - SizeUtil.width(30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeUtil.width(15)),
        color: ZColors.KFFF9FAFBTheme(context),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: <Widget>[
                SizedBox(width:  SizeUtil.width(20),),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Text(
                      name,
                      style: AppTheme.text14(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(width:  SizeUtil.width(20),),
                Expanded(
                  flex: 2,
                  child: Container(
                    child: Text(
                      address,
                      style: AppTheme.text14(),
                      maxLines: 2,
                    ),
                  ),
                ),
                SizedBox(width: 20,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
