import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:indigo24/pages/chat/chat.dart';
import 'package:indigo24/pages/chat/chat_page_view_test.dart';
import 'package:indigo24/pages/chat/ui/replyMessage.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/linkMessage.dart';
import 'package:indigo24/widgets/video_player_widget.dart';
import 'package:indigo24/services/localization.dart' as localization;

class Sended extends StatelessWidget {
  final m;
  final chatId;

  Sended(this.m, {this.chatId});

  @override
  Widget build(BuildContext context) {
    var a = (m['attachments'] == false ||
            m['attachments'] == null ||
            m['attachments'] == '')
        ? false
        : jsonDecode(m['attachments']);
    var replyData = (m['reply_data'] == false || m['reply_data'] == null)
        ? false
        : m['reply_data'];

    var forwarData =
        ('${m['forward_data']}' == 'false' || '${m['forward_data']}' == 'null')
            ? false
            : jsonDecode(m['forward_data']);
    return Align(
      alignment: Alignment(1, 0),
      child: Container(
        child: CupertinoContextMenu(
          actions: [
            CupertinoContextMenuAction(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${localization.delete}',
                    style: TextStyle(color: redColor, fontSize: 14),
                  ),
                  Icon(CupertinoIcons.delete, color: redColor, size: 20)
                ],
              ),
              onPressed: () {
                ChatRoom.shared.deleteFromAll(
                    chatId, m['id'] == null ? m['message_id'] : m['id']);
                Navigator.pop(context);
              },
            ),
            CupertinoContextMenuAction(
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${localization.edit}',
                      style: TextStyle(fontSize: 14),
                    ),
                    Icon(
                      CupertinoIcons.pen,
                      size: 20,
                    )
                  ],
                ),
              ),
              onPressed: () {
                ChatRoom.shared.editingMessage(m);
                Navigator.pop(context);
              },
            ),
            CupertinoContextMenuAction(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('${localization.forward}',
                      style: TextStyle(fontSize: 14)),
                  Icon(CupertinoIcons.reply_thick_solid, size: 20)
                ],
              ),
              onPressed: () {
                // ChatRoom.shared.replyingMessage(m);
                Navigator.pop(context);
                Navigator.pop(context, m);
              },
            ),
            CupertinoContextMenuAction(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${localization.reply}',
                    style: TextStyle(fontSize: 14),
                  ),
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
            child: SendedMessageWidget(
              content: '${m['text']}',
              time: _time('${m['time']}'),
              write: '${m['write']}',
              type: "${m["type"]}",
              media: (a == false || a == null)
                  ? null
                  : "${m["type"]}" == '12' ? a[0]['link'] : a[0]['filename'],
              rMedia: (a == false || a == null)
                  ? null
                  : a[0]['r_filename'] == null
                      ? a[0]['filename']
                      : a[0]['r_filename'],
              mediaUrl: (a == false || a == null) ? null : m['attachment_url'],
              edit: "${m["edit"]}",
              anotherUser: "${m["type"]}" == '11'
                  ? jsonDecode(
                      jsonEncode(
                        {
                          "id": "${m["another_user_id"]}",
                          "avatar": "${m["another_user_avatar"]}",
                          "name": "${m["another_user_name"]}"
                        },
                      ),
                    )
                  : null,
              replyData:
                  (replyData == false || replyData == null) ? null : replyData,
              forwardData: forwarData,
            ),
          ),
        ),
      ),
    );
  }

  String _time(timestamp) {
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

EmojiParser _parser = EmojiParser();

class SendedMessageWidget extends StatelessWidget {
  final String content;
  final String time;
  final String write;
  final String media;
  final String mediaUrl;
  final String rMedia;
  final String type;
  final String edit;
  final anotherUser;
  final replyData;
  final forwardData;

  const SendedMessageWidget({
    Key key,
    this.content,
    this.time,
    this.write,
    this.media,
    this.mediaUrl,
    this.rMedia,
    this.type,
    this.edit,
    this.anotherUser,
    this.replyData,
    this.forwardData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var a = _parser.unemojify(content);
    int l = a.length - 1;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: edit == '1' ? 140.0 : 120.0,
      ),
      child: Container(
        child: Padding(
          padding: EdgeInsets.only(
            right: 8.0,
            left: 50.0,
            top: 4.0,
            bottom: 4.0,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(0),
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child: Container(
              color: type == '11' ? primaryColor : whiteColor,
              child: Stack(children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: (type == "3") ? 5 : 12.0,
                    left: (type == "3") ? 2 : 8.0,
                    top: (type == "3") ? 2 : 8.0,
                    bottom: (type == "3") ? 1.0 : 15.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      '$forwardData' != 'null' && '$forwardData' != 'false'
                          ? Text(
                              '${localization.forwardFrom} ${forwardData['chat_name']}')
                          : SizedBox(
                              height: 0,
                              width: 0,
                            ),
                      (type == "12")
                          ? LinkMessage("$media")
                          : (a[0] == ":" && a[l] == ":" && content.length < 9)
                              ? Text(content, style: TextStyle(fontSize: 40))
                              : (a[0] == ":" &&
                                      a[l] == ":" &&
                                      content.length > 8)
                                  ? Text(content,
                                      style: TextStyle(fontSize: 24))
                                  : (type == "1")
                                      ? (() {
                                          listMessages.forEach((element) {
                                            if (element['type'].toString() ==
                                                '1') {
                                              imageCount.add(element);
                                              test = element;
                                            }
                                          });
                                          return ImageMessage(
                                            "$mediaUrl$rMedia",
                                            "$mediaUrl$media",
                                            content: content,
                                            imageCount:
                                                imageCount.indexOf(test),
                                          );
                                        }())
                                      : (type == "2")
                                          ? Container(
                                              color: Colors.pinkAccent
                                                  .withOpacity(0.2),
                                              padding: EdgeInsets.all(5),
                                              child: Text(
                                                '${localization.document} ${localization.error}',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            )
                                          // TODO FIX FILES

                                          //  FileMessage(
                                          //     url: "$mediaUrl/$media",
                                          //     key: Key("$mediaUrl/$media"),
                                          //   )
                                          : (type == "3")
                                              ? AudioMessage("$mediaUrl$media")
                                              : (type == "4")
                                                  ? Container(
                                                      child: VideoPlayerWidget(
                                                          "$mediaUrl$media",
                                                          "network"),
                                                    )
                                                  : (type == "10")
                                                      ? ReplyMessage(
                                                          content, replyData)
                                                      : type == '11'
                                                          ? Container(
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Container(
                                                                        width:
                                                                            30.0,
                                                                        height:
                                                                            30.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          shape:
                                                                              BoxShape.circle,
                                                                          image:
                                                                              DecorationImage(
                                                                            fit:
                                                                                BoxFit.fill,
                                                                            image:
                                                                                NetworkImage(
                                                                              "$avatarUrl${anotherUser["avatar"].toString().replaceAll('AxB', '200x200')}",
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          width:
                                                                              5),
                                                                      Flexible(
                                                                        child:
                                                                            Text(
                                                                          "${anotherUser["name"]}",
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.w600,
                                                                              color: whiteColor),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          5),
                                                                  Flexible(
                                                                    child: Text(
                                                                      '-$content KZT',
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            )
                                                          : (type ==
                                                                  "uploading")
                                                              ? Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.7,
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.7,
                                                                  child: uploadingImage !=
                                                                          null
                                                                      ? Stack(
                                                                          children: [
                                                                            Container(
                                                                              width: MediaQuery.of(context).size.width * 0.7,
                                                                              height: MediaQuery.of(context).size.width * 0.7,
                                                                              child: Image.file(
                                                                                uploadingImage,
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                              width: MediaQuery.of(context).size.width * 0.7,
                                                                              height: MediaQuery.of(context).size.width * 0.7,
                                                                              color: Colors.grey.withOpacity(0.5),
                                                                            ),
                                                                            Center(),
                                                                          ],
                                                                        )
                                                                      : Center(),
                                                                )
                                                              : SelectableText(
                                                                  content,
                                                                ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: -1,
                  right: 3,
                  child: write == '1'
                      ? Icon(
                          Icons.done_all,
                          size: 16,
                          color: type == '11' ? whiteColor : Colors.blue,
                        )
                      : Icon(
                          Icons.done,
                          size: 16,
                          color: type == '11' ? whiteColor : Colors.grey[500],
                        ),
                ),
                Positioned(
                  bottom: 1,
                  left: 10,
                  child: Row(
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                            fontSize: 10,
                            color: type == '11'
                                ? whiteColor
                                : Colors.black.withOpacity(0.6)),
                      ),
                      edit == '1'
                          ? Text(
                              " ред.",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.black.withOpacity(0.6),
                              ),
                            )
                          : Container()
                    ],
                  ),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
