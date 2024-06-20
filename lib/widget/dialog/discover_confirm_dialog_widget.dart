import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/callback.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/model/coin_model.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/service/api_data.dart';
import 'package:abey_wallet/service/api_manager.dart';
import 'package:abey_wallet/utils/console_util.dart';
import 'package:abey_wallet/utils/math_util.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:abey_wallet/widget/dialog/fee_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:get/get.dart';

class DiscoverConfirmDialogWidget extends StatefulWidget {
  final String? icon;
  final String? name;
  final String? chain;
  final String? coin;
  final MapCallback? callback;
  final Callback? noneback;
  final WalletFeeListModel? fees;
  final Map<String,dynamic>? data;
  final CoinModel? nftModel;

  const DiscoverConfirmDialogWidget(
      {Key? key, this.fees,this.icon, this.name,this.coin, this.chain, this.callback,this.noneback,this.data,this.nftModel})
      : super(key: key);

  @override
  DiscoverConfirmDialogWidgetState createState() => DiscoverConfirmDialogWidgetState();
}

class DiscoverConfirmDialogWidgetState extends State<DiscoverConfirmDialogWidget> {
  Map<String,dynamic> _data = {};
  String gwei = '1000000000';

  List<WalletFeeModel>? walletFeeModelList;
  String gas_price='0.0000';
  String gas_limit='21000';


  @override
  void initState() {
    super.initState();
    _data = widget.data!;
    ConsoleUtil.i(_data);
    if (_data == null) {
      _data = {};
    }
    if (widget.fees != null) {
      walletFeeModelList = widget.fees!.items;
      walletFeeModelList!.forEach((element) {
        if (element.type == "general") {
          if (mounted) {
            setState(() {
              gas_price = element.gas_price!;
              gas_limit = element.gas_limit!;
            });
          }
        }
      });
    } else {
      requestFees();
    }
  }

  void requestFees() async {
    if (_data['from'].isEmptyString()) {
      return;
    }
    ApiData apiData = await ApiManager.postWalletFees(data:{
      "symbol": widget.chain,
      "address": _data['from'],
      "contract": _data['contract'],
      "contractAddress": _data['contractAddress']
    });
    if (apiData.code == 0) {
      WalletFeeListModel walletFeeListModel = WalletFeeListModel.fromJson(apiData.data);
      if (walletFeeListModel != null) {
        walletFeeModelList = walletFeeListModel.items;
        walletFeeListModel.items!.forEach((element) {
          if (element.type == "general") {
            if (mounted) {
              setState(() {
                gas_price = element.gas_price!;
                gas_limit = element.gas_limit!;
              });
            }
          }
        });
        this.walletFeeModelList = walletFeeListModel.items;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String desc = widget.name!;

    return GestureDetector(
        child: IntrinsicHeight(
          child: Stack(
            children: [
              Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: SizeUtil.padding(left: 0, right: 0, bottom: 40, top: 10),
                    width: SizeUtil.screenWidth(),
                    decoration: BoxDecoration(
                        color: ZColors.ZFFFAFAFATheme(context),
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: SizeUtil.width(40),),
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  ID.WalletTransferInfo.tr,
                                  style: AppTheme.text16(),
                                ),
                              ),
                            ),
                            Container(
                              width: SizeUtil.width(40),
                              child: IconButton(
                                icon: Icon(Icons.close,color: ZColors.ZFF2D4067Theme(context),),
                                onPressed: () {
                                  if(widget.noneback!=null){
                                    widget.noneback!();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: SizeUtil.screenWidth(),
                          margin: SizeUtil.margin(all: 14, right: 14),
                          padding: SizeUtil.padding(all: 10),
                          decoration: BoxDecoration(
                              color: ZColors.ZFFFFFFFFTheme1(context),
                              borderRadius: BorderRadius.all(Radius.circular(6.0)),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: SizeUtil.width(60),
                                height: SizeUtil.width(60),
                                padding: SizeUtil.padding(all: 5),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: ZColors.ZFFF5F5F5),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(6.0)),
                                ),
                                child: CustomWidget.buildNetworkImage(context, widget.icon!, SizeUtil.width(50), SizeUtil.width(50), SizeUtil.width(6))
                              ),
                              Container(
                                padding:
                                SizeUtil.padding(left: 10, right: 10, top: 10),
                                child: Text(
                                  desc,
                                  style: AppTheme.text14(),
                                ),
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${_data['value']}',style: AppTheme.text14(),),
                                    Text('${widget.coin}',style: AppTheme.text14(),),
                                  ],
                                ),
                              ),
                              _buildInfoCard()
                            ],
                          ),
                        ),
                        Container(
                          margin: SizeUtil.padding(left: 20,right: 20),
                          width: SizeUtil.screenWidth() - SizeUtil.width(40),
                          child: CustomWidget.buildButtonImage(() {
                            if(widget.callback!=null){
                              widget.callback!({"gas_price":gas_price,"gas_limit":gas_limit});
                            }
                          },text: ID.CommonConfirm.tr),
                        ),
                      ],
                    ),
                  ),
              )
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
                child: CustomWidget.buildNetworkImage(context, widget.nftModel != null && widget.nftModel!.img != null ? widget.nftModel!.img! : "", SizeUtil.width(60), SizeUtil.width(60), SizeUtil.width(6))
              ),
              SizedBox(width: SizeUtil.width(12),),
              Container(
                width: SizeUtil.screenW - SizeUtil.width(140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.nftModel != null && widget.nftModel!.name != null ? widget.nftModel!.name! : "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.text12(),
                    ),
                    Row(
                      children: [
                        Container(
                          width: SizeUtil.width(24),
                          height: SizeUtil.width(24),
                          child: CustomWidget.buildNetworkImage(context, widget.nftModel != null && widget.nftModel!.icon != null ? widget.nftModel!.icon! : "", SizeUtil.width(24), SizeUtil.width(24), SizeUtil.width(3))
                        ),
                        SizedBox(width: SizeUtil.width(6),),
                        Text(
                          widget.nftModel != null && widget.nftModel!.chainName != null ? widget.nftModel!.chainName! : "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.text12(),
                        ),
                        SizedBox(width: SizeUtil.width(6),),
                        Container(
                          color: ZColors.ZFFA2A6B0,
                          width: 0.5,
                          height: SizeUtil.width(12),
                        ),
                        SizedBox(width: SizeUtil.width(6),),
                        Text(
                          ID.WalletTransferNftTokenid.tr + (widget.nftModel != null && widget.nftModel!.tokenID != null ? widget.nftModel!.tokenID! : ""),
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

  Widget _buildInfoCard(){
    String gas = MathUtil.startWithStr(gas_limit).multiplyStr(gas_price).toString();
    String gwel = MathUtil.startWithStr(gas_price).multiplyStr(gwei).toString();

    return Column(
      children: [
        Container(
          padding: SizeUtil.padding(top: 10,bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${ID.WalletTransferReceiveAddress.tr}:',style: AppTheme.text14(),),
              Expanded(child:Padding(
                padding: SizeUtil.padding(left: 20,top: 2),
                child:  Text('${_data['to']}',
                  style: AppTheme.text14(),
                  textAlign: TextAlign.right,
                ),
              ))
            ],
          ),
        ),
        Container(
          padding: SizeUtil.padding(top: 10,bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${ID.WalletTransferPayAddress.tr}:',style: AppTheme.text14(),),
              Expanded(child:Padding(
                padding: SizeUtil.padding(left: 20,top: 2),
                child:  Text('${_data['from']}',
                  style: AppTheme.text14(),
                  textAlign: TextAlign.right,),
              ))
            ],
          ),
        ),
        InkWell(
          onTap: (){
            _goFee();
          },
          child: Container(
            padding: SizeUtil.padding(top: 10,bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${ID.WalletTransferGas.tr}:',style: AppTheme.text14(),),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${gas}',style: AppTheme.text14(),),
                    Text('Gas Price(${gwel}GWEI) * Gas(${gas_limit})',style: AppTheme.text12(),)
                  ],
                ),
                Container(
                  margin: SizeUtil.margin(left: 10,top: 4),
                  child: Icon(Icons.arrow_forward_ios,size: SizeUtil.width(14),color: ZColors.ZFF2D4067Theme(context),),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  _goFee()async {
    await showDialog(
        useSafeArea:false,
        context: context, builder: (context){
      return FeeDialogWidget(data: walletFeeModelList!,contract: widget.chain!, callback: (value) {
        setState(() {
          gas_price = value['gas_price'];
          gas_limit = value['gas_limit'];
          Get.back();
        });
      },);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}