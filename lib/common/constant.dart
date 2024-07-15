class Constant {
  static const String Assets_Files = 'assets/files/';
  static const String Assets_Images = 'assets/images/';

  static const String Base_Url = 'http://54.255.45.202:8010';

  static const bool Base_Check_Update = true;

  static final String APPID='';
  static final String APPKEY="";
  static final String SEED_ABC="";

  static const bool ISDEBUG = true;

  static final String WHEEL = "WHEEL";

  static const String DatabaseName = "abey.db";
  static const String Table_Auth = "abey_auth";
  static const String Table_Identity = "abey_identity";
  static const String Table_Coin = "abey_coin";

  static const String ZGuide = "ZGuide";
  static const String ZIsShowProperty = "ZIsShowProperty";
  static const String ZIsHavePassword = "ZIsHavePassword";
  static const String ZLanguage = 'ZLanguage';
  static const String ZTouchID = "ZTouchID";

  static const String ZConfigModel = "ZConfigModel";
  static const String ZAddressBook = "ZAddressBook";
  static const String ZALPHABET = "0123456789abcdef";
  static const String ZALPHABETLONG = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

  static const String CURRENT_WID = "CURRENT_WID";
  static const String CURRENT_CS = "CURRENT_CS";
  static const String DEVICE_UDID = "DEVICE_UDID";

  static const double AppBarHeight = 48;

  static const String ZLightThemeModeString = 'LightThemeModeString';
  static const String ZDarkThemeModeString = 'DarkThemeModeString';
  static const String ZSystemThemeModeString = 'SystemThemeModeString';

  static const String ZDiscoverSearchHistory = "DiscoverSearchHistory";
  static const String ZDiscoverSearchRefresh = "ZDiscoverSearchRefresh";

  static const String CHAIN_ABEY = "ABEY";
  static const String CHAIN_ETH = "ETH";
  static const String CHAIN_BNB = "BNB";
  static const String CHAIN_MATIC = "MATIC";
  static const String CHAIN_TRX = "TRX";

  static const String Marco_Wallet_Json = "Marco_Wallet_Json";
  static const String TrayName = "tray.db";
  static const String WalletArray = "WalletArray";

  static const String WalletOriginal = "WalletOriginal";

  static const String WalletLocalAuth = "WalletLocalAuth";
  static const String WalletLocalAuthPwd = "WalletLocalAuthPwd";
  static const String FCMToken = "FCMToken";

  static const List<Map<String,String>> ZLanguages = [
    {
      'name': 'en',
      'content': 'English',
    },
    {
      'name': 'ja',
      'content': '日本語',
    },
    {
      'name': 'ko',
      'content': '한국어',
    },
    {
      'name': 'zh',
      'content': '简体中文',
    },
  ];

  static const Map<String,String> CS_UNITS = {
    "USD":"\$",
    "CNY":"¥",
    "KRW":"₩",
  };

  static const List<Map<String,String>> ZCurrencys = [
    {
      'name': 'USD',
      'content': 'USD',
    },
    {
      'name': 'CNY',
      'content': 'CNY',
    },
    {
      'name': 'KRW',
      'content': 'KRW',
    },
  ];

  static const List<Map<String,String>> ZFocusus = [
    {
      'name': '',
      'content': '',
    },
  ];

  static const List<Map<String,String>> ZBitCoin = [
    {
      'chainName': 'BTC',
      'chainId': '0',
    },
  ];

  static const List<Map<String,String>> ZEthereumSeries = [
    {
      'chainName': 'ETH',
      'chainId': '1',
    },
    {
      'chainName': 'ABEY',
      'chainId': '179',
    },
    {
      'chainName': 'BNB',
      'chainId': '56',
    },
    {
      'chainName': 'MATIC',
      'chainId': '137',
    },
    {
      'chainName': 'MAP',
      'chainId': '22776',
    },
  ];

  static const List<Map<String,String>> ZTron = [
    {
      'chainName': 'TRON',
      'chainId': '0',
    },
  ];
}

class LoadStatus {
  static const int networkFailure = -1;
  static const int apiFailure = -2;
  static const int loading = 0;
  static const int success = 1;
  static const int empty = 2;
}
