class MyTape {
  // var avatar;
  // var commentsCount;
  // var created;
  // var description;
  bool isBlocked = false;
  var id;
  // var likes = [];
  // var likesCount;
  // var media;
  // var myLike;
  // var name;
  // var title;
  // var type;

  MyTape({
    this.id,
    this.isBlocked,
    // this.commentsCount,
    // this.avatar,
    // this.created,
    // this.description,
    // this.likes,
    // this.likesCount,
    // this.media,
    // this.myLike,
    // this.name,
    // this.title,
    // this.type,
  });

  factory MyTape.fromJson(Map<String, dynamic> json) => MyTape(
        id: json["id"],
        isBlocked: json['isBlocked'],
        //   commentsCount: json["commentsCount"],
        //   avatar: json["avatar"],
        //   created: json["created"],
        //   description: json["description"],
        //   likes: json["likes"].toList(),
        //   likesCount: json["likesCount"],
        //   media: json["media"],
        //   myLike: json["myLike"],
        //   name: json["name"],
        //   title: json["title"],
        //   type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "isBlocked": isBlocked,
        // commentsCount: commentsCount,
        // avatar: avatar,
        // created: created,
        // description: description,
        // likes: likes,
        // likesCount: likesCount,
        // media: media,
        // myLike: myLike,
        // name: name,
        // title: title,
        // type: type,
      };
}
