class PaymentCategory {
  int id;
  String logo;
  String title;
  int count;
  dynamic locationType;
  PaymentCategory({
    this.id,
    this.logo,
    this.title,
    this.count,
    this.locationType,
  });

  @override
  String toString() {
    return ''' 
    'id' : $id,
    'logo' : $logo,
    'title' : $title,
    'count' : $count,
    'locationType' : $locationType,
    ''';
  }

  PaymentCategory.fromJson(Map json)
      : id = json['ID'],
        logo = json['logo'],
        title = json['title'],
        count = json['count'],
        locationType = json['location_type'];

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'logo': logo,
      'title': title,
      'count': count,
      'location_type': locationType,
    };
  }
}
