import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:indigo24/pages/chat/ui/new_chat/chat.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/services/localization.dart' as localization;

import '../../chat_list.dart';

extension GlobalKeyEx on GlobalKey {
  Rect get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    var translation = renderObject?.getTransformTo(null)?.getTranslation();
    if (translation != null && renderObject.paintBounds != null) {
      return renderObject.paintBounds
          .shift(Offset(translation.x, translation.y));
    } else {
      return null;
    }
  }
}

class TestChatsListPage extends StatefulWidget {
  @override
  _TestChatsListPageState createState() => _TestChatsListPageState();
}

class _TestChatsListPageState extends State<TestChatsListPage> {
  ListTile _chatListTile(myList, int i, {data}) {
    return ListTile(
      onTap: () {
        print('get message');
        ChatRoom.shared.getMessages(myList[i]['id']);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              chatId: int.parse(myList[i]['id'].toString()),
              chatName: myList[i]['name'],
              chatType: int.parse(myList[i]['type'].toString()),
            ),
          ),
        );
        // _goToChat(
        //   myList[i]['name'],
        //   myList[i]['id'],
        //   phone: myList[i]['another_user_phone'],
        //   members: myList[i]['members'],
        //   memberCount: myList[i]['members_count'],
        //   chatType: myList[i]['type'],
        //   userIds: myList[i]['another_user_id'],
        //   avatar: myList[i]['avatar'].toString().replaceAll("AxB", "200x200"),
        //   avatarUrl: myList[i]['avatar_url'],
        // );
      },
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(25.0),
        child: Container(
          height: 50,
          width: 50,
          color: greyColor,
          child: ClipOval(
            child: Image.network(
              (myList[i]["avatar"] == null ||
                      myList[i]["avatar"] == '' ||
                      myList[i]["avatar"] == false)
                  ? '${myList[i]['type'].toString() == '1' ? groupAvatarUrl : avatarUrl}noAvatar.png'
                  : '${myList[i]['type'].toString() == '1' ? groupAvatarUrl : avatarUrl}${myList[i]["avatar"].toString().replaceAll("AxB", "200x200")}',
            ),
          ),
        ),
      ),
      title: Text(
        myList[i]["name"].toString().length != 0
            ? "${myList[i]["name"][0].toUpperCase() + myList[i]["name"].substring(1)}"
            : "",
        maxLines: 1,
        style: TextStyle(color: blackPurpleColor, fontWeight: FontWeight.w400),
      ),
      subtitle: Text(
        myList[i]["last_message"].toString().length != 0
            ? myList[i]["last_message"]['text'].toString().length != 0
                ? "${myList[i]["last_message"]['text'].toString()[0].toUpperCase() + myList[i]["last_message"]['text'].toString().substring(1)}"
                : myList[i]["last_message"]['message_for_type'] != null
                    ? "${myList[i]["last_message"]['message_for_type'][0].toUpperCase() + myList[i]["last_message"]['message_for_type'].substring(1)}"
                    : ""
            : "",
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(color: darkGreyColor2),
      ),
      trailing: Wrap(
        direction: Axis.vertical,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        children: <Widget>[
          Text(
            myList[i]['last_message']["time"] == null
                ? "null"
                : _time(myList[i]['last_message']["time"]),
            style: TextStyle(
              color: blackPurpleColor,
            ),
            textAlign: TextAlign.right,
          ),
          myList[i]['unread_messages'] == 0
              ? Container()
              : Container(
                  decoration: BoxDecoration(
                      color: brightGreyColor4,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    " ${myList[i]['unread_messages']} ",
                    style: TextStyle(color: Colors.white),
                  ),
                )
        ],
      ),
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
          return '${localization.today}\n$hours:$minutes';
        } else if (diff.inDays < 7) {
          int weekDay = messageUnixDate.weekday;
          return identifyDay(weekDay) + '\n$hours:$minutes';
        } else {
          return '$messageUnixDate'.substring(0, 10).replaceAll('-', '.') +
              '\n$hours:$minutes';
        }
      }
    }
    return '??:??';
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: myList.length,
      itemBuilder: (BuildContext context, int i) {
        return Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          secondaryActions: <Widget>[
            IconSlideAction(
              caption:
                  '${myList[i]['mute'].toString() == '0' ? localization.mute : localization.unmute}',
              color:
                  myList[i]['mute'].toString() == '0' ? redColor : Colors.grey,
              icon: myList[i]['mute'].toString() == '0'
                  ? Icons.volume_mute
                  : Icons.settings_backup_restore,
              onTap: () {
                myList[i]['mute'].toString() == '0'
                    ? ChatRoom.shared.muteChat(myList[i]['id'], 1)
                    : ChatRoom.shared.muteChat(myList[i]['id'], 0);
                globalBoolForForceGetChat = false;

                ChatRoom.shared.forceGetChat();
              },
            ),
            IconSlideAction(
              caption: '${localization.delete}',
              color: Colors.red,
              icon: Icons.delete,
              onTap: () {
                // _showAlertDialog(
                //   context,
                //   '${localization.delete} ${localization.chat} ${myList[i]['name']}?',
                //   myList[i]['id'],
                // );
                ChatRoom.shared.forceGetChat();
              },
            )
          ],
          child: _chatListTile(myList, i),
        );
      },
    );
  }
}
