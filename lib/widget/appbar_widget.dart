import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppbarWidget {
  static Widget appBar(BuildContext context, {Color? backColor,String? title,bool isBack = false,IconData? iconData,IconButton? iconButton,VoidCallback? callback,Widget? widget}) {
    return SizedBox(
      height: AppBar().preferredSize.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 8),
            child: Container(
              width: AppBar().preferredSize.height - 8,
              height: AppBar().preferredSize.height - 8,
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  title != null ? title : "",
                  style: TextStyle(
                    fontSize: 18,
                    color: ZColors.KFF033B19Theme(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 8),
            child: Container(
              width: AppBar().preferredSize.height - 8,
              height: AppBar().preferredSize.height - 8,
              // color: Colors.white,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius:
                  BorderRadius.circular(AppBar().preferredSize.height),
                  child: Icon(
                    iconData,
                    color: ZColors.KFF111827Theme(context),
                  ),
                  onTap: () {
                    if (callback != null) {
                      callback();
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget appBarBack(BuildContext context, {Color? backColor,String? title,bool isBack = false,IconData? iconData,IconButton? iconButton,VoidCallback? callback,Widget? widget, bool? showProgress}) {
    return SizedBox(
      height: AppBar().preferredSize.height,
      child: Row(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            width: AppBar().preferredSize.height + 40,
            height: AppBar().preferredSize.height,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: const BorderRadius.all(
                  Radius.circular(32.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.arrow_back, color: ZColors.KFF111827Theme(context),),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                title != null ? title : "",
                style: TextStyle(
                  fontSize: 18,
                  color: ZColors.KFF033B19Theme(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Container(
            width: AppBar().preferredSize.height + 40,
            height: AppBar().preferredSize.height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(32.0),
                    ),
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(iconData, color: ZColors.KFF111827Theme(context),),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(32.0),
                    ),
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(iconData, color: ZColors.KFF111827Theme(context),),
                    ),
                  ),
                ),
              ],
            ),
          ),
          showProgress == true ? PreferredSize(
            preferredSize: Size(SizeUtil.screenWidth(), SizeUtil.height(2)),
            child: SizedBox(
              child: LinearProgressIndicator(),
              height: SizeUtil.height(2),
              width: SizeUtil.screenWidth(),
            ),
          ) : PreferredSize(
            preferredSize: Size(
              SizeUtil.screenWidth(),
              0,
            ),
            child: SizedBox(
              height: 0,
            ),
          ),
        ],
      ),
    );
  }

  static AppBar initAppBar(BuildContext context,{Color? backColor,String? title,Widget? titleWidget,bool isBack = false,IconButton? iconButton,VoidCallback? callback,Widget? widget}) {
    return AppBar(
      backgroundColor: backColor == null ? ZColors.KFFFFFFFFTheme(context) : backColor,
      elevation: 0,
      title: titleWidget != null ? titleWidget : Text(
        title != null ? title : "",
        style: AppTheme.text18(color: ZColors.KFF033B19Theme(context)),
      ),
      centerTitle: true,
      leading: isBack ? CupertinoButton(
        onPressed: () {
          if (callback == null) {
            FocusScope.of(context).requestFocus(FocusNode());
            Navigator.pop(context);
          } else {
            callback();
          }
        },
        child: Container(
          width: 44,
          height: 44,
          child: Icon(Icons.arrow_back,color: ZColors.KFF111827Theme(context),),
        ),
      ) : null,
      actions: <Widget>[
        widget != null ? widget : Container(),
      ],
    );
  }

  static AppBar initAppBarWhite(BuildContext context,{Color? backColor,String? title,bool isBack = false,IconButton? iconButton,VoidCallback? callback,Widget? widget}) {
    return AppBar(
      backgroundColor: backColor == null ? ZColors.KFFFFFFFFTheme(context) : backColor,
      elevation: 0,
      title: Text(
        title != null ? title : "",
        style: AppTheme.text18(color: ZColors.ZFFFFFFFF),
      ),
      centerTitle: true,
      leading: isBack ? CupertinoButton(
        onPressed: () {
          if (callback == null) {
            FocusScope.of(context).requestFocus(FocusNode());
            Navigator.pop(context);
          } else {
            callback();
          }
        },
        child: Container(
          width: 44,
          height: 44,
          child: Icon(Icons.arrow_back,color: ZColors.ZFFFFFFFF,),
        ),
      ) : Container(),
      actions: <Widget>[
        widget != null ? widget : Container(),
      ],
    );
  }

  static AppBar initAppContainBar(BuildContext context,{Color? backColor,String? title, VoidCallback? callback, Widget? widget}) {
    return AppBar(
      backgroundColor: backColor == null ? ZColors.KFFFFFFFFTheme(context) : backColor,
      elevation: 0,
      title: Text(
        title != null ? title : "",
        style: AppTheme.text18(color: ZColors.KFF033B19Theme(context)),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.dashboard,
          color: ZColors.ZFF2D4067Theme(context),
        ),
        onPressed: () {
          if (callback != null) {
            callback();
          }
        },
      ),
      actions: <Widget>[
        widget != null ? widget : Container(),
      ],
    );
  }
}