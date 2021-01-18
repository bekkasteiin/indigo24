class PaymentsService {
  int id;
  String logo;
  double commission;
  String title;
  bool isConvertable;
  int providerId;

  PaymentsService({
    this.id,
    this.logo,
    this.commission,
    this.title,
    this.isConvertable,
    this.providerId,
  });

  @override
  String toString() {
    return ''' 
    'id' : $id,
    'logo' : $logo,
    'commission' : $commission,
    'title' : $title,
    'isConvertable' : $isConvertable,
    'providerId' : $providerId,
    ''';
  }

  PaymentsService.fromJson(Map json)
      : id = json['id'],
        logo = json['logo'],
        commission = double.tryParse(json['commission'].toString()),
        title = json['title'],
        isConvertable = json['is_convertable'] == 1 ? true : false,
        providerId = json['provider_id'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'logo': logo,
      'commission': commission,
      'title': title,
      'is_convertable': isConvertable ? 1 : 0,
      'provider_id': providerId,
    };
  }
}
