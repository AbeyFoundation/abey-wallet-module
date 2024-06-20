import 'package:abey_wallet/common/app_theme.dart';
import 'package:abey_wallet/common/callback.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:abey_wallet/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class InputDialogWidget extends StatefulWidget {
  final String? title;
  final String? text;
  final StringCallback? callback;

  const InputDialogWidget({Key? key, this.title, this.text, this.callback}) : super(key: key);

  @override
  InputDialogWidgetState createState() => InputDialogWidgetState();
}

class InputDialogController extends GetxController {
  var text = "".obs;

  increment(text) => this.text.value = text;
}

class InputDialogWidgetState extends State<InputDialogWidget> {
  TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: IntrinsicHeight(
        child: Container(
          margin: EdgeInsets.only(left: SizeUtil.width(15), right: SizeUtil.width(15)),
          child: Column(
            children: [
              Spacer(),
              Container(
                padding: SizeUtil.padding(left: 0, right: 0, bottom: 10, top: 10),
                width: SizeUtil.screenWidth(),
                decoration: BoxDecoration(
                  color: ZColors.ZFFFAFAFATheme(context),
                  borderRadius: BorderRadius.all(Radius.circular(6.0)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.title != null ? Container(
                      width: SizeUtil.screenWidth(),
                      padding: SizeUtil.padding(top: 10, left: 20, right: 20, bottom: 10),
                      child: Text(
                        widget.title!,
                        textAlign: TextAlign.left,
                        style: AppTheme.text16(),
                      ),
                    ) : SizedBox(
                      height: 0,
                    ),
                    Container(
                      padding: SizeUtil.padding(left: 20, right: 20),
                      child: _buildInput(widget.text, _textController, onChanged: (value) {}),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20,right: 20, bottom: 10),
                      child: CustomWidget.buildButtonImage(() {
                        if (widget.callback != null) {
                          widget.callback!(_textController.text);
                        }
                        Get.back();
                      },text: ID.CommonConfirm.tr),
                    ),
                  ],
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    label,
    controller, {
    TextInputFormatter? inputFormatters,
    TextStyle? style,
    TextInputType? keyboardType,
    bool obscureText = false,
    Function? onChanged,
    suffixIcon,
    maxLines = 1,
    bool justInput = false,
  }) {
    Widget input = TextField(
      decoration: InputDecoration(
        fillColor: Colors.transparent,
        filled: false,
        hintText: label,
        suffixIcon: suffixIcon != null
            ? suffixIcon
            : Container(width: 0, height: 0,),
      ),
      style: style != null ? style : AppTheme.text16(),
      inputFormatters: inputFormatters != null ? [inputFormatters] : [],
      keyboardType: keyboardType != null ? keyboardType : TextInputType.text,
      obscureText: obscureText,
      textAlign: TextAlign.left,
      controller: controller,
      maxLines: maxLines,

      onChanged: (str) {
        if (onChanged != null) {
          onChanged(str);
        }
      },
    );
    if (justInput) {
      return input;
    }
    return Container(
      child: input,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
