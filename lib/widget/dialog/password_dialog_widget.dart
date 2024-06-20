import 'dart:math';

import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/callback.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasswordDialogWidget extends StatefulWidget {
  final StringCallback? callback;
  final bool step;

  const PasswordDialogWidget({Key? key, this.callback, this.step = false}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PasswordDialogWidgetState();
  }
}

class PasswordDialogController extends GetxController {
  var point = "⦾ ⦾ ⦾ ⦾ ⦾ ⦾".obs;
  var pointSize = 0.obs;

  changePoint(size) {
    pointSize.value = size;
  }
}

class PasswordDialogWidgetState extends State<PasswordDialogWidget> {
  List<Widget>? passGroups;
  List<String> _numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  String _values = '';
  PasswordDialogController _passwordDialogController = Get.put(PasswordDialogController());

  @override
  void initState() {
    super.initState();
    _passwordDialogController.changePoint(0);
  }

  String _popnum() {
    if (_numbers.length == 0) {
      _numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    }
    if (_numbers.length == 1) {
      String value = _numbers[0];
      _numbers = [];
      return value;
    }
    var index = Random().nextInt(_numbers.length);
    String value = _numbers[index];
    _numbers.removeAt(index);
    return value;
  }

  void _callback() {
    if (_values.length == 6) {

    }
  }

  @override
  Widget build(BuildContext context) {
    if (passGroups == null || passGroups!.length == 0) {
      passGroups = _createPassGroups();
    }
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
        child: IntrinsicHeight(
          child: Stack(
            children: [
              Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: SizeUtil.padding(left: 0, right: 0, bottom: 0, top: 0),
                    width: SizeUtil.screenWidth(),
                    decoration: BoxDecoration(
                        color: ZColors.ZFFFAFAFATheme(context),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6.0),
                            topRight: Radius.circular(6.0),
                        ),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                padding: SizeUtil.padding(top: 10),
                                child: Text(
                                  ID.WalletCreatePsd.tr,
                                  style: AppTheme.text18(),
                                ),
                            ),
                            Container(
                                width: SizeUtil.screenWidth(),
                                child: Stack(
                                  children: [
                                    Container(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: SizeUtil.screenWidth(),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  margin: SizeUtil.margin(top: 10, bottom: 10),
                                                  alignment: Alignment.center,
                                                  width:double.infinity,
                                                  padding: SizeUtil.padding(top: 5, bottom: 5),
                                                  child: Obx(() {
                                                    List<Widget> items=[];
                                                    int size = _passwordDialogController.pointSize.value;
                                                    for (int i = 1; i <=6; i++) {
                                                      items.add(
                                                          Container(
                                                            margin: SizeUtil.margin(left: 5,right: 5),
                                                            child: Icon(i<=size?Icons.radio_button_checked:Icons.radio_button_off_outlined,color: ZColors.ZFF000000Theme(context),size: SizeUtil.width(12),),
                                                          )
                                                      );

                                                    }
                                                    return Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: items,
                                                    );
                                                  }),
                                                )
                                              ],
                                            ),
                                          ),
                                          passGroups![0],
                                          passGroups![1],
                                          passGroups![2],
                                          passGroups![3],
                                          Container(
                                            height: SizeUtil.height(30),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        ));
  }

  List<Widget> _createPassGroups() {
    List<Widget> group1 = [];
    List<Widget> group2 = [];
    List<Widget> group3 = [];
    List<Widget> group4 = [];
    for (int i = 0; i < 10; i++) {
      String popnum = _popnum();
      Widget button = _createPassButton(popnum);
      if (i < 3) {
        group1.add(button);
      } else if (i < 6) {
        group2.add(button);
      } else if (i < 9) {
        group3.add(button);
      } else {
        group4.add(button);
      }
    }
    group4 = [_createPassButton('clean')]
      ..addAll(group4)
      ..add(_createPassButton('del'));
    return [
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: group1,
        ),
      ),
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: group2,
        ),
      ),
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: group3,
        ),
      ),
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: group4,
        ),
      ),
    ];
  }

  Widget _createPassButton(numstr) {
    double width = (SizeUtil.screenWidth() - SizeUtil.width(60)) / 3;
    return Container(
      margin: SizeUtil.margin(left: 1.5, right: 1.5, bottom: 0.5, top: 0.5),
      child: numstr == 'temp' ? Container(
        height: SizeUtil.height(30),
        width: width,
      ) : Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (numstr == 'del') {
              if (_values.length > 0) {
                _values = _values.substring(0, _values.length - 1);
                _passwordDialogController.changePoint(_values.length);
                if (widget.step && widget.callback != null) {
                  widget.callback!(_values);
                }
              }
              return;
            }
            if (numstr == 'clean') {
              _values = "";
              _passwordDialogController.changePoint(0);
              if (widget.step && widget.callback != null) {
                widget.callback!(_values);
              }
              return;
            }
            if (_values.length == 6) {
              if (widget.callback != null) {
                widget.callback!(_values);
              }
              return;
            }
            _values = '$_values$numstr';
            _passwordDialogController.changePoint(_values.length);
            if (widget.callback != null) {
              if (widget.step) {
                widget.callback!(_values);
              } else if (_values.length == 6) {
                if (widget.callback != null) {
                  widget.callback!(_values);
                }
              }
            }
          },
          child: Container(
            alignment: Alignment.center,
            padding: SizeUtil.padding(top: 15,bottom: 15),
            width: width,
            child: numstr == 'del'
                ? Icon(Icons.backspace_outlined, color: ZColors.ZFF2D4067Theme(context),)
                : Text(
              "$numstr".tr,
              style: AppTheme.text16(),
            ),
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
