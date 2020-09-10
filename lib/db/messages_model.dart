class MessagesModel {
  var id;
  var name;
  var avatar;
  var type;
  var membersCount;
  var unreadMessage;
  var phone;
  var lastMessage;
  var anotherUserID;
  var time;
  MessagesModel(
      {this.id,
      this.name,
      this.avatar,
      this.type,
      this.membersCount,
      this.unreadMessage,
      this.phone,
      this.lastMessage,
      this.anotherUserID,
      this.time});

  factory MessagesModel.fromJson(Map<String, dynamic> json) => MessagesModel(
      id: json["id"],
      name: json["name"],
      avatar: json["avatar"],
      type: json["type"],
      membersCount: json["members_count"],
      unreadMessage: json["unread_messages"],
      phone: json["phone"],
      lastMessage: json["last_message"],
      anotherUserID: json["another_user_id"],
      time: int.parse(json["time"].toString()));

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "avatar": avatar,
        "type": type,
        "members_count": membersCount,
        "unread_messages": unreadMessage,
        "phone": phone,
        "last_message": lastMessage,
        "another_user_id": anotherUserID,
        "time": time
      };

  @override
  String toString() {
    return """{
      "id": $id,
      "name": $name,
      "avatar": $avatar,
      "type": $type,
      "members_count": $membersCount,
      "unread_message": $unreadMessage,
      "phone": $phone,
      "last_message": $lastMessage,
      "another_user_id": $anotherUserID,
      "time": $time
    }""";
  }
}
