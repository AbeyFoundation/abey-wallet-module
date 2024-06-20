import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/model/coin_model.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/service/api_data.dart';
import 'package:abey_wallet/utils/math_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:abey_wallet/extension/string_extension.dart';

class TransferKyfDialogWidget extends StatefulWidget {
  final VoidCallback? callback;

  final String amount;
  final String coin;
  final String contract;
  final String from;
  final String to;
  final WalletFeeModel? fee;
  final String contractAddress;
  final CoinModel? nft;

  const TransferKyfDialogWidget({Key? key,
    this.amount="1",
    this.contract="--",
    this.coin="--",
    this.from="--",
    this.to="--",
    this.fee,
    this.contractAddress = "",
    this.nft,
    this.callback
  }) : super(key: key);

  @override
  TransferKyfDialogWidgetState createState() => TransferKyfDialogWidgetState();
}

class TransferKyfDialogWidgetState extends State<TransferKyfDialogWidget> {

  String gas_limit = '0';
  String gas_price = '0';
  String gas_price_str = '0';
  String gas = '0';

  @override
  void initState() {
    super.initState();
    gas_limit = widget.fee!.gas_limit!;
    gas_price = widget.fee!.gas_price!;
    gas_price_str = widget.fee!.gas_price_str!;
    gas = MathUtil.startWithStr(gas_limit).multiplyStr(gas_price).toString();
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
                              ID.WalletTransferDetail.tr,
                              style: AppTheme.text18(),
                            ),
                          ),
                          Container(
                            padding: SizeUtil.padding(top: 15,bottom: 15),
                            child: widget.nft != null ? createInfo() : Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(widget.amount,style: AppTheme.text20(),),
                                Container(
                                  padding: SizeUtil.padding(left: 3,bottom: 2),
                                  child: Text(widget.coin,style: AppTheme.text14(),),
                                )
                              ],
                            ),
                          ),

                          _buildItem(ID.WalletTransferInfo.tr, right:"${widget.coin} ${ID.WalletTransfer.tr}"),
                          widget.contractAddress.isEmptyString() ? SizedBox(width: 0,height: 0,) : _buildItem(ID.WalletTransferContractAddress.tr, right:widget.contractAddress),
                          _buildItem(ID.WalletTransferReceiveAddress.tr, right:widget.to),
                          _buildItem(ID.WalletTransferPayAddress.tr, right:widget.from),
                          widget.contract.toUpperCase() == "TRX" ? _buildItem(ID.WalletTransferGas.tr, right:widget.fee!.fee! + widget.contract) :
                          _buildItem(ID.WalletTransferGas.tr, rightWidget: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Text(
                                    "${gas}${widget.contract}",
                                    style: AppTheme.text14(),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Container(
                                  padding: SizeUtil.padding(top: 0, bottom: 0),
                                  child: Text(
                                    "=Gas Price(${gas_price_str}GWEI) * Gas(${gas_limit})",
                                    style: AppTheme.text12(),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                          )),
                          Container(
                            margin: SizeUtil.margin(bottom: 30,left: 15,right: 15,top: 15),
                            width: SizeUtil.screenWidth(),
                            child: CustomWidget.buildButtonImage(() {
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

  Widget createInfo() {
    return Container(
      margin: EdgeInsets.only(left: SizeUtil.width(20), right: SizeUtil.width(20)),
      padding: EdgeInsets.all(SizeUtil.width(14)),
      height: SizeUtil.width(124),
      decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: new BorderRadius.circular(SizeUtil.width(6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ID.WalletTransferNftTip.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.text14(),
          ),
          SizedBox(height: SizeUtil.width(12),),
          Row(
            children: [
              Container(
                  width: SizeUtil.width(60),
                  height: SizeUtil.width(60),
                  child: CustomWidget.buildNetworkImage(context, widget.nft != null && widget.nft!.img != null ? widget.nft!.img! : "", SizeUtil.width(60), SizeUtil.width(60), SizeUtil.width(6))
              ),
              SizedBox(width: SizeUtil.width(12),),
              Container(
                width: SizeUtil.screenW - SizeUtil.width(140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.nft != null && widget.nft!.name != null ? widget.nft!.name! : "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.text12(),
                    ),
                    Row(
                      children: [
                        Container(
                            width: SizeUtil.width(24),
                            height: SizeUtil.width(24),
                            child: CustomWidget.buildNetworkImage(context, widget.nft != null && widget.nft!.icon != null ? widget.nft!.icon! : "", SizeUtil.width(24), SizeUtil.width(24), SizeUtil.width(3))
                        ),
                        SizedBox(width: SizeUtil.width(6),),
                        Text(
                          widget.nft != null && widget.nft!.chainName != null ? widget.nft!.chainName! : "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.text12(),
                        ),
                        SizedBox(width: SizeUtil.width(6),),
                        Container(
                          color: ZColors.ZFFCCCCCC,
                          width: 0.5,
                          height: SizeUtil.width(12),
                        ),
                        SizedBox(width: SizeUtil.width(6),),
                        Text(
                          ID.WalletTransferNftTokenid.tr + (widget.nft != null && widget.nft!.tokenID != null ? widget.nft!.tokenID! : ""),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.text12(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItem(left,{right,rightWidget}){
    return Container(
      padding: SizeUtil.padding(left: 15,right: 15),
      child: Column(
        children: [
          Container(
            padding: SizeUtil.padding(top: 5,bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:SizeUtil.padding(right: 15,left: 0,bottom: 0),
                  child: Text(left,style: AppTheme.text16(),),
                ),
                Expanded(child: rightWidget??Container(
                  child: Text(right,style: AppTheme.text14(),),
                ))

              ],
            ),
          ),
          Divider()
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}