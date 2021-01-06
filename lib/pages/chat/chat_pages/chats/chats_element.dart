import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/pages/chat/chat_models/chat_model.dart';
import 'package:indigo24/services/api/socket/socket.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/helpers/day_helper.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/services/extensions/string_extension.dart';

import '../chat.dart';

class ChatsElement extends StatelessWidget {
  const ChatsElement({
    Key key,
    @required this.chat,
    this.onTap,
  }) : super(key: key);
  final dynamic onTap;
  final ChatModel chat;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: () {
            onTap == null
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        chatId: int.parse(chat.chatId.toString()),
                        chatName: chat.name,
                        chatType: int.parse(chat.chatType.toString()),
                        avatar: chat.avatar,
                      ),
                    ),
                  ).whenComplete(
                    () {
                      ChatRoom.shared.forceGetChat();
                    },
                  )
                : onTap();
          },
          leading: Container(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: Container(
                height: 40,
                width: 40,
                color: greyColor,
                child: CachedNetworkImage(
                  errorWidget: (context, url, error) => Material(
                    child: Image.network(
                      '${avatarUrl}noAvatar.png',
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.width * 0.7,
                    ),
                  ),
                  imageUrl: (chat.avatar == null || chat.avatar == '')
                      ? '${avatarUrl}noAvatar.png'
                      : '$avatarUrl${chat.avatar.toString().replaceAll("AxB", "200x200")}',
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.width * 0.7,
                ),
              ),
            ),
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  chat.name.toString().capitalize(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: blackPurpleColor, fontWeight: FontWeight.w400),
                ),
              ),
              Container(
                padding: EdgeInsets.all(5),
                child: Center(
                  child: chat.isMuted
                      ? Image.asset(
                          'assets/images/unmuteChat.png',
                          width: 10,
                          height: 10,
                        )
                      : null,
                ),
              ),
            ],
          ),
          subtitle: Container(
            child: Text(
              chat.message == 'null' ? chat.messagePreview : chat.message,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style:
                  TextStyle(color: darkGreyColor2, fontWeight: FontWeight.w300),
            ),
          ),
          trailing: Wrap(
            direction: Axis.vertical,
            crossAxisAlignment: WrapCrossAlignment.end,
            alignment: WrapAlignment.center,
            children: <Widget>[
              Container(
                child: Text(
                  _time(chat.messageTime),
                  style: TextStyle(
                    color: blackPurpleColor,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              chat.unreadCount == 0
                  ? Container(
                      width: 0,
                      height: 0,
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      height: 20,
                      decoration: BoxDecoration(
                        color: brightGreyColor4,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "${chat.unreadCount}",
                          style: TextStyle(color: whiteColor),
                        ),
                      ),
                    )
            ],
          ),
        ),
        Container(
          child: Padding(
            padding: const EdgeInsets.only(left: 65),
            child: Container(
              color: brightGreyColor5,
              width: MediaQuery.of(context).size.width,
              height: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  String _time(timestamp) {
    if (timestamp != null) {
      if (timestamp != '') {
        var messageUnixDate = DateTime.fromMillisecondsSinceEpoch(
          int.parse("$timestamp") * 1000,
        );
        TimeOfDay messageDate =
            TimeOfDay.fromDateTime(DateTime.parse('$messageUnixDate'));
        var hours;
        var minutes;
        hours = '${messageDate.hour}';
        minutes = '${messageDate.minute}';
        var diff = DateTime.now().difference(messageUnixDate);
        if (messageDate.hour.toString().length == 1)
          hours = '0${messageDate.hour}';
        if (messageDate.minute.toString().length == 1)
          minutes = '0${messageDate.minute}';
        if (diff.inDays == 0) {
          return '$hours:$minutes';
        } else if (diff.inDays < 7) {
          int weekDay = messageUnixDate.weekday;
          return newIdentifyDay(weekDay) + '\n$hours:$minutes';
        } else {
          return '$messageUnixDate'.substring(0, 10).replaceAll('-', '.') +
              '\n$hours:$minutes';
        }
      }
    }
    return '??:??';
  }
}
