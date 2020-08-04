class MyContact {
  var id;
  var name;
  var avatar;
  var phone;
  var chatId;
  var online;
  MyContact(
      {this.id, this.name, this.avatar, this.phone, this.chatId, this.online});

  factory MyContact.fromJson(Map<String, dynamic> json) => MyContact(
        id: json["id"],
        name: json["name"],
        avatar: json["avatar"],
        phone: json["phone"],
        chatId: json["chatId"],
        online: json["online"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "avatar": avatar,
        "phone": phone,
        "chatId": chatId,
        "online": online,
      };

  @override
  String toString() {
    return """{
      "id": $id,
      "name": $name,
      "avatar": $avatar,
      "phone": $phone,
      "chatId": $chatId,
      "online": $online,
    }""";
  }
}
