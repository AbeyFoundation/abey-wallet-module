import 'dart:convert';

import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/model/coin_model.dart';
import 'package:abey_wallet/model/identity_model.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/service/api_data.dart';
import 'package:abey_wallet/service/api_manager.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/common_util.dart';
import 'package:abey_wallet/utils/database_util.dart';
import 'package:abey_wallet/utils/preferences_util.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:abey_wallet/extension/string_extension.dart';
import 'package:package_info/package_info.dart';
import 'dart:io';
import 'package:abey_wallet/vender/chain/chain_exp.dart';
import 'package:get/get.dart';

class Global {
  static String GOOGLE_TOKEN = "";

  static String DEVICE_UDID="";
  static String VERSION = '';
  static String IMEI = '';
  static String MAC = '';
  static String MODEL = '';
  static String NETWORK = '';
  static String PLATFORM_V = '';
  static String CLIENT_V = '';
  static String CLIENT_C = '';
  static String SOURCE = '';
  static String RESOLUTION = '';
  static String DEVICE_ID = '';
  static String SITE = '';
  static String LANGUAGE = '';
  static String CS = '';

  static bool IS_WHEEL = false;

  static bool isDebug = !bool.fromEnvironment("dart.vm.product");
  static bool isAndroid = Platform.isAndroid;
  static bool isIOS = Platform.isIOS;
  static bool isLinux = Platform.isLinux;
  static bool isMacOS = Platform.isMacOS;
  static bool isWindows = Platform.isWindows;
  static bool isFuchsia = Platform.isFuchsia;

  static String PAGE_AGREEMENT='';
  static String PAGE_VERSION='';
  static String PAGE_FEEDBACK = "";
  static String PAGE_INSTRUCTIONS = "";
  static List<CoinModel> SUPORT_CHAINS = [];
  static List<CoinModel> SUPORT_KYFS = [];
  static List<CoinModel> SUPORT_DAPPS = [];
  static RPC E_RPC = RPC();
  static List<CoinModel> CURRENT_CONIS=[];


  static const bool zReleaseMode = bool.fromEnvironment('dart.vm.product',defaultValue: false);
  static PackageInfo? zPackageInfo;
  static String zAuth = "";

  static Future init(VoidCallback callback) async {
    WidgetsFlutterBinding.ensureInitialized();

    await PreferencesUtil.getInstance();
    zPackageInfo = await PackageInfo.fromPlatform();

    callback();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    if (Platform.isAndroid) {
      SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent,statusBarIconBrightness: Brightness.dark,);
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    }
  }

  static String getLanguage() {
    var defaultLocale = WidgetsBinding.instance!.window.locale;
    String languageCode = PreferencesUtil.getString(Constant.ZLanguage,defValue: defaultLocale.languageCode);
    return languageCode.split("-")[0].toLowerCase();
  }

  static install(BuildContext context) async {
    var language = PreferencesUtil.getString(Constant.ZLanguage);
    if (language == null) {
      language = Global.LANGUAGE;
      PreferencesUtil.putString(Constant.ZLanguage, language);
    }
    var touchID = PreferencesUtil.getString(Constant.ZTouchID);
    if (touchID == null) {
      PreferencesUtil.putString(Constant.ZTouchID, "0");
    }

    Global.LANGUAGE = language;

    var cs = PreferencesUtil.getString(Constant.CURRENT_CS);
    if (cs.isEmptyString()) {
      cs = 'USD';
      PreferencesUtil.putString(Constant.CURRENT_CS, cs);
    }
    Global.CS = cs;

    Global.DEVICE_UDID = PreferencesUtil.getString(Constant.DEVICE_UDID);
    if (Global.DEVICE_UDID.isEmptyString()) {
      Global.DEVICE_UDID = CommonUtil.generateUDID();
      PreferencesUtil.putString(Constant.DEVICE_UDID, Global.DEVICE_UDID);
    }

    await initData();

    ApiData apiData = await ApiManager.postConfigStatic(data:{
      "wid": "",
    });
    if (apiData.code == 0) {
      ConfigModel configModel = ConfigModel.fromJson(apiData.data);
      if (configModel != null) {
        String jsonS = json.encode(apiData.data);
        PreferencesUtil.putString(Constant.ZConfigModel, jsonS);

        PreferencesUtil.putBool('${Constant.WHEEL}_${Global.CLIENT_V}',configModel.config!['wheel'] == 1 ? true : false);

        Global.IS_WHEEL = PreferencesUtil.getBool('${Constant.WHEEL}_${Global.CLIENT_V}');
        Global.PAGE_AGREEMENT = configModel.config!['agreement'];
        Global.PAGE_VERSION = configModel.config!['version'];
        Global.PAGE_FEEDBACK = configModel.config!['feedbackEmail'];
        Global.PAGE_INSTRUCTIONS = configModel.config!['instructions'];
        Global.SUPORT_CHAINS = configModel.chains!;
        Global.SUPORT_KYFS = configModel.nftchains!;
        Global.SUPORT_DAPPS = configModel.dappGroups!;

        var rpc_abey = configModel.config!['ABEY_RPC'];
        if (rpc_abey != null && rpc_abey != "") {
          var json = jsonDecode(rpc_abey);
          Global.E_RPC.ABEY = ChainRPC.fromJson(json);
        }
        var rpc_eth = configModel.config!['ETH_RPC'];
        if(rpc_eth != null && rpc_eth != "") {
          var json = jsonDecode(rpc_eth);
          Global.E_RPC.ETH = ChainRPC.fromJson(json);
        }
        var rpc_bnb = configModel.config!['BNB_RPC'];
        if(rpc_bnb != null && rpc_bnb != "") {
          var json = jsonDecode(rpc_bnb);
          Global.E_RPC.BNB = ChainRPC.fromJson(json);
        }
        var rpc_matic = configModel.config!['MATIC_RPC'];
        if(rpc_matic != null && rpc_matic != "") {
          var json = jsonDecode(rpc_matic);
          Global.E_RPC.MATIC = ChainRPC.fromJson(json);
        }

        if (Global.GOOGLE_TOKEN.isNotEmptyString()) {
          PreferencesUtil.putString(Constant.FCMToken, Global.GOOGLE_TOKEN);
        }
      } else {
        PreferencesUtil.putBool('${Constant.WHEEL}_${Global.CLIENT_V}', false);
      }
    } else {
      AlertUtil.showWarnBar(ID.CommonNetworkError.tr);
      PreferencesUtil.putBool('${Constant.WHEEL}_${Global.CLIENT_V}', false);
    }

    initJPush();
    String fcmtoken = PreferencesUtil.getString(Constant.FCMToken);
    deviceTokenAction(fcmtoken);
    return Future.value(true);
  }

  static void deviceTokenAction(String tokenid) async {
    List<IdentityModel> identityModelList = await DatabaseUtil.create().queryIdentityList();
    if (identityModelList != null) {
      List<CoinModel> chainList = [];
      for (final identityModel in identityModelList) {
        CoinModel coinModel = new CoinModel(wid: identityModel.wid);
        List<CoinModel> coinList = await DatabaseUtil.create().queryCoinList(coinModel);
        if (coinList != null && coinList.length > 0) {
          coinList.forEach((element) {
            if (element.symbol == element.contract && element.contract == "ABEY") {
              chainList.add(element);
            }
          });
        }
      }
      String addressStr = "";
      for (final coinModel in chainList) {
        if (coinModel.address?.isNotEmptyString()) {
          if (addressStr.length > 0) {
            if (!addressStr.contains(coinModel.address!.toLowerCase())) {
              addressStr = addressStr + "," + (coinModel.address?.toLowerCase() ?? "");
            }
          } else {
            addressStr = (coinModel.address?.toLowerCase() ?? "");
          }
        }
      }
      String language = PreferencesUtil.getString(Constant.ZLanguage);
      ApiManager.postConfigDeviceTokenid(data: {
        "deviceId": Global.DEVICE_ID,
        "tokenId": tokenid,
        "addressStr": addressStr,
        "lang": language.isNotEmpty ? language : 'en'
      });
    }
  }

  static getPlatform() {
    if (Platform.isAndroid) {
      return "android";
    }
    if (Platform.isIOS) {
      return "iOS";
    }
    if (Platform.isLinux) {
      return "Linux";
    }
    if (Platform.isMacOS) {
      return "macOS";
    }
    if (Platform.isWindows) {
      return "windows";
    }
    if (Platform.isFuchsia) {
      return "fuchsia";
    }
    return "";
  }

  static initData() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      Global.VERSION = packageInfo.version;
      Global.CLIENT_C = packageInfo.buildNumber;
      DeviceInfoPlugin deviceInfo = new DeviceInfoPlugin();
      if (Platform.isIOS) {
        IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
        Global.MODEL = iosDeviceInfo.model;
        Global.PLATFORM_V = iosDeviceInfo.systemVersion;
        Global.CLIENT_V = Global.VERSION;
        Global.DEVICE_ID = iosDeviceInfo.identifierForVendor;
      } else if (Platform.isAndroid) {
        AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
        Global.MODEL = androidDeviceInfo.model;
        Global.PLATFORM_V = androidDeviceInfo.version.release;
        Global.CLIENT_V = Global.VERSION;
        Global.DEVICE_ID = androidDeviceInfo.id;
      }

      String data = PreferencesUtil.getString(Constant.ZConfigModel);
      ConfigModel configModel = ConfigModel.fromJson(json.decode(data));
      if (configModel != null) {
        Global.IS_WHEEL = PreferencesUtil.getBool('${Constant.WHEEL}_${Global.CLIENT_V}');
        Global.PAGE_AGREEMENT = configModel.config!['agreement'];
        Global.PAGE_VERSION = configModel.config!['version'];
        Global.PAGE_FEEDBACK = configModel.config!['feedbackEmail'];
        Global.PAGE_INSTRUCTIONS = configModel.config!['instructions'];
        Global.SUPORT_CHAINS = configModel.chains!;
        Global.SUPORT_DAPPS = configModel.dappGroups!;

        var rpc_abey = configModel.config!['ABEY_RPC'];
        if (rpc_abey != null && rpc_abey != "") {
          var json = jsonDecode(rpc_abey);
          Global.E_RPC.ABEY = ChainRPC.fromJson(json);
        }
        var rpc_eth = configModel.config!['ETH_RPC'];
        if(rpc_eth != null && rpc_eth != "") {
          var json = jsonDecode(rpc_eth);
          Global.E_RPC.ETH = ChainRPC.fromJson(json);
        }

        var rpc_bnb = configModel.config!['BNB_RPC'];
        if(rpc_bnb != null && rpc_bnb != "") {
          var json = jsonDecode(rpc_bnb);
          Global.E_RPC.BNB = ChainRPC.fromJson(json);
        }
        var rpc_matic = configModel.config!['MATIC_RPC'];
        if(rpc_matic != null && rpc_matic != "") {
          var json = jsonDecode(rpc_matic);
          Global.E_RPC.MATIC = ChainRPC.fromJson(json);
        }
      }
    } catch (e) {

    }
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile) {
        Global.NETWORK = 'mobile';
      } else if (connectivityResult == ConnectivityResult.wifi) {
        Global.NETWORK = 'wifi';
      } else {
        Global.NETWORK = 'none';
      }
    } catch (e) {
      Global.NETWORK = 'none';
    }
  }

  static initJPush() {

  }
}