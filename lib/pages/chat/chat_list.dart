import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:indigo24/db/chats_model.dart';
import 'package:indigo24/pages/chat/chat.dart';
import 'package:indigo24/pages/chat/chat_contacts.dart';
import 'package:indigo24/pages/chat/chat_group_selection.dart';
import 'package:indigo24/pages/chat/chat_page_view_test.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/style/colors.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:indigo24/services/localization.dart' as localization;

class ChatsListPage extends StatefulWidget {
  ChatsListPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ChatsListPageState createState() => _ChatsListPageState();
}

List<ChatsModel> dbChats = [];
List myList = [];
List chatList = [];
List<ChatsModel> chatsModel = [];
int chatsPage = 1;

bool globalBoolForForceGetChat = false;

class _ChatsListPageState extends State<ChatsListPage>
    with AutomaticKeepAliveClientMixin {
  RefreshController _refreshController;

  @override
  void initState() {
    _refreshController = RefreshController(initialRefresh: false);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    String string = '${localization.chats}';
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          string,
          style: TextStyle(
            fontSize: 22.0,
            color: blackPurpleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        brightness: Brightness.light,
        actions: <Widget>[
          IconButton(
            icon: Container(
              height: 20,
              width: 20,
              child: Image(
                image: AssetImage(
                  'assets/images/contacts.png',
                ),
              ),
            ),
            iconSize: 30,
            color: blackPurpleColor,
            onPressed: () {
              ChatRoom.shared.setCabinetInfoStream();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatContactsPage(),
                ),
              ).whenComplete(
                () {
                  ChatRoom.shared.contactController.close();
                  // this is bool for check load more is needed or not
                  globalBoolForForceGetChat = false;
                  ChatRoom.shared.forceGetChat();
                  ChatRoom.shared.closeContactsStream();
                },
              );
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 10, top: 10),
            child: InkWell(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '${localization.createGroup}',
                      style: TextStyle(color: blackPurpleColor),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      height: 10,
                      width: 10,
                      child: Image(
                        image: AssetImage(
                          'assets/images/add.png',
                        ),
                      ),
                    ),
                    Container(
                      height: 30,
                      width: 20,
                      child: Image(
                        image: AssetImage(
                          'assets/images/group.png',
                        ),
                      ),
                    )
                  ],
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatGroupSelection(),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _listView(
              context,
              string,
              myList: myList.isEmpty ? chatList : myList,
            ),
          ),
        ],
      ),
    );
  }

  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    print("_onRefresh");
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    print("_onLoading");
    if (myList.length % 20 == 0) {
      globalBoolForForceGetChat = true;
      chatsPage++;
      if (mounted)
        setState(() {
          print("_onLoading CHATS with page $chatsPage");
          ChatRoom.shared.forceGetChat(page: chatsPage);
        });
      _refreshController.loadComplete();
    }
  }

  _goToChat(
    name,
    chatID, {
    phone,
    chatType,
    memberCount,
    userIds,
    avatar,
    avatarUrl,
    members,
  }) {
    ChatRoom.shared.setCabinetStream();
    ChatRoom.shared.checkUserOnline(userIds);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          name,
          chatID,
          phone: phone,
          members: members,
          chatType: chatType,
          memberCount: memberCount,
          userIds: userIds,
          avatar: avatar,
          avatarUrl: avatarUrl,
        ),
      ),
    ).whenComplete(
      () {
        setState(() {
          uploadingImage = null;
        });
        // this is bool for check load more is needed or not
        globalBoolForForceGetChat = false;
        ChatRoom.shared.forceGetChat();
        ChatRoom.shared.closeCabinetStream();
      },
    );
  }

  _showAlertDialog(BuildContext context, String message, var chat) {
    Widget okButton = CupertinoDialogAction(
      isDestructiveAction: true,
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
        ChatRoom.shared.deleteChat(chat);
        ChatRoom.shared.forceGetChat();
      },
    );
    Widget noButton = CupertinoDialogAction(
      child: Text("${localization.no}"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: Text("$message"),
      actions: [
        noButton,
        okButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _listView(context, status, {myList}) {
    return myList.isEmpty
        // ? dbChats.isNotEmpty
        //     ? localChatBuilder(dbChats)
        ? InkWell(
            onTap: () {
              print("чат");
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatContactsPage()))
                  .whenComplete(() {
                ChatRoom.shared.contactController.close();
                // this is bool for check load more is needed or not
                ChatRoom.shared.forceGetChat();
                ChatRoom.shared.closeContactsStream();
              });
            },
            child: Container(
              color: Colors.white,
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Image.asset("assets/chat_animation.gif"),
                    Container(
                      child: Text(
                        "${localization.noChats} \n${localization.clickToStart}",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        // Center(child: CircularProgressIndicator())
        : SmartRefresher(
            enablePullDown: false,
            enablePullUp: true,
            // header: WaterDropHeader(),
            footer: CustomFooter(
              builder: (BuildContext context, LoadStatus mode) {
                Widget body;
                return Container(
                  height: 55.0,
                  child: Center(child: body),
                );
              },
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: ListView.builder(
              itemCount: myList.length,
              itemBuilder: (context, i) {
                return Column(
                  children: <Widget>[
                    Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      actionExtentRatio: 0.25,
                      secondaryActions: <Widget>[
                        IconSlideAction(
                          caption:
                              '${myList[i]['mute'].toString() == '0' ? localization.mute : localization.unmute}',
                          color: myList[i]['mute'].toString() == '0'
                              ? redColor
                              : Colors.grey,
                          icon: myList[i]['mute'].toString() == '0'
                              ? Icons.volume_mute
                              : Icons.settings_backup_restore,
                          onTap: () {
                            myList[i]['mute'].toString() == '0'
                                ? ChatRoom.shared.muteChat(myList[i]['id'], 1)
                                : ChatRoom.shared.muteChat(myList[i]['id'], 0);
                            ChatRoom.shared.forceGetChat();
                          },
                        ),
                        IconSlideAction(
                          caption: '${localization.delete}',
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: () {
                            _showAlertDialog(
                              context,
                              '${localization.delete} ${localization.chat} ${myList[i]['name']}?',
                              myList[i]['id'],
                            );
                            ChatRoom.shared.forceGetChat();
                          },
                        )
                      ],
                      child: ListTile(
                        onTap: () {
                          print('get message');
                          ChatRoom.shared.getMessages(myList[i]['id']);
                          _goToChat(
                            myList[i]['name'],
                            myList[i]['id'],
                            phone: myList[i]['another_user_phone'],
                            members: myList[i]['members'],
                            memberCount: myList[i]['members_count'],
                            chatType: myList[i]['type'],
                            userIds: myList[i]['another_user_id'],
                            avatar: myList[i]['avatar']
                                .toString()
                                .replaceAll("AxB", "200x200"),
                            avatarUrl: myList[i]['avatar_url'],
                          );
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
                                    ? '${avatarUrl}noAvatar.png'
                                    : '$avatarUrl${myList[i]["avatar"].toString().replaceAll("AxB", "200x200")}',
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          myList[i]["name"].length != 0
                              ? "${myList[i]["name"][0].toUpperCase() + myList[i]["name"].substring(1)}"
                              : "",
                          maxLines: 1,
                          style: TextStyle(
                              color: blackPurpleColor,
                              fontWeight: FontWeight.w400),
                        ),
                        subtitle: Text(
                          myList[i]["last_message"].length != 0
                              ? myList[i]["last_message"]['text'].length != 0
                                  ? "${myList[i]["last_message"]['text'][0].toUpperCase() + myList[i]["last_message"]['text'].substring(1)}"
                                  : myList[i]["last_message"]
                                              ['message_for_type'] !=
                                          null
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
                              style: TextStyle(color: blackPurpleColor),
                            ),
                            myList[i]['unread_messages'] == 0
                                ? Container()
                                : Container(
                                    decoration: BoxDecoration(
                                        color: brightGreyColor4,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Text(
                                      " ${myList[i]['unread_messages']} ",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 80, right: 20),
                      height: 1,
                      color: Colors.grey.shade300,
                    )
                  ],
                );
              },
            ),
          );
  }

  String _time(timestamp) {
    if (timestamp != null) {
      if (timestamp != '') {
        var date = DateTime.fromMillisecondsSinceEpoch(
          int.parse("$timestamp") * 1000,
        );
        TimeOfDay roomBooked = TimeOfDay.fromDateTime(DateTime.parse('$date'));
        var hours;
        var minutes;
        // messageMinutes = '${roomBooked.minute}';
        hours = '${roomBooked.hour}';
        minutes = '${roomBooked.minute}';

        if (roomBooked.hour.toString().length == 1)
          hours = '0${roomBooked.hour}';
        if (roomBooked.minute.toString().length == 1)
          minutes = '0${roomBooked.minute}';
        return '$hours:$minutes';
      }
    }
    return '??:??';
  }

  @override
  bool get wantKeepAlive => true;
}
