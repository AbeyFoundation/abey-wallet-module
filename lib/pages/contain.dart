import 'dart:io';

import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/global.dart';
import 'package:abey_wallet/common/zcolor.dart';
import 'package:abey_wallet/pages/discover.dart';
import 'package:abey_wallet/pages/kyf.dart';
import 'package:abey_wallet/pages/set.dart';
import 'package:abey_wallet/pages/wallet.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/widget/dialog/version_update_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ContainPage extends StatefulWidget {
  const ContainPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ContainPageState();
  }
}

class ContainPageState extends State<ContainPage> {
  int currentIndex = 0;
  PageController _pageController = PageController(initialPage: 0);
  List? pages;

  var tabImages;

  int _popStep = 0;

  bool isWheel = false;

  @override
  void initState() {
    super.initState();

    _popStep = 0;

    if (Constant.Base_Check_Update) {
      Future.delayed(Duration(seconds: 1),() async {
        await checkUpdate(context,(data) {
        });
      });
    }

    if (Platform.isIOS || Platform.isMacOS) {
      if (Global.IS_WHEEL) {
        isWheel = true;
        pages = [WalletPage(), KyfPage(), DiscoverPage(), SetPage()];
        tabImages = [
          [
            getTabImage('assets/images/contain_tab_wallet_true.png'),
            getTabImage('assets/images/contain_tab_wallet_false.png')
          ],
          [
            getTabImage('assets/images/contain_tab_kyf_true.png'),
            getTabImage('assets/images/contain_tab_kyf_false.png')
          ],
          [
            getTabImage('assets/images/contain_tab_discover_true.png'),
            getTabImage('assets/images/contain_tab_discover_false.png')
          ],
          [
            getTabImage('assets/images/contain_tab_mine_true.png'),
            getTabImage('assets/images/contain_tab_mine_false.png')
          ],
        ];
      } else {
        isWheel = false;
        pages = [WalletPage(), SetPage()];
        tabImages = [
          [
            getTabImage('assets/images/contain_tab_wallet_true.png'),
            getTabImage('assets/images/contain_tab_wallet_false.png')
          ],
          [
            getTabImage('assets/images/contain_tab_mine_true.png'),
            getTabImage('assets/images/contain_tab_mine_false.png')
          ],
        ];
      }
    } else {
      isWheel = true;
      pages = [WalletPage(), KyfPage(), DiscoverPage(), SetPage()];
      tabImages = [
        [
          getTabImage('assets/images/contain_tab_wallet_true.png'),
          getTabImage('assets/images/contain_tab_wallet_false.png')
        ],
        [
          getTabImage('assets/images/contain_tab_kyf_true.png'),
          getTabImage('assets/images/contain_tab_kyf_false.png')
        ],
        [
          getTabImage('assets/images/contain_tab_discover_true.png'),
          getTabImage('assets/images/contain_tab_discover_false.png')
        ],
        [
          getTabImage('assets/images/contain_tab_mine_true.png'),
          getTabImage('assets/images/contain_tab_mine_false.png')
        ],
      ];
    }
  }

  Image getTabImage(String path) {
    return new Image.asset(path,width: 19,height: 19);
  }

  Image getTabIcon(int curIndex) {
    if(currentIndex == curIndex) {
      return tabImages[curIndex][0];
    } else {
      return tabImages[curIndex][1];
    }
  }

  Widget createTabBarView() {
    return PageView.builder(
      controller: _pageController,
      allowImplicitScrolling: true,
      itemBuilder: (context, index) {
        return pages?[index];
      },
      itemCount: pages?.length,
      onPageChanged: (index) {
        if (currentIndex != index) {
          setState(() {
            currentIndex = index;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () {
        if (_popStep == 0) {
          AlertUtil.showTipsBar(ID.CommonBack.tr);
          _popStep++;
          Future.delayed(Duration(seconds: 2), () {
            _popStep = 0;
          });
          return Future.value(true);
        }
        SystemNavigator.pop();
        return Future.value(true);
      },
      child: isWheel ? Scaffold(
        backgroundColor: ZColors.KFFFFFFFFTheme(context),
        body: createTabBarView(),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: ZColors.ZFFEECC5B,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: tabImages[0][1],
              activeIcon: tabImages[0][0],
              label: ID.MineHome.tr,
            ),
            BottomNavigationBarItem(
              icon: tabImages[1][1],
              activeIcon: tabImages[1][0],
              label: ID.Kyf.tr,
            ),
            BottomNavigationBarItem(
              icon: tabImages[2][1],
              activeIcon: tabImages[2][0],
              label: ID.Discover.tr,
            ),
            BottomNavigationBarItem(
              icon: tabImages[3][1],
              activeIcon: tabImages[3][0],
              label: ID.Mine.tr,
            ),
          ],
          currentIndex: currentIndex,
          onTap: (index) => setState(() {
            currentIndex = index;
            _pageController.animateToPage(currentIndex, duration: Duration(milliseconds: 200), curve: Curves.ease);
          }),
        ),
      ) : Scaffold(
        backgroundColor: ZColors.KFFFFFFFFTheme(context),
        body: createTabBarView(),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: ZColors.ZFFEECC5B,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: tabImages[0][1],
              activeIcon: tabImages[0][0],
              label: ID.MineHome.tr,
            ),
            BottomNavigationBarItem(
              icon: tabImages[1][1],
              activeIcon: tabImages[1][0],
              label: ID.Mine.tr,
            ),
          ],
          currentIndex: currentIndex,
          onTap: (index) => setState(() {
            currentIndex = index;
            _pageController.animateToPage(currentIndex, duration: Duration(milliseconds: 200), curve: Curves.ease);
          }),
        ),
      )
    );
  }
}