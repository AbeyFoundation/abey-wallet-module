class IdentityModel {
  int? id;
  String? wid = "";
  String? name = "";
  String? scope = "";
  int? type = 0;
  String? tokenType = "";
  String? token = "";
  String? mnemonic = "";
  String? keystore = "";
  String? privateKey = "";
  String? privateKeyTrx = "";

  String? color = "";
  int? isBackup = 0;

  IdentityModel({
    this.id,
    this.wid = "",
    this.name = "",
    this.scope = "",
    this.type = 0,
    this.tokenType = "",
    this.token = "",
    this.mnemonic = "",
    this.keystore = "",
    this.privateKey = "",
    this.privateKeyTrx = "",
    this.color = "",
    this.isBackup = 0,
  });

  IdentityModel.fromJson(dynamic obj) {
    if (obj["id"] != null) {
      if (obj["id"] is String) {
        this.id = int.parse(obj['id']);
      } else {
        this.id = obj['id'];
      }
    };
    if (obj["wid"] != null) this.wid = obj['wid'];
    if (obj["name"] != null) this.name = obj['name'];
    if (obj["scope"] != null) this.scope = obj['scope'];
    if (obj["type"] != null) this.type = obj['type'];
    if (obj["tokenType"] != null) this.tokenType = obj['tokenType'];
    if (obj["token"] != null) this.token = obj['token'];
    if (obj["mnemonic"] != null) this.mnemonic = obj['mnemonic'];
    if (obj["keystore"] != null) this.keystore = obj['keystore'];
    if (obj["privateKey"] != null) this.privateKey = obj['privateKey'];
    if (obj["privateKeyTrx"] != null) this.privateKeyTrx = obj['privateKeyTrx'];
    if (obj["color"] != null) this.color = obj['color'];
    if (obj["isBackup"] != null) this.isBackup = obj['isBackup'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map();
    data["id"] = this.id;
    data["wid"] = this.wid;
    data["name"] = this.name;
    data["scope"] = this.scope;
    data["type"] = this.type;
    data["tokenType"] = this.tokenType;
    data["token"] = this.token;
    data["mnemonic"] = this.mnemonic;
    data["keystore"] = this.keystore;
    data["privateKey"] = this.privateKey;
    data["privateKeyTrx"] = this.privateKeyTrx;
    data["color"] = this.color;
    data["isBackup"] = this.isBackup;
    return data;
  }

}