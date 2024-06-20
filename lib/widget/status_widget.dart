import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StatusWidget extends StatelessWidget {

  final int status;
  final GestureTapCallback? onTap;
  final Color? color;

  StatusWidget(this.status,{this.onTap,this.color});

  @override
  Widget build(BuildContext context) {
    switch(status) {
      case LoadStatus.networkFailure:
        return new Container(
          width: double.infinity,
          child: new Material(
            color: color ?? Colors.transparent,
            child: new InkWell(
              onTap: () {
                if(onTap != null) {
                  onTap!();
                }
              },
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 100,
                  ),
                  Image.asset(
                    Constant.Assets_Images + "error_network.png",
                    width: 85,
                    height: 85,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    ID.CommonErrorNetwork.tr,
                    textAlign: TextAlign.center,
                    style:  TextStyle(
                      fontSize: 12,
                    ),
                  ),

                ],
              ),
            ),
          ),
        );
        break;
      case LoadStatus.apiFailure:
        return new Container(
          width: double.infinity,
          child: new Material(
            color: color ?? Colors.transparent,
            child: new InkWell(
              onTap: () {
                if(onTap != null) {
                  onTap!();
                }
              },
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 100,
                  ),
                  Image.asset(
                    Constant.Assets_Images + "error_system.png",
                    width: 85,
                    height: 85,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  new Text(
                    ID.CommonErrorSystem.tr,
                    textAlign: TextAlign.center,
                    style:  TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        break;
      case LoadStatus.loading:
        return new Container(
          alignment: Alignment.center,
          child: CustomWidget.simplePageLoading(context),
        );
        break;
      case LoadStatus.empty:
        return new Container(
          color: color ?? Colors.transparent,
          width: double.infinity,
          child: new InkWell(
            onTap: () {
              if(onTap != null) {
                onTap!();
              }
            },
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 100,
                ),
                Image.asset(
                  Constant.Assets_Images + "error_empty.png",
                  width: 107,
                  height: 82,
                ),
                SizedBox(
                  height: 30,
                ),
                new Text(
                  ID.CommonErrorEmpty.tr,
                  textAlign: TextAlign.center,
                  style:  TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
        break;
      default:
        return Container();
        break;
    }
  }
}