class NameValueModel {
  String? name = "";
  String? value = "";

  NameValueModel({this.name = "", this.value = ""});

  NameValueModel.fromJson(dynamic obj) {
    if(obj["name"] != null) this.name = obj['name'];
    if(obj["value"] != null) this.value = obj['value'];
  }
}