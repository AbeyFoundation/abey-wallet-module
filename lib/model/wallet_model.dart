class WalletListModel {
  List<WalletModel>? items = <WalletModel>[];

  WalletListModel({this.items});

  WalletListModel.fromJson(dynamic obj) {
    if (obj != null) {
      items = <WalletModel>[];
      if (obj["items"] != null) {
        obj["items"].forEach((v) {
          items?.add(new WalletModel.fromJson(v));
        });
      }
    }
  }
}

class WalletIosListModel {
  List<WalletModel>? walletArray;

  WalletIosListModel({this.walletArray});

  WalletIosListModel.fromJson(dynamic obj) {
    if (obj != null) {
      walletArray = <WalletModel>[];
      if (obj["walletArray"] != null) {
        obj["walletArray"].forEach((v) {
          walletArray?.add(new WalletModel.fromJson(v));
        });
      }
    }
  }
}



class WalletModel {
  int? id;
  String? chain = "";
  String? name = "";
  String? password = "";
  String? address = "";
  String? mnemonic = "";
  String? privateKey = "";

  WalletModel({
    this.id,
    this.chain = "",
    this.name = "",
    this.address = "",
    this.password = "",
    this.mnemonic = "",
    this.privateKey = "",
  });

  WalletModel.fromJson(Map<String, dynamic> obj) {
    if (obj["id"] != null) this.id = obj['id'];
    if (obj["chain"] != null) this.chain = obj['chain'];
    if (obj["name"] != null) this.name = obj['name'];
    if (obj["address"] != null) this.address = obj['address'];
    if (obj["password"] != null) this.password = obj['password'];
    if (obj["mnemonic"] != null) this.mnemonic = obj['mnemonic'];
    if (obj["privateKey"] != null) this.privateKey = obj['privateKey'];
  }

  Map<String, dynamic> toJson({bool excludeId = true}) {
    final Map<String, dynamic> data = new Map();
    if (excludeId == false) {
      data["id"] = this.id;
    }
    data["chain"] = this.chain;
    data["name"] = this.name;
    data["address"] = this.address;
    data["password"] = this.password;
    data["mnemonic"] = this.mnemonic;
    data["privateKey"] = this.privateKey;

    return data;
  }

}