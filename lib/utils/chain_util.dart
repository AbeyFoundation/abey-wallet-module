import 'package:abey_wallet/model/auth_model.dart';
import 'package:abey_wallet/model/coin_model.dart';
import 'package:abey_wallet/model/identity_model.dart';
import 'package:abey_wallet/resources/Strings.dart';
import 'package:abey_wallet/service/api_data.dart';
import 'package:abey_wallet/service/api_manager.dart';
import 'package:abey_wallet/utils/alert_util.dart';
import 'package:abey_wallet/utils/common_util.dart';
import 'package:abey_wallet/utils/database_util.dart';
import 'package:abey_wallet/utils/password_util.dart';
import 'package:abey_wallet/vender/chain/chain_exp.dart';
import 'package:abey_wallet/vender/chain/chaincore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:abey_wallet/extension/string_extension.dart';

class ChainUtil {
  static Future<String> getPrivateKeyFromKeystoreEth(BuildContext context,String chainName,String keystore,String passwordKS) async{
    AccountChain chain = getChain(chainName)!;
    if (chain != null) {
      String privateKey = await chain.getPrivateKey(keystore:keystore,password:passwordKS);
      return privateKey;
    } else {
      return "";
    }
  }

  static Future<String> getKeystoreFromPrivateKeyEth(BuildContext context,String chainName, String privateKey, String passwordKS) async{
    AccountChain chain = getChain(chainName)!;
    if (chain != null) {
      String keystore = await chain.getKeystore(privateKey: privateKey,password: passwordKS);
      return keystore;
    } else {
      return "";
    }
  }

  static Future<String> getPrivateKeyFromKeystore(BuildContext context,chains, keystore, passwordKS) async{
    if (chains.length > 0) {
      CoinModel coin = chains[0];
      AccountChain chain = getChain(coin.contract!)!;
      if(chain!=null){
        String privateKey = await chain.getPrivateKey(keystore:keystore,password:passwordKS);
        return privateKey;
      }
    }
    return "";
  }

  static Future<String> getPrivateKeyFromMnemonic(BuildContext context,chains, mnemonic) async{
    if (chains.length > 0) {
      CoinModel coin = chains[0];
      AccountChain chain = getChain(coin.contract!)!;
      if (chain != null) {
        String privateKey = await chain.getPrivateKey(mnemonic:mnemonic);
        return privateKey;
      }
    }
    return "";
  }

  static Future<String> getPrivateKeyFromMnemonicEth(BuildContext context, String chainName,String mnemonic) async{
    AccountChain chain = getChain(chainName)!;
    if (chain != null) {
      String privateKey = await chain.getPrivateKey(mnemonic:mnemonic);
      return privateKey;
    }
    return "";
  }

  static Future<String> vertityAddress(BuildContext context, String chainName, String address) async{
    AccountChain chain = getChain(chainName)!;
    if (chain != null) {
      String isAddress = await chain.validateAddress(address:address);
      return isAddress;
    }
    return "false";
  }

  static Future<dynamic> saveIdentity(BuildContext context, IdentityModel identityModel, String password, {String? mnemonic, String? keystore, String? keystorePwd, String? privateKey}) async {
    String tokenI = "";
    String mnemonicI = "";
    String keystoreI = "";
    String privateKeyI = "";
    String privateKeyITrx = "";
    if (identityModel.tokenType == "mnemonic") {
      String privateS = await ChainUtil.getPrivateKeyFromMnemonicEth(context, "ETH", mnemonic!);
      String keystoreS = await ChainUtil.getKeystoreFromPrivateKeyEth(context, "ETH", privateS, keystorePwd!);
      tokenI = await CommonUtil.encrypt(mnemonic, password);
      mnemonicI = tokenI;
      keystoreI = await CommonUtil.encrypt(keystoreS, password);
      privateKeyI = await CommonUtil.encrypt(privateS, password);
      String privateSTrx = await ChainUtil.getPrivateKeyFromMnemonicEth(context, "TRX", mnemonic);
      privateKeyITrx = await CommonUtil.encrypt(privateSTrx, password);
    } else if (identityModel.tokenType == "keystore") {
      String privateS = await ChainUtil.getPrivateKeyFromKeystoreEth(context, "ETH", keystore!, keystorePwd!);
      String ks = Uri.decodeComponent(keystore);
      tokenI = await CommonUtil.encrypt(ks, password);
      keystoreI = tokenI;
      privateKeyI = await CommonUtil.encrypt(privateS, password);
      String privateSTrx = await ChainUtil.getPrivateKeyFromKeystoreEth(context, "TRX", keystore, keystorePwd);
      privateKeyITrx = await CommonUtil.encrypt(privateSTrx, password);
    } else {
      String keystoreS = await ChainUtil.getKeystoreFromPrivateKeyEth(context, "ETH", privateKey!, keystorePwd!);
      tokenI = await CommonUtil.encrypt(privateKey, password);
      keystoreI = await CommonUtil.encrypt(keystoreS, password);
      privateKeyI = tokenI;
      privateKeyITrx = tokenI;
    }

    IdentityModel identity = IdentityModel.fromJson({
      "wid": identityModel.wid,
      "name": identityModel.name,
      "scope": identityModel.scope,
      "type": identityModel.type,
      "tokenType": identityModel.tokenType,
      "token": tokenI,
      "mnemonic": mnemonicI,
      "keystore": keystoreI,
      "privateKey": privateKeyI,
      "privateKeyTrx": privateKeyITrx,
      "color": "",
      "isImport": 0,
      "isBackup": 1
    });
    return await DatabaseUtil.create().insertIdentity(identity);
  }

  static Future<List<String>> saveCoin(BuildContext context,IdentityModel identityModel,int type,List<CoinModel> chains, String pass, bool needRequest) async {
    List<String> descAddresses = [];
    if (type == 2) {
      IdentityModel identity = await DatabaseUtil.create().queryIdentityByWid(identityModel.wid!);

      await PasswordUtil.handlePassword(context, (text, goback) async {
        pass = text;
        pass = CommonUtil.getTokenId(text);
        AuthModel auth = await DatabaseUtil.create().queryAuth();
        if (auth.password != pass) {
          AlertUtil.showWarnBar(ID.CommonPassword.tr);
          return Future.value(null);
        } else {
          if (goback) {
            Get.back();
          }
        }
      });
    } else {

    }

    if (identityModel.tokenType == "mnemonic") {
      for (int i = 0; i < chains.length; i++) {
        CoinModel coin = chains[i];
        if (coin.contract!.toUpperCase() == "TRX") {
          if (identityModel.privateKeyTrx?.isEmptyString()) {
            String mnemonic = await CommonUtil.decrypt(identityModel.mnemonic!, pass);
            String privateSTrx = await ChainUtil.getPrivateKeyFromMnemonicEth(context, "TRX", mnemonic);
            identityModel.privateKeyTrx = await CommonUtil.encrypt(privateSTrx, pass);

            await DatabaseUtil.create().updateIdentity(identityModel);
          }
          String privateKey = await CommonUtil.decrypt(identityModel.privateKeyTrx!, pass);
          AccountChain chain = getChain("TRX")!;
          String address = await chain.getAddress(privateKey: privateKey);

          coin.wid = identityModel.wid;
          coin.tokenType = identityModel.tokenType;
          coin.token = identityModel.token;
          coin.mnemonic = identityModel.mnemonic;
          coin.keystore = identityModel.keystore;
          coin.publicKey = "";
          coin.privateKey = identityModel.privateKeyTrx;
          coin.address = address;
          await DatabaseUtil.create().insertCoin(coin);
          descAddresses.add(coin.symbol!.toDescAddress(address));
        } else {
          String privateKey = await CommonUtil.decrypt(identityModel.privateKey!, pass);
          AccountChain chain = getChain("ETH")!;
          String address = await chain.getAddress(privateKey: privateKey);

          coin.wid = identityModel.wid;
          coin.tokenType = identityModel.tokenType;
          coin.token = identityModel.token;
          coin.mnemonic = identityModel.mnemonic;
          coin.keystore = identityModel.keystore;
          coin.publicKey = "";
          coin.privateKey = identityModel.privateKey;
          coin.address = address;
          await DatabaseUtil.create().insertCoin(coin);
          descAddresses.add(coin.symbol!.toDescAddress(address));
        }
      }
    } else if (identityModel.tokenType == "keystore") {
      for (int i = 0; i < chains.length; i++) {
        CoinModel coin = chains[i];
        if (coin.contract!.toUpperCase() == "TRX") {
          if (identityModel.privateKeyTrx?.isEmptyString()) {
            identityModel.privateKeyTrx = identityModel.privateKey;
            await DatabaseUtil.create().updateIdentity(identityModel);
          }
          String privateKey = await CommonUtil.decrypt(identityModel.privateKeyTrx!, pass);
          AccountChain chain = getChain("TRX")!;
          String address = await chain.getAddress(privateKey: privateKey);

          coin.wid = identityModel.wid;
          coin.tokenType = identityModel.tokenType;
          coin.token = identityModel.token;
          coin.mnemonic = identityModel.mnemonic;
          coin.keystore = identityModel.keystore;
          coin.publicKey = "";
          coin.privateKey = identityModel.privateKeyTrx;
          coin.address = address;
          await DatabaseUtil.create().insertCoin(coin);
          descAddresses.add(coin.symbol!.toDescAddress(address));
        } else {
          String privateKey = await CommonUtil.decrypt(identityModel.privateKey!, pass);
          AccountChain chain = getChain("ETH")!;
          String address = await chain.getAddress(privateKey: privateKey);

          coin.wid = identityModel.wid;
          coin.tokenType = identityModel.tokenType;
          coin.token = identityModel.token;
          coin.mnemonic = identityModel.mnemonic;
          coin.keystore = identityModel.keystore;
          coin.publicKey = "";
          coin.privateKey = identityModel.privateKey;
          coin.address = address;
          await DatabaseUtil.create().insertCoin(coin);
          descAddresses.add(coin.symbol!.toDescAddress(address));
        }
      }
    } else {
      for (int i = 0; i < chains.length; i++) {
        CoinModel coin = chains[i];
        if (coin.contract!.toUpperCase() == "TRX") {
          if (identityModel.privateKeyTrx?.isEmptyString()) {
            identityModel.privateKeyTrx = identityModel.privateKey;
            await DatabaseUtil.create().updateIdentity(identityModel);
          }
          String privateKey = await CommonUtil.decrypt(identityModel.privateKeyTrx!, pass);
          AccountChain chain = getChain("TRX")!;
          String address = await chain.getAddress(privateKey: privateKey);

          coin.wid = identityModel.wid;
          coin.tokenType = identityModel.tokenType;
          coin.token = identityModel.token;
          coin.mnemonic = identityModel.mnemonic;
          coin.keystore = identityModel.keystore;
          coin.publicKey = "";
          coin.privateKey = identityModel.privateKeyTrx;
          coin.address = address;
          await DatabaseUtil.create().insertCoin(coin);
          descAddresses.add(coin.symbol!.toDescAddress(address));
        } else {
          String privateKey = await CommonUtil.decrypt(identityModel.privateKey!, pass);
          AccountChain chain = getChain("ETH")!;
          String address = await chain.getAddress(privateKey: privateKey);

          coin.wid = identityModel.wid;
          coin.tokenType = identityModel.tokenType;
          coin.token = identityModel.token;
          coin.mnemonic = identityModel.mnemonic;
          coin.keystore = identityModel.keystore;
          coin.publicKey = "";
          coin.privateKey = identityModel.privateKey;
          coin.address = address;
          await DatabaseUtil.create().insertCoin(coin);
          descAddresses.add(coin.symbol!.toDescAddress(address));
        }
      }
    }
    if (needRequest) {
      ApiData apiData = await ApiManager.postWalletCreate(data:{
        "wid": identityModel.wid,
        "chains": descAddresses.join(","),
      });
      if (apiData.code == 0) {

      } else {
        return Future.value([]);
      }
    }
    return Future.value(descAddresses);
  }

}