class TransferModel {
  int id;
  double amount;
  String avatar;
  String data;
  String from;
  int to;
  String type;
  String name;
  String phone;
  String pdf;
  String comment;

  TransferModel(
    int id,
    double amount,
    String avatar,
    String data,
    String from,
    int to,
    String type,
    String name,
    String phone,
    String pdf,
    String comment,
  ) {
    this.id = id;
    this.amount = amount;
    this.avatar = avatar;
    this.data = data;
    this.from = from;
    this.to = to;
    this.type = type;
    this.name = name;
    this.phone = phone;
    this.pdf = pdf;
    this.comment = comment;
  }

  @override
  String toString() {
    return ''''id' : $id,
'amount' : $amount,
'avatar' : $avatar,
'data' : $data,
'from' : $from,
'to' : $to,
'type' : $type,
'name' : $name,
'phone' : $phone,
'pdf' : $pdf,
'comment' : $comment,
''';
  }

  TransferModel.fromJson(Map json)
      : id = json['id'],
        amount = double.parse(json['amount'].toString()),
        avatar = json['avatar'],
        data = json['data'],
        from = json['from'],
        to = json['to'],
        type = json['type'],
        name = json['name'],
        phone = json['phone'],
        pdf = json['pdf'],
        comment = json['comment'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'avatar': avatar,
      'data': data,
      'from': from,
      'to': to,
      'type': type,
      'name': name,
      'phone': phone,
      'pdf': pdf,
      'comment': comment,
    };
  }
}
