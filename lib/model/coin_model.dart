import 'package:abey_wallet/model/attribute_model.dart';
import 'package:abey_wallet/extension/map_extension.dart';

class CoinModel {
  int? id;
  String? wid = "";
  String? color = "";
  String? address = "";
  String? publicKey = "";
  String? token = "";
  String? tokenType = "";
  String? mnemonic = "";
  String? keystore = "";
  String? privateKey = "";

  String? symbol = "";
  String? name = "";
  String? contract = "";
  String? contractAddress = "";
  String? chainName = "";
  String? icon = "";
  String? balance = "";
  String? price = "";
  String? totalPrice = "";
  String? value = "";
  String? extra = "";
  String? note = "";
  String? description = "";

  bool? showUserAllCoins = false;
  String? detail = "";
  String? status = "";
  String? csUnit = "";

  String? tokenID = "";
  String? netUsed = "";
  String? netLimit = "";
  String? energyUsed = "";
  String? energyLimit = "";

  String? mainValue = "";
  String? floorPrice = "";
  String? img = "";
  String? madeby = "";
  List<AttributeModel>? attributes = <AttributeModel>[];

  bool? selected = false;
  bool? canAction=true;
  bool? isHas = false;

  String? assetName = "";

  CoinModel({
    this.id,
    this.wid = "",
    this.color = "",
    this.address = "",
    this.publicKey = "",
    this.token = "",
    this.tokenType = "",
    this.mnemonic = "",
    this.keystore = "",
    this.privateKey = "",

    this.symbol = "",
    this.name = "",
    this.contract = "",
    this.contractAddress = "",
    this.chainName = "",
    this.icon = "",
    this.balance = "",
    this.price = "",
    this.totalPrice = "",
    this.value = "",
    this.extra = "",
    this.note = "",
    this.description = "",

    this.showUserAllCoins = false,
    this.detail = "",
    this.status = "",
    this.csUnit = "",

    this.tokenID = "",
    this.netUsed = "",
    this.netLimit = "",
    this.energyUsed = "",
    this.energyLimit = "",

    this.mainValue = "",
    this.floorPrice = "",
    this.img = "",
    this.madeby = "",
    this.attributes,

    this.selected = false,
    this.canAction = false,
    this.isHas = false,

    this.assetName = "",
  });

  CoinModel.fromJson(Map<String, dynamic> obj) {
    if (obj["id"] != null) this.id = obj['id'];
    if (obj["wid"] != null) this.wid = obj['wid'];
    if (obj["color"] != null) this.color = obj['color'];
    if (obj["address"] != null) this.address = obj['address'];
    if (obj["publicKey"] != null) this.publicKey = obj['publicKey'];
    if (obj["token"] != null) this.token = obj['token'];
    if (obj["tokenType"] != null) this.tokenType = obj['tokenType'];
    if (obj["mnemonic"] != null) this.mnemonic = obj['mnemonic'];
    if (obj["keystore"] != null) this.keystore = obj['keystore'];
    if (obj["privateKey"] != null) this.privateKey = obj['privateKey'];

    if (obj["symbol"] != null) this.symbol = obj['symbol'];
    if (obj["name"] != null) this.name = obj['name'];
    if (obj["contract"] != null) this.contract = obj['contract'];
    if (obj["contractAddress"] != null) this.contractAddress = obj['contractAddress'];
    if (obj["chainName"] != null) this.chainName = obj['chainName'];
    if (obj["icon"] != null) this.icon = obj['icon'];
    if (obj["balance"] != null) this.balance = obj['balance'];
    if (obj["price"] != null) this.price = obj.value2Str('price');
    if (obj["totalPrice"] != null) this.totalPrice = obj['totalPrice'];
    if (obj["value"] != null) this.value = obj['value'];
    if (obj["extra"] != null) this.extra = obj['extra'];
    if (obj["note"] != null) this.note = obj['note'];
    if (obj["description"] != null) this.description = obj['description'];

    if (obj["showUserAllCoins"] != null) this.showUserAllCoins = obj['showUserAllCoins'];
    if (obj["detail"] != null) this.detail = obj['detail'];
    if (obj["status"] != null) this.status = obj.value2Str('status');
    if (obj["csUnit"] != null) this.csUnit = obj['csUnit'];

    if (obj["tokenID"] != null) this.tokenID = obj['tokenID'].toString();
    if (obj["netUsed"] != null) this.netUsed = obj['netUsed'];
    if (obj["netLimit"] != null) this.netLimit = obj['netLimit'];
    if (obj["energyUsed"] != null) this.energyUsed = obj['energyUsed'];
    if (obj["energyLimit"] != null) this.energyLimit = obj['energyLimit'];

    if (obj["mainValue"] != null) this.mainValue = obj['mainValue'];
    if (obj["floorPrice"] != null) this.floorPrice = obj['floorPrice'];
    if (obj["img"] != null) this.img = obj['img'];
    if (obj["madeby"] != null) this.madeby = obj['madeby'];
    if (obj["attributes"] != null) this.attributes = obj['attributes'];

    if (obj["selected"] != null) this.selected = obj['selected'];
    if (obj["canAction"] != null) this.canAction = obj['canAction'];
    if (obj["isHas"] != null) {
      this.isHas = obj['isHas'] == 1;
    };

    if (obj["assetName"] != null) this.assetName = obj['assetName'];
  }

  Map<String, dynamic> toJson({bool excludeId = true}) {
    final Map<String, dynamic> data = new Map();
    if (excludeId == false) {
      data["id"] = this.id;
    }
    data["wid"] = this.wid;
    data["color"] = this.color;
    data["address"] = this.address;
    data["publicKey"] = this.publicKey;
    data["token"] = this.token;
    data["tokenType"] = this.tokenType;
    data["mnemonic"] = this.mnemonic;
    data["keystore"] = this.keystore;
    data["privateKey"] = this.privateKey;

    data["symbol"] = this.symbol;
    data["name"] = this.name;
    data["contract"] = this.contract;
    data["contractAddress"] = this.contractAddress;
    data["chainName"] = this.chainName;
    data["icon"] = this.icon;
    data["balance"] = this.balance;
    data["price"] = this.price;
    data["totalPrice"] = this.totalPrice;
    data["value"] = this.value;
    data["extra"] = this.extra;
    data["note"] = this.note;
    data["description"] = this.description;
    return data;
  }

}