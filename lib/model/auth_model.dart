class AuthModel {
  int? id;
  String? type = "";
  String? password = "";
  String? touchId = "";
  String? faceId = "";

  AuthModel({this.id,this.type = "",this.password = "",this.touchId = "",this.faceId = ""});

  AuthModel.fromJson(dynamic obj) {
    if (obj["id"] != null) this.id = obj['id'];
    if (obj["type"] != null) this.type = obj['type'];
    if (obj["password"] != null) this.password = obj['password'];
    if (obj["touchId"] != null) this.touchId = obj['touchId'];
    if (obj["faceId"] != null) this.faceId = obj['faceId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map();
    data["id"] = this.id;
    data["type"] = this.type;
    data["password"] = this.password;
    data["touchId"] = this.touchId;
    data["faceId"] = this.faceId;
    return data;
  }

}