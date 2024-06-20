import 'dart:async';
import 'package:abey_wallet/common/constant.dart';
import 'package:abey_wallet/model/auth_model.dart';
import 'package:abey_wallet/model/coin_model.dart';
import 'package:abey_wallet/model/identity_model.dart';
import 'package:path/path.dart';
import 'package:synchronized/synchronized.dart';
import 'package:sqflite/sqflite.dart';
import 'package:abey_wallet/extension/string_extension.dart';

class DatabaseUtil {
  DatabaseUtil();
  DatabaseUtil.create();

  static Database? _database;

  _init() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, Constant.DatabaseName);
    _database = await openDatabase(path, version: 3, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return _database;
  }

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    } else {
      await _init();
      return _database!;
    }
  }

  void _onCreate(Database database,int oldV) async {
    await database.execute(
        'CREATE TABLE IF NOT EXISTS abey_auth('
        'id INTEGER PRIMARY KEY autoincrement, '
        'type TEXT, '
        'password TEXT, '
        'touchId TEXT, '
        'faceId TEXT)');

    await database.execute(
        'CREATE TABLE IF NOT EXISTS abey_identity('
        'id INTEGER PRIMARY KEY autoincrement, '
        'wid TEXT, '
        'name TEXT, '
        'scope TEXT, '
        'type INTEGER, '
        'tokenType TEXT, '
        'token TEXT, '
        'mnemonic TEXT, '
        'keystore TEXT, '
        'privateKey TEXT, '
        'privateKeyTrx TEXT, '
        'color TEXT, '
        'isBackup INTEGER)');

    await database.execute('CREATE TABLE IF NOT EXISTS abey_coin('
        'id INTEGER PRIMARY KEY autoincrement, '
        'wid TEXT, '
        'color TEXT, '
        'address TEXT, '
        'publicKey TEXT, '
        'token TEXT, '
        'tokenType TEXT, '
        'tokenID TEXT, '
        'mnemonic TEXT, '
        'keystore TEXT, '
        'privateKey TEXT, '

        'symbol TEXT, '
        'name TEXT, '
        'contract TEXT, '
        'contractAddress TEXT, '
        'chainName TEXT, '
        'icon TEXT, '
        'balance TEXT, '
        'price TEXT, '
        'totalPrice TEXT, '
        'value TEXT, '
        'extra TEXT, '
        'description TEXT, '
        'csUnit TEXT, '
        'note TEXT)'
    );
  }

  void _onUpgrade(Database database,int oldV,int newV) async {
    if (oldV < newV) {
      switch (oldV) {
        case 0:
          break;
        case 1:
          await database.execute("ALTER TABLE 'abey_coin' ADD 'tokenID' TEXT;");
          await database.execute("ALTER TABLE 'abey_identity' ADD 'privateKeyTrx' TEXT;");
          break;
        case 2:
          await database.execute("ALTER TABLE 'abey_identity' ADD 'privateKeyTrx' TEXT;");
          break;
      }
    }
  }

  insertAuth(AuthModel authModel) async {
    var db = await database;
    AuthModel? old = await queryAuth();
    var result;
    if (old != null) {
      result = await updateAuth(authModel);
    } else {
      result = await db.insert(Constant.Table_Auth, authModel.toJson());
    }
    return result;
  }

  deleteAuth(AuthModel authModel) async {
    var db = await database;
    var result = await db.delete(Constant.Table_Auth, where: "id = ?",whereArgs: [authModel.id]);
    return result;
  }

  updateAuth(AuthModel authModel) async {
    var db = await database;
    var result = await db.update(Constant.Table_Auth, authModel.toJson());
    return result;
  }

  queryAuth() async {
    var db = await database;
    var result = await db.query(Constant.Table_Auth);
    AuthModel? authModel;
    if (result != null && result.isNotEmpty) {
      authModel = AuthModel.fromJson(result[0]);
    }
    return authModel;
  }

  queryAuthList() async {
    var db = await database;
    var result = await db.query(Constant.Table_Auth);
    List<AuthModel> authModelList = [];
    if (result != null && result.isNotEmpty && result is List) {
      result.forEach((element) {
        authModelList.add(AuthModel.fromJson(element));
      });
    }
    return authModelList;
  }

  insertIdentity(IdentityModel identityModel) async {
    var db = await database;
    IdentityModel? old;
    if (identityModel.wid != null && identityModel.wid!.isNotEmptyString()) {
      old = await queryIdentity(identityModel);
    }
    var result;
    if (old != null) {
      result = await updateIdentity(identityModel);
    } else {
      result = await db.insert(Constant.Table_Identity, identityModel.toJson());
    }
    return result;
  }

  deleteIdentity(IdentityModel identityModel) async {
    var db = await database;
    var result = await db.delete(Constant.Table_Identity, where: "id = ?",whereArgs: [identityModel.id]);
    return result;
  }

  updateIdentity(IdentityModel identityModel) async {
    List<String> keys = [];
    List<String> values = [];
    if (identityModel.wid != null && identityModel.wid!.isNotEmptyString()) {
      keys.add("wid");
      values.add(identityModel.wid!);
    }
    String whereStr = createWhere(keys);

    var db = await database;
    var result = await db.update(Constant.Table_Identity, identityModel.toJson(), where: whereStr,whereArgs: values);
    return result;
  }

  queryIdentityByWid(String wid) async {
    var db = await database;
    var result = await db.query(Constant.Table_Identity,where: "wid = ?",whereArgs: [wid]);
    List<IdentityModel> identityModelList = [];
    if (result != null && result.isNotEmpty && result is List) {
      result.forEach((element) {
        identityModelList.add(IdentityModel.fromJson(element));
      });
      return identityModelList[0];
    } else {
      return null;
    }
  }

  queryCurrentIdentityByWid(String wid) async {
    var db = await database;
    List<IdentityModel> identityModelList = await queryIdentityList();
    IdentityModel? result;
    if (identityModelList.isEmpty) {
      return result;
    } else {
      for (int i = 0; i < identityModelList.length; i++) {
        IdentityModel identityModel = identityModelList[i];
        if (identityModel.wid == wid) {
          result = identityModel;
          break;
        }
      }
      if (result == null) {
        result = identityModelList[0];
      }
      return result;
    }
  }

  queryIdentityFirst() async {
    var db = await database;
    var result = await db.query(Constant.Table_Identity);
    List<IdentityModel> identityModelList = [];
    if (result != null && result.isNotEmpty && result is List) {
      result.forEach((element) {
        identityModelList.add(IdentityModel.fromJson(element));
      });
      return identityModelList[0];
    } else {
      return null;
    }
  }

  queryIdentity(IdentityModel identity) async {
    var db = await database;
    var result = await db.query(Constant.Table_Identity,where: "wid = ?",whereArgs: [identity.wid]);
    List<IdentityModel> identityModelList = [];
    if (result != null && result.isNotEmpty && result is List) {
      result.forEach((element) {
        identityModelList.add(IdentityModel.fromJson(element));
      });
      return identityModelList[0];
    } else {
      return null;
    }
  }

  queryIdentityList() async {
    var db = await database;
    var result = await db.query(Constant.Table_Identity);
    List<IdentityModel> identityModelList = [];
    if (result != null && result.isNotEmpty && result is List) {
      result.forEach((element) {
        identityModelList.add(IdentityModel.fromJson(element));
      });
    }
    return identityModelList;
  }

  insertCoin(CoinModel coinModel) async {
    var db = await database;
    List<CoinModel> coinModelList = await queryCoin(coinModel);
    var result;
    if (coinModelList != null && coinModelList.length > 0) {
      result = await updateCoin(coinModel);
    } else {
      result = await db.insert(Constant.Table_Coin, coinModel.toJson());
    }
    return result;
  }

  deleteCoin(CoinModel coin) async {
    List<String> keys = [];
    List<String> values = [];
    if (coin.wid != null && coin.wid!.isNotEmptyString()) {
      keys.add("wid");
      values.add(coin.wid!);
    }
    if (coin.contract != null && coin.contract!.isNotEmptyString()) {
      keys.add("contract");
      values.add(coin.contract!);
    }
    if (coin.symbol != null && coin.symbol!.isNotEmptyString()) {
      keys.add("symbol");
      values.add(coin.symbol!);
    }
    if (coin.address != null && coin.address!.isNotEmptyString()) {
      keys.add("address");
      values.add(coin.address!);
    }
    String whereStr = createWhere(keys);
    var db = await database;
    var result = await db.delete(Constant.Table_Coin, where: whereStr,whereArgs: values);
    return result;
  }

  updateCoin(CoinModel coin) async {
    List<String> keys = [];
    List<String> values = [];
    if (coin.wid != null && coin.wid!.isNotEmptyString()) {
      keys.add("wid");
      values.add(coin.wid!);
    }
    if (coin.contract != null && coin.contract!.isNotEmptyString()) {
      keys.add("contract");
      values.add(coin.contract!);
    }
    if (coin.symbol != null && coin.symbol!.isNotEmptyString()) {
      keys.add("symbol");
      values.add(coin.symbol!);
    }
    if (coin.address != null && coin.address!.isNotEmptyString()) {
      keys.add("address");
      values.add(coin.address!);
    }
    String whereStr = createWhere(keys);
    var db = await database;
    var result = await db.update(Constant.Table_Coin, coin.toJson(),where: whereStr,whereArgs: values);
    return result;
  }

  updateCoinAmount(CoinModel coin) async {
    List<String> keys = [];
    List<String> values = [];
    if (coin.wid != null && coin.wid!.isNotEmptyString()) {
      keys.add("wid");
      values.add(coin.wid!);
    }
    if (coin.contract != null && coin.contract!.isNotEmptyString()) {
      keys.add("contract");
      values.add(coin.contract!);
    }
    if (coin.symbol != null && coin.symbol!.isNotEmptyString()) {
      keys.add("symbol");
      values.add(coin.symbol!);
    }
    if (coin.address != null && coin.address!.isNotEmptyString()) {
      keys.add("address");
      values.add(coin.address!);
    }
    String whereStr = createWhere(keys);
    var db = await database;
    var result = await db.update(Constant.Table_Coin, {'color': coin.color, 'balance': coin.balance ,'price': coin.price, "totalPrice": coin.totalPrice, "tokenID": coin.tokenID, "csUnit": coin.csUnit},where: whereStr,whereArgs: values);
    if (result == 1) {

    } else {
      CoinModel coinChain = new CoinModel();
      coinChain.wid = coin.wid;
      coinChain.contract = coin.contract;
      List<CoinModel> coinModelList = await queryCoin(coinChain);
      if (coinModelList != null && coinModelList.length > 0) {
        CoinModel coinNew = coinModelList.first;
        coinNew.id = 0;
        coinNew.symbol = coin.symbol;
        coinNew.name = coin.name;
        coinNew.contractAddress = coin.contractAddress;
        coinNew.icon = coin.icon;
        coinNew.color = coin.color;
        coinNew.balance = coin.balance;
        coinNew.price = coin.price;
        coinNew.totalPrice = coin.totalPrice;
        coinNew.tokenID = coin.tokenID;
        coinNew.csUnit = coin.csUnit;
        coinNew.value = coin.value;
        coinNew.extra = coin.extra;
        coinNew.note = coin.note;
        coinNew.description = coin.description;
        result = await insertCoin(coinNew);
      } else {

      }
    }
    return result;
  }

  updateCoinList(List<CoinModel> coinModelList) async {
    coinModelList.forEach((element) async {
      await updateCoinAmount(element);
    });
    return coinModelList.length;
  }

  queryCoin(CoinModel coin) async {
    List<String> keys = [];
    List<String> values = [];
    if (coin.wid != null && coin.wid!.isNotEmptyString()) {
      keys.add("wid");
      values.add(coin.wid!);
    }
    if (coin.contract != null && coin.contract!.isNotEmptyString()) {
      keys.add("contract");
      values.add(coin.contract!);
    }
    if (coin.symbol != null && coin.symbol!.isNotEmptyString()) {
      keys.add("symbol");
      values.add(coin.symbol!);
    }
    if (coin.address != null && coin.address?.isNotEmptyString()) {
      keys.add("address");
      values.add(coin.address!);
    }
    String whereStr = createWhere(keys);
    var db = await database;
    var result = await db.query(Constant.Table_Coin,where: whereStr,whereArgs: values);
    List<CoinModel> coinModelList = [];
    if (result is List) {
      result.forEach((element) {
        coinModelList.add(CoinModel.fromJson(element));
      });
    }
    return coinModelList;
  }
  queryChainCoin(CoinModel coin) async {
    List<String> keys = [];
    List<String> values = [];
    if (coin.wid != null && coin.wid?.isNotEmptyString()) {
      keys.add("wid");
      values.add(coin.wid!);
    }
    if (coin.contract != null && coin.contract!.isNotEmptyString()) {
      keys.add("contract");
      values.add(coin.contract!);
    }
    keys.add("contractAddress");
    values.add("");
    String whereStr = createWhere(keys);
    var db = await database;
    var result = await db.query(Constant.Table_Coin,where: whereStr,whereArgs: values);
    List<CoinModel> coinModelList = [];
    if (result is List) {
      result.forEach((element) {
        coinModelList.add(CoinModel.fromJson(element));
      });
    }
    return coinModelList;
  }

  queryCoinList(CoinModel coin) async {
    List<String> keys = [];
    List<String> values = [];
    if (coin.wid != null && coin.wid?.isNotEmptyString()) {
      keys.add("wid");
      values.add(coin.wid!);
    }
    if (coin.contract != null && coin.contract?.isNotEmptyString()) {
      keys.add("contract");
      values.add(coin.contract!);
    }
    if (coin.symbol != null && coin.symbol?.isNotEmptyString()) {
      keys.add("symbol");
      values.add(coin.symbol!);
    }
    if (coin.address != null && coin.address?.isNotEmptyString()) {
      keys.add("address");
      values.add(coin.address!);
    }
    String whereStr = createWhere(keys);
    var db = await database;
    var result = await db.query(Constant.Table_Coin,where: whereStr,whereArgs: values);
    List<CoinModel> coinModelList = [];
    if (result is List) {
      result.forEach((element) {
        coinModelList.add(CoinModel.fromJson(element));
      });
    }
    return coinModelList;
  }

  String createWhere(List keys) {
    String whereStr = "";
    keys.forEach((element) {
      if (whereStr.isEmpty) {
        whereStr = "$element = ? ";
      } else {
        whereStr = "$whereStr and $element = ? ";
      }
    });
    if (whereStr.isEmpty) {
      whereStr = " 1 ";
    }
    return whereStr;
  }

  Future close() async {
    var db = await database;
    if (db.isOpen) {
      db.close();
    }
    _database = null;
  }
}