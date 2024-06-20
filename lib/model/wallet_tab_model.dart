class WalletTabModel {
  String? name = "";
  String? key = "";
  String? message = "";

  WalletTabModel({this.name = "",this.key = "",this.message = ""});

  WalletTabModel.fromJson(dynamic obj) {
    if (obj["name"] != null) this.name = obj['name'];
    if (obj["key"] != null) this.key = obj['key'];
    if (obj["message"] != null) this.message = obj['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map();
    data["name"] = this.name;
    data["key"] = this.key;
    data["message"] = this.message;
    return data;
  }
}