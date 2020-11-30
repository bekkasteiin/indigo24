class PaymentHistoryModel {
  String account;
  double amount;
  String data;
  String logo;
  String status;
  String title;
  int serviceId;

  PaymentHistoryModel(
    String account,
    double amount,
    String data,
    String logo,
    String status,
    String title,
    int serviceId,
  ) {
    this.account = account;
    this.amount = amount;
    this.data = data;
    this.logo = logo;
    this.status = status;
    this.title = title;
    this.serviceId = serviceId;
  }

  @override
  String toString() {
    return ''' 
    'account' : $account,
    'amount' : $amount,
    'data' : $data,
    'logo' : $logo,
    'status' : $status,
    'title' : $title,
    'serviceId' : $serviceId
    ''';
  }

  PaymentHistoryModel.fromJson(Map json)
      : account = json['account'].toString(),
        amount = double.parse(json['amount'].toString()),
        data = json['data'],
        logo = json['logo'],
        status = json['status'].toString(),
        title = json['title'],
        serviceId = json['serviceID'];

  Map<String, dynamic> toJson() {
    return {
      'account': account,
      'amount': amount,
      'data': data,
      'logo': logo,
      'status': status,
      'title': title,
      'serviceId': serviceId,
    };
  }
}
