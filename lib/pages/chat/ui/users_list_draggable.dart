import 'package:flutter/material.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:indigo24/pages/chat/ui/new_chat/chat.dart';
import 'package:indigo24/pages/wallet/transfers/transfer.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/helpers/day_helper.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/services/user.dart' as user;

import '../chat.dart';

class UsersListDraggableWidget extends StatefulWidget {
  final int chatId;

  const UsersListDraggableWidget({Key key, this.chatId}) : super(key: key);
  @override
  _UsersListDraggableWidgetState createState() =>
      _UsersListDraggableWidgetState();
}

class _UsersListDraggableWidgetState extends State<UsersListDraggableWidget> {
  bool _isMembersLoading;
  List _users;
  int _membersPage;
  @override
  void initState() {
    _isMembersLoading = false;
    _users = [];
    _membersPage = 1;
    ChatRoom.shared.setNewUsersListStream();
    _listen();
    ChatRoom.shared.chatMembers(widget.chatId);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          color: blackPurpleColor,
          icon: Icon(Icons.cancel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Column(
          children: <Widget>[
            Text(
              localization.chats,
              style: TextStyle(
                fontSize: 22.0,
                color: blackPurpleColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        brightness: Brightness.light,
      ),
      body: SafeArea(
        child: Container(
          child: _users.isNotEmpty
              ? NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (!_isMembersLoading &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                      _loadMore();
                    }
                  },
                  child: ScrollablePositionedList.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, i) {
                      if ('${_users[i]['user_id']}' == '${user.id}')
                        return SizedBox(
                          height: 0,
                          width: 0,
                        );
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(25.0),
                          child: Image.network(
                            '$avatarUrl${_users[i]['avatar'].toString().replaceAll("AxB", "200x200")}',
                            width: 35,
                            height: 35,
                          ),
                        ),
                        title: Text(
                          '${_users[i]['user_name']}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransferPage(
                                phone: _users[i]['phone'],
                                transferChat: '${widget.chatId}',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }

  _loadMore() {
    setState(() {
      _isMembersLoading = true;
    });

    ChatRoom.shared.chatMembers(widget.chatId, page: _membersPage);
  }

  _listen() {
    ChatRoom.shared.onUsersListDialogChange.listen((e) {
      print("USERS DRAGABLE EVENT ${e.json['cmd']}");
      var cmd = e.json['cmd'];
      var data = e.json['data'];
      switch (cmd) {
        case "chat:members":
          _isMembersLoading = false;
          print('$data');
          if (data.isNotEmpty) {
            _membersPage++;
            setState(() {
              _users.addAll(data.toList());
            });
          }

          break;

        default:
          print('USERS LIST DRAGABLE DEFasdasdAULT');
      }
    });
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
