import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:indigo24/pages/chat/chat.dart';
import 'package:indigo24/pages/chat/chat_page_view_test.dart';
import 'package:indigo24/pages/chat/chat_user_profile.dart';
import 'package:indigo24/pages/chat/ui/replyMessage.dart';
import 'package:indigo24/pages/tapes/tapes.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/widgets/linkMessage.dart';
import 'package:indigo24/widgets/video_player_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:indigo24/services/localization.dart' as localization;

var parser = EmojiParser();

class Received extends StatelessWidget {
  final m;
  final chatId;
  final bool isGroup;
  Received(this.m, {this.chatId, this.isGroup});
  @override
  Widget build(BuildContext context) {
    var a = (m['attachments'] == false || m['attachments'] == null)
        ? false
        : jsonDecode(m['attachments']);
    var replyData = (m['reply_data'] == false || m['reply_data'] == null)
        ? false
        : m['reply_data'];

    return Align(
        alignment: Alignment(-1, 0),
        child: Container(
            child: CupertinoContextMenu(
          actions: [
            // CupertinoContextMenuAction(
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       const Text('Удалить', style: TextStyle(color:Colors.red, fontSize: 14),),
            //       const Icon(CupertinoIcons.delete, color: Colors.red, size: 20)
            //     ],
            //   ),
            //   onPressed: () {
            //     ChatRoom.shared.deleteFromAll(chatId, m['id']==null?m['message_id']:m['id']);
            //     Navigator.pop(context);
            //   },
            // ),
            // CupertinoContextMenuAction(
            //   child: Container(
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       children: [
            //         const Text('Редактировать', style: TextStyle(fontSize: 14)),
            //         const Icon(CupertinoIcons.pen, size: 20,)
            //       ],
            //     ),
            //   ),
            //   onPressed: () {
            //     Navigator.pop(context);
            //   },
            // ),
            CupertinoContextMenuAction(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('${localization.reply}', style: TextStyle(fontSize: 14)),
                  Icon(CupertinoIcons.reply_thick_solid, size: 20)
                ],
              ),
              onPressed: () {
                ChatRoom.shared.replyingMessage(m);
                Navigator.pop(context);
              },
            ),
          ],
          child: Material(
            color: Colors.transparent,
            child: ReceivedMessageWidget(
                phone: "${m['phone']}",
                content: '${m['text']}',
                time: time('${m['time']}'),
                name: '${m['user_name']}',
                image: (m["avatar"] == null || m["avatar"] == "")
                    ? "${avatarUrl}noAvatar.png"
                    : m["avatar_url"] == null
                        ? "$avatarUrl${m["avatar"].toString().replaceAll("AxB", "200x200")}"
                        : "${m["avatar_url"]}${m["avatar"].toString().replaceAll("AxB", "200x200")}",
                type: "${m["type"]}",
                media: (a == false || a == null)
                    ? null
                    : "${m["type"]}" == '12' ? a[0]['link'] : a[0]['filename'],
                rMedia: (a == false || a == null)
                    ? null
                    : a[0]['r_filename'] == null
                        ? a[0]['filename']
                        : a[0]['r_filename'],
                mediaUrl:
                    (a == false || a == null) ? null : m['attachment_url'],
                edit: "${m["edit"]}",
                isGroup: isGroup,
                replyData: (replyData == false || replyData == null)
                    ? null
                    : replyData),
          ),
        )));
  }

  String time(timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(
      int.parse(timestamp) * 1000,
    );
    TimeOfDay roomBooked = TimeOfDay.fromDateTime(DateTime.parse('$date'));
    var hours;
    var minutes;
    hours = '${roomBooked.hour}';
    minutes = '${roomBooked.minute}';

    if (roomBooked.hour.toString().length == 1) hours = '0${roomBooked.hour}';
    if (roomBooked.minute.toString().length == 1)
      minutes = '0${roomBooked.minute}';
    return '$hours:$minutes';
  }
}

class ReceivedMessageWidget extends StatelessWidget {
  final String content;
  final String time;
  final String image;
  final String name;
  final String media;
  final String mediaUrl;
  final String rMedia;
  final String type;
  final String edit;
  final bool isGroup;
  final phone;
  final replyData;

  const ReceivedMessageWidget(
      {Key key,
      this.phone,
      this.content,
      this.time,
      this.image,
      this.name,
      this.media,
      this.mediaUrl,
      this.rMedia,
      this.type,
      this.edit,
      this.isGroup,
      this.replyData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var a = parser.unemojify(content);
    int l = a.length - 1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        SizedBox(width: 5),
        isGroup
            ? InkWell(
                onTap: () {
                  ChatRoom.shared.cabinetController.close();
                  ChatRoom.shared.setCabinetInfoStream();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatUserProfilePage(
                        '100',
                        email: 'email',
                        image: image,
                        name: name,
                        phone: phone,
                      ),
                    ),
                  ).whenComplete(() {
                    ChatRoom.shared.closeCabinetInfoStream();
                  });
                },
                child: CircleAvatar(
                  backgroundImage: NetworkImage(image),
                  child: ClipOval(
                    child: CachedNetworkImage(
                        imageUrl: image,
                        errorWidget: (context, url, error) =>
                            CachedNetworkImage(
                                imageUrl: "${avatarUrl}noAvatar.png")),
                  ),
                ),
              )
            : Container(),
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: edit == '1' ? 150.0 : 130.0,
            ),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.only(
                    right: 75.0, left: 8.0, top: 8.0, bottom: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(15),
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  child: Container(
                    color: Color(0xFFFFFFFF),
                    child: Stack(children: <Widget>[
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          isGroup
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      right: 8.0,
                                      left: 8.0,
                                      top: 5.0,
                                      bottom: 0.0),
                                  child: Text(name,
                                      style: TextStyle(
                                          color: Colors.amber,
                                          fontWeight: FontWeight.w500)),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                ),
                          Padding(
                            padding: EdgeInsets.only(
                                right: (type == "3") ? 5 : 8.0,
                                left: (type == "3") ? 2 : 8.0,
                                top: 0.0,
                                bottom: (type == "3") ? 1 : 15.0),
                            child: (type == "12")
                                ? LinkMessage("$media")
                                : (a[0] == ":" &&
                                        a[l] == ":" &&
                                        content.length < 9)
                                    ? Text(content,
                                        style: TextStyle(fontSize: 40))
                                    : (a[0] == ":" &&
                                            a[l] == ":" &&
                                            content.length > 8)
                                        ? Text(content,
                                            style: TextStyle(fontSize: 24))
                                        : (type == "1")
                                            ? (() {
                                                listMessages.forEach((element) {
                                                  if (element['type']
                                                          .toString() ==
                                                      '1') {
                                                    imageCount.add(element);
                                                    test = element;
                                                  }
                                                });
                                                return ImageMessage(
                                                    "$mediaUrl$rMedia",
                                                    "$mediaUrl$media",
                                                    imageCount: imageCount
                                                        .indexOf(test));
                                              }())
                                            : (type == "2")
                                                ? FileMessage(
                                                    url: "$mediaUrl$media")
                                                : (type == "3")
                                                    ? new AudioMessage(
                                                        "$mediaUrl$media")
                                                    : (type == "4")
                                                        ? Container(
                                                            child: VideoPlayerWidget(
                                                                "$mediaUrl$media",
                                                                "network"))
                                                        : (type == "10")
                                                            ? ReplyMessage(
                                                                content,
                                                                replyData)
                                                            :
                                                            // TODO CHANGE
                                                            type == '11'
                                                                ? Text(
                                                                    '${localization.money} $content')
                                                                // MoneyMessage(content)
                                                                : Text(
                                                                    content,
                                                                  ),
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 1,
                        right: 10,
                        child: Row(
                          children: [
                            edit == '1'
                                ? Text(
                                    "${localization.editedMessage}. ",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black.withOpacity(0.6),
                                    ),
                                  )
                                : Container(),
                            Text(
                              time,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      )
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
