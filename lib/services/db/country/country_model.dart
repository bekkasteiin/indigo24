class Country {
  int id;
  int length;
  int min;
  int max;
  String title;
  String mask;
  String icon;
  String phonePrefix;
  String code;

  Country(int id, int length, int min, int max, String name, String phonePrefix,
      String code, String mask, String icon) {
    this.id = id;
    this.length = length;
    this.title = name;
    this.phonePrefix = phonePrefix;
    this.code = code;
    this.mask = mask;
    this.icon = icon;
    this.min = min;
    this.max = max;
  }

  @override
  String toString() {
    return '''   'id': $id,
      'length': $length,
      'min': $min,
      'max: $max,
      'title': $title,
      'phonePrefix': $phonePrefix,
      'code': $code,
      'mask': $mask,
      'icon': $icon, ''';
  }

  Country.fromJson(Map json)
      : id = json['id'],
        length = json['length'],
        title = json['title'],
        min = json['min'],
        max = json['max'],
        phonePrefix = json['phonePrefix'],
        code = json['code'],
        mask = json['mask'],
        icon = json['icon'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'length': length,
      'min': min,
      'max': max,
      'title': title,
      'phonePrefix': phonePrefix,
      'code': code,
      'mask': mask,
      'icon': icon,
    };
  }
}
