import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/callback.dart';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';

class CustomWidget {

  static Widget buildTextArea(label,controller,{bool showClear = false,StringCallback? callback}) {
    return Container(
      color: ZColors.ZFFFFFFFFTheme1(Get.context!),
        width: SizeUtil.screenWidth(),
        constraints: BoxConstraints(
            maxHeight: SizeUtil.height(120),
            minHeight: SizeUtil.height(70),
            maxWidth: SizeUtil.screenWidth(),
        ),
        child: buildInput(label, controller,onChanged: (str) {
          if (str.isEmptyString() && showClear) {
              showClear = false;
          } else if (str.isNotEmptyString() && !showClear) {
              showClear = true;
          }
          if (callback != null) {
            callback(str);
          }
        }, suffixIcon: showClear ? IconButton(
          icon: Icon(Icons.close, color: ZColors.ZFF2D4067Theme(Get.context!),),
          onPressed: () {
            controller.clear();
            showClear = false;
          },
        ) : Container(width: 0, height: 0,),
            keyboardType:TextInputType.multiline,
            maxLines:null,justInput: true
        ),
    );
  }

  static Widget buildTextArea1(label,controller,{StringCallback? callback,Widget? suffixIcon }) {
    return Container(
      color: ZColors.ZFFFFFFFFTheme1(Get.context!),
      width: double.infinity,
      constraints: BoxConstraints(
          maxHeight: SizeUtil.height(120),
          minHeight: SizeUtil.height(70),
          maxWidth: double.infinity),
      child:buildInput(label, controller, inputFormatters: FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z ]')),onChanged: (str){
        if (callback != null) {
          callback(str);
        }
      },suffixIcon:suffixIcon,
          keyboardType:TextInputType.multiline,
          maxLines:null,justInput: true
      ),
    );
  }

  static Widget buildTextArea2(label,controller,{StringCallback? callback,Widget? suffixIcon }) {
    return Container(
      color: ZColors.ZFFFFFFFFTheme1(Get.context!),
        width: double.infinity,
        constraints: BoxConstraints(
            maxHeight: SizeUtil.height(120),
            minHeight: SizeUtil.height(70),
            maxWidth: double.infinity),
        child:buildInput(label, controller, inputFormatters: FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),onChanged: (str){
          if (callback != null) {
            callback(str);
          }
        },suffixIcon:suffixIcon,
            keyboardType:TextInputType.multiline,
            maxLines:null,justInput: true
        ),
    );
  }

  static Widget buildTextArea3(label,controller,{StringCallback? callback,Widget? suffixIcon }) {
    return Container(
      color: ZColors.ZFFFFFFFFTheme1(Get.context!),
        width: SizeUtil.screenWidth(),
        constraints: BoxConstraints(
            maxHeight: SizeUtil.height(120),
            minHeight: SizeUtil.height(70),
            maxWidth: SizeUtil.screenWidth()),
        child:buildInput(label, controller,onChanged: (str) {
          if (callback != null) {
            callback(str);
          }
        },suffixIcon:suffixIcon,
            keyboardType:TextInputType.multiline,
            maxLines:null,justInput: true
        ),
    );
  }

  static Widget buildCard(Widget child, {padding, margin}) {
    return Card(
      color: ZColors.ZFFFFFFFFTheme1(Get.context!),
      elevation: 0,
      margin: margin ?? SizeUtil.margin(left: 12, right: 12, top: 7, bottom: 7),
      child: Container(
        padding: padding ?? SizeUtil.padding(all: 10),
        width: SizeUtil.screenWidth(),
        child: child,
      ),
    );
  }

  static Widget buildCardMargin0(Widget child, {padding, margin}) {
    return Card(
      color: ZColors.ZFFFFFFFFTheme1(Get.context!),
      elevation: 0,
      child: Container(
        padding: padding ?? SizeUtil.padding(all: 10),
        width: SizeUtil.screenWidth(),
        child: child,
      ),
    );
  }

  static Widget buildInput(label,controller,
      {TextInputFormatter? inputFormatters,
        TextStyle? style,
        TextInputType? keyboardType,
        bool obscureText = false,
        Function? onChanged,
        suffixIcon,maxLines=1,
        bool justInput=false,
        maxLength=TextField.noMaxLength,
        VoidCallback? onTap
      }) {
    Widget input = TextField(
      autofocus: false,
      decoration: InputDecoration(
          border: InputBorder.none,
          fillColor: Colors.transparent,
          filled: false,
          labelText: label,
          labelStyle: AppTheme.text16(),
          counterText: "",
          suffixIcon:suffixIcon!=null?suffixIcon:Container(width: 0,height: 0,)
      ),
      style: style != null ? style : AppTheme.text16(),
      inputFormatters: inputFormatters != null ? [inputFormatters] : [],
      keyboardType: keyboardType != null ? keyboardType : TextInputType.text,
      obscureText: obscureText,
      textAlign: TextAlign.left,
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,

      onTap: (){
        if(onTap!=null){onTap();}
      },
      onChanged: (str){
        if (onChanged != null) {
          onChanged(str);
        }
      },
    );
    if(justInput){
      return input;
    }
    return Container(
      child: input,
    );
  }

  static Widget buildInputName(label,controller,
      {TextInputFormatter? inputFormatters,
        TextStyle? style,
        TextInputType? keyboardType,
        bool obscureText = false,
        Function? onChanged,
        suffixIcon,maxLines=1,
        bool justInput=false,
        maxLength=TextField.noMaxLength,
        VoidCallback? onTap
      }) {
    Widget input = TextField(
      autofocus: false,
      decoration: InputDecoration(
          border: InputBorder.none,
          fillColor: Colors.transparent,
          filled: false,
          labelText: label,
          labelStyle: AppTheme.text16(),
          counterText: "",
          suffixIcon:suffixIcon!=null?suffixIcon:Container(width: 0,height: 0,)
      ),
      style: style != null ? style : AppTheme.text16(),
      inputFormatters: [
        LengthLimitingTextInputFormatter(20)
      ],
      keyboardType: keyboardType != null ? keyboardType : TextInputType.text,
      obscureText: obscureText,
      textAlign: TextAlign.left,
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,

      onTap: (){
        if(onTap!=null){onTap();}
      },
      onChanged: (str){
        if (onChanged != null) {
          onChanged(str);
        }
      },
    );
    if(justInput){
      return input;
    }
    return Container(
      child: input,
    );
  }

  static Widget buildInputAddress(label,controller,
      {TextInputFormatter? inputFormatters,
        TextStyle? style,
        TextInputType? keyboardType,
        bool obscureText = false,
        Function? onChanged,
        suffixIcon,maxLines=1,
        bool justInput=false,
        maxLength=TextField.noMaxLength,
        VoidCallback? onTap
      }) {
    Widget input = TextField(
      autofocus: false,
      decoration: InputDecoration(
          border: InputBorder.none,
          fillColor: Colors.transparent,
          filled: false,
          labelText: label,
          labelStyle: AppTheme.text16(),
          counterText: "",
      ),
      style: style != null ? style : AppTheme.text16(),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z]'))
      ],
      keyboardType: keyboardType != null ? keyboardType : TextInputType.text,
      obscureText: obscureText,
      textAlign: TextAlign.left,
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,

      onTap: (){
        if(onTap!=null){onTap();}
      },
      onChanged: (str){
        if (onChanged != null) {
          onChanged(str);
        }
      },
    );
    if(justInput){
      return input;
    }
    return Container(
      child: input,
    );
  }

  static Widget buildPassword(label,controller,{VoidCallback? clicker}) {
    return buildInput(label, controller,
        obscureText: true,
        keyboardType:TextInputType.number,
        maxLength: 6,
        onTap: clicker,
        inputFormatters: FilteringTextInputFormatter.allow(RegExp(r'[0-9]')));
  }

  static Widget buildButton(VoidCallback onTap,{color,text}) {
    return Container(
      margin: SizeUtil.margin(top: 20),
      child: MaterialButton(
        onPressed: onTap,
        color: color ?? ZColors.ZFFEECC5B,
        minWidth: SizeUtil.width(300),
        height: SizeUtil.width(45),
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: SizeUtil.radius(all: 6),
        ),
        child: Text(
          '${text}',
          style: AppTheme.text16(color: ZColors.ZFFFFFFFF, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static Widget buildButtonImage(VoidCallback onTap,{color,text}) {
    return Container(
      margin: SizeUtil.margin(top: 20),
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(Constant.Assets_Images + "common_button_back.png"),
              fit: BoxFit.fill
          )
      ),
      child: MaterialButton(
        onPressed: onTap,
        minWidth: SizeUtil.width(300),
        height: SizeUtil.width(45),
        child: Text(
          '${text}',
          style: AppTheme.text16(color: ZColors.ZFFFFFFFF, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static Widget buildCardX(Widget child) {
    return Card(
      elevation: 0,
      margin: SizeUtil.margin(left: 15, right: 15, top: 7, bottom: 7),
      child: Container(
        color: ZColors.KFFFFFFFFTheme1(Get.context!),
        padding: SizeUtil.padding(left: 10, right: 10),
        width: SizeUtil.screenWidth(),
        child: child,
      ),
    );
  }

  static Widget buildRefresh(Widget child, EasyRefreshController controller, Widget? emptyWidget, refreshCallback,
      {noMore: true, loadCallback}) {
    var refreshView = EasyRefresh(
      controller: controller,
      child: child,
      header: MaterialHeader(),
      emptyWidget: emptyWidget,
      onRefresh: () async {
        await refreshCallback();
        controller.finishRefresh(success: true);
      },
      onLoad: loadCallback != null ? () async {
        await loadCallback();
        controller.finishLoad(success: true, noMore: noMore);
      } : null,
    );
    return refreshView;
  }

  static Widget simplePageLoading(BuildContext context) {
    return new Center(
      child: new SizedBox(
        width: 24.0,
        height: 24.0,
        child: new CircularProgressIndicator(
          strokeWidth: 2.0,
        ),
      ),
    );
  }

  static Widget buildPoint(BuildContext context,{Color color = Colors.red, double size = 10, }) {
    return Container(
      decoration: new BoxDecoration(
          color: color,
          borderRadius: BorderRadius.all(Radius.circular(size)),
          border: new Border.all(width: 1, color:color),
      ),
      height: size,
      width: size,
    );
  }

  static Widget buildNetworkImage(BuildContext context, String url, double width, double height, double radius, {String placeholder = "common_placeholder.png"}) {
    return CachedNetworkImage(
      width: width,
      height: height,
      imageUrl: url,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover
          ),
        ),
      ),
      placeholder: (context, url) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          image: DecorationImage(
              image: AssetImage(
                Constant.Assets_Images + placeholder,
              ),
              fit: BoxFit.cover
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          image: DecorationImage(
              image: AssetImage(
                Constant.Assets_Images + placeholder,
              ),
              fit: BoxFit.cover
          ),
        ),
      ),
    );
  }

}