class ChatsModel {
  var id;
  var name;
  var avatar;
  var type;
  var membersCount;
  var unreadMessage;
  var phone;
  var lastMessage;

  ChatsModel({
    this.id,
    this.name,
    this.avatar,
    this.type,
    this.membersCount,
    this.unreadMessage,
    this.phone,
    this.lastMessage
  });

  factory ChatsModel.fromJson(Map<String, dynamic> json) => ChatsModel(
    id: json["id"],
    name: json["name"],
    avatar: json["avatar"],
    type: json["type"],
    membersCount: json["members_count"],
    unreadMessage: json["unread_messages"],
    phone: json["phone"],
    lastMessage: json["last_message"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "avatar": avatar,
    "type": type,
    "members_count": membersCount,
    "unread_messages": unreadMessage,
    "phone": phone,
    "last_message": lastMessage,
  };


  @override
  String toString() {
    return """{
      "id": $id,
      "name": $name,
      "avatar": $avatar,
      "type": $type,
      "membersCount": $membersCount,
      "unreadMessage": $unreadMessage,
      "phone": $phone,
      "lastMessage": $lastMessage
    }""";
  }
}