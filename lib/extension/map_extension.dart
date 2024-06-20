extension MapExtension on Map<String, dynamic> {
  value2Str(String key) {
    var value = this[key];
    try {
      if (value is String) {
        return value;
      }
      if (value == null) {
        return '';
      }
      if (value == 'null') {
        return '';
      }
      return value.toString();
    } catch (e) {
      return '';
    }
  }

  value2Num(String key) {
    var value = this[key];
    if (value == null) {
      return 0;
    }
    try {
      if (value is String) {
        return num.parse(value);
      }
      if (value is num) {
        return value;
      }
    } catch (e) {
      return 0;
    }
    return 0;
  }

  value2Int(key) {
    var value = this[key];
    if (value == null) {
      return 0;
    }
    try {
      if (value is String) {
        return int.parse(value);
      }
      if (value is int) {
        return value;
      }
    } catch (e) {
      return 0;
    }
    return 0;
  }

  value2Bool(key) {
    var value = this[key];
    if (value == null) {
      return false;
    }
    try {
      if (value is bool) {
        return value;
      }
      if (value is String) {
        return value=='true';
      }
      if (value is num) {
        return value>0;
      }
    } catch (e) {
    }
    return false;
  }

  value2List(key) {
    var value = this[key];
    if (value == null) {
      return [];
    }
    try {
      if (value is List) {
        return value;
      }
    } catch (e) {
    }
    return [];
  }
}
