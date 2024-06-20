class AttributeModel {
  String? name = "";
  String? value = "";

  AttributeModel({this.name = "",this.value = ""});

  AttributeModel.fromJson(dynamic obj) {
    if (obj["name"] != null) this.name = obj['name'];
    if (obj["value"] != null) this.value = obj['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map();
    data["name"] = this.name;
    data["value"] = this.value;
    return data;
  }
}