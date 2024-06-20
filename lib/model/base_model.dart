class Parser {
  void parser(Map<String, dynamic> data) {}
}

abstract class BaseModel implements Parser {
  Map<String, dynamic>? map;

  BaseModel();

  BaseModel parser(Map<String, dynamic> map) {
    this.map = map;
    if (this.map != null) {
      parserImpl(this.map);
    }
    return this;
  }

  void parserImpl(Map<String, dynamic>? map);

  Map<String, dynamic>? toMap() {
    return this.map;
  }
}