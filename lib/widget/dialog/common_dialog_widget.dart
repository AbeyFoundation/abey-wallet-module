import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:flutter/material.dart';

class CommonDialogWidget extends StatefulWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;

  const CommonDialogWidget({Key? key, this.child, this.padding}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CommonDialogWidgetState();
  }
}

class CommonDialogWidgetState extends State<CommonDialogWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: createContent(),
    );
  }

  Widget createContent() {
    return GestureDetector(
      child: IntrinsicHeight(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: widget.padding ?? SizeUtil.padding(left: 0, right: 0, bottom: 40, top: 20),
                width: SizeUtil.screenWidth(),
                decoration: BoxDecoration(
                  color: ZColors.KFFFFFFFFTheme(context),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6.0),
                    topRight: Radius.circular(6.0),
                  ),
                ),
                child: widget.child ?? Container(),
              ),
            ),
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
