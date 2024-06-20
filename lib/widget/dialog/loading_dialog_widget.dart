import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/utils/size_util.dart';
import 'package:flutter/material.dart';

class LoadingDialogWidget extends StatefulWidget {
  const LoadingDialogWidget({Key? key}) : super(key: key);

  @override
  LoadingDialogWidgetState createState() => LoadingDialogWidgetState();
}

class LoadingDialogWidgetState extends State<LoadingDialogWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: double.infinity,
      padding: SizeUtil.padding(bottom: 100),
      child: Container(
        width: SizeUtil.width(100),
        height: SizeUtil.width(100),
        decoration: new BoxDecoration(
          color: Colors.white70,
          borderRadius: new BorderRadius.circular(SizeUtil.width(5)),),
        child: _Progress(),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  final Widget? child;

  _Progress({
    Key? key,
    this.child,
  })  :super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: Center(
          child: child??CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(ZColors.ZFFEECC5B),),
        ));
  }
}