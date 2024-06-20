import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/common/global.dart';
import 'package:abey_wallet/common/theme.dart';
import 'package:abey_wallet/event/event.dart';
import 'package:abey_wallet/pages/splish.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/language_util.dart';
import 'package:abey_wallet/utils/preferences_util.dart';
import 'package:abey_wallet/utils/style_util.dart';
import 'package:abey_wallet/widget/CustomBehavior.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification?.body}');
}

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await Firebase.initializeApp();

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    messaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
    messaging.getToken().then((value) => {
      Global.GOOGLE_TOKEN = value ?? "",
      eventBus.fire(UpdateTokenid(value ?? "")),
    });
    messaging.subscribeToTopic("messaging");

    FirebaseMessaging.onBackgroundMessage(_messageHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print(event.notification?.body);
      AlertUtil.showTipsBar("${event.notification?.title ?? ""}\n${event.notification?.body ?? ""}", duration: Duration(seconds: 2));
      eventBus.fire(UpdateBalance());
      eventBus.fire(UpdateTradeKyf());
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      AlertUtil.showTipsBar("${message.notification?.title ?? ""}\n${message.notification?.body ?? ""}", duration: Duration(seconds: 2));
      eventBus.fire(UpdateBalance());
      eventBus.fire(UpdateTradeKyf());
    });

    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
      if (window.physicalSize.isEmpty) {
        window.onMetricsChanged = () {
          if (!window.physicalSize.isEmpty) {
            window.onMetricsChanged = null;
            runAbeyApp();
          }
        };
      } else {
        runAbeyApp();
      }
    } else if (Platform.isIOS) {
      runAbeyApp();
    } else {
      runAbeyApp();
    }
  }, (error, stackTrace) {
    print("App Start err ${error.toString()}");
  });
}

void runAbeyApp() {
  Global.init(() {
    runApp(AbeyApp());
  });
}

class AbeyApp extends StatefulWidget {
  const AbeyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AbeyAppState();
  }
}

class AbeyAppState extends State<AbeyApp> {
  final ThemeMode themeMode = StyleUtil.themeMode;
  var locale;

  @override
  void initState() {
    super.initState();
    eventBus.on<ELanguage>().listen((event) {
      _loadLocale();
    });
    _loadLocale();
  }

  void _loadLocale() {
    setState(() {
      String langCode = PreferencesUtil.getString(Constant.ZLanguage);
      if (langCode.isEmpty) {
        PreferencesUtil.putString(Constant.ZLanguage, '');
        locale = null;
      } else {
        locale = new Locale(langCode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final easyload = EasyLoading.init();
    return GetMaterialApp(
      home: SplishPage(),
      title: 'ABEY',
      popGesture: true,
      themeMode: themeMode,
      theme: kLightTheme,
      darkTheme: kDarkTheme,
      builder: (context, child) {
        child = easyload(context, child);
        return ScrollConfiguration(
          behavior: CustomBehavior(),
          child: child,
        );
      },
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        String langCode = PreferencesUtil.getString(Constant.ZLanguage);
        if (langCode.isEmpty) {
          if (deviceLocale != null && deviceLocale.languageCode.contains("zh")) {
            PreferencesUtil.putString(Constant.ZLanguage, "zh");
            locale = Locale("zh");
          } else if (deviceLocale != null && deviceLocale.languageCode.contains("ja")) {
            PreferencesUtil.putString(Constant.ZLanguage, "ja");
            locale = Locale("ja");
          } else if (deviceLocale != null && deviceLocale.languageCode.contains("ko")) {
            PreferencesUtil.putString(Constant.ZLanguage, "ko");
            locale = Locale("ko");
          } else {
            PreferencesUtil.putString(Constant.ZLanguage, "en");
            locale = Locale("en");
          }
          Get.updateLocale(locale);
        }
      },
      translations: LanguageUtil(),
      locale: locale,
      navigatorObservers: [observer],
    );
  }
}
