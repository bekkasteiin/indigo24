class Country {
  int id;
  int length;
  String title;
  String mask;
  String icon;
  String phonePrefix;
  String code;

  Country(int id, int length, String name, String phonePrefix, String code,
      String mask, String icon) {
    this.id = id;
    this.length = length;
    this.title = name;
    this.phonePrefix = phonePrefix;
    this.code = code;
    this.mask = mask;
    this.icon = icon;
  }

  @override
  String toString() {
    return '''   'id': $id,
      'length': $length,
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
        phonePrefix = json['phonePrefix'],
        code = json['code'],
        mask = json['mask'],
        icon = json['icon'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'length': length,
      'title': title,
      'phonePrefix': phonePrefix,
      'code': code,
      'mask': mask,
      'icon': icon,
    };
  }
}
