import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/extension/string_extension.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransferFinishDialogWidget extends StatefulWidget {
  final VoidCallback? callback;

  final String? hash;

  const TransferFinishDialogWidget({Key? key,
    this.hash,
    this.callback
  }) : super(key: key);

  @override
  TransferFinishDialogWidgetState createState() => TransferFinishDialogWidgetState();
}

class TransferFinishDialogWidgetState extends State<TransferFinishDialogWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: IntrinsicHeight(
        child: Stack(
          children: [
            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  width: SizeUtil.screenWidth(),
                  decoration: BoxDecoration(
                    color: ZColors.ZFFFAFAFATheme(context),
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding:SizeUtil.padding(top:10),
                            child: Text(
                              ID.WalletTransferResult.tr,
                              style: AppTheme.text18(),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          widget.hash?.isNotEmptyString() ? Image.asset(Constant.Assets_Images + "wallet_transfer_success.png",width: SizeUtil.width(44),) : Image.asset(Constant.Assets_Images + "wallet_transfer_fail.png",width: SizeUtil.width(44),),
                          SizedBox(
                            height: 10,
                          ),
                          widget.hash?.isNotEmptyString() ? Padding(padding: SizeUtil.padding(top: 10,bottom: 6),
                            child:Text(ID.WalletTransferResultTip1.tr,style: AppTheme.text16(),),
                          ) : Padding(padding: SizeUtil.padding(top: 10,bottom: 6),
                            child:Text(ID.WalletTransferResultTip2.tr,style: AppTheme.text16(),),
                          ),

                          widget.hash?.isNotEmptyString() ? Padding(padding: SizeUtil.padding(top: 10,bottom: 6, left: 25, right: 25),
                            child:Text(ID.WalletTransferResultTip3.tr,style: AppTheme.text14(),textAlign: TextAlign.center,),
                          ) : Padding(padding: SizeUtil.padding(top: 10,bottom: 6, left: 25, right: 25),
                            child:Text(ID.WalletTransferResultTip4.tr,style: AppTheme.text14(),textAlign: TextAlign.center,),
                          ),

                          Container(
                            margin: SizeUtil.margin(bottom: 30,left: 15,right: 15,top: 15),
                            width: SizeUtil.screenWidth(),
                            child: CustomWidget.buildButtonImage(() {
                              Navigator.pop(context);
                              if(widget.callback!=null){
                                widget.callback!();
                              }
                            },text: ID.CommonConfirm.tr),
                          ),
                        ],
                      ),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}