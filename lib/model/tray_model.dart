class TrayModel {
  int? id;
  String? KEY = "";
  String? VALUE = "";

  TrayModel({
    this.id,
    this.VALUE = "",
    this.KEY = "",
  });

  TrayModel.fromJson(Map<String, dynamic> obj) {
    if (obj["id"] != null) this.id = obj['id'];
    if (obj["VALUE"] != null) this.VALUE = obj['VALUE'];
    if (obj["KEY"] != null) this.KEY = obj['KEY'];
  }

  Map<String, dynamic> toJson({bool excludeId = true}) {
    final Map<String, dynamic> data = new Map();
    if (excludeId == false) {
      data["id"] = this.id;
    }
    data["VALUE"] = this.VALUE;
    data["KEY"] = this.KEY;

    return data;
  }

}