import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/db/Student_DAO.dart';
import 'package:indigo24/db/chats_model.dart';
import 'package:indigo24/db/student.dart';
import 'package:indigo24/pages/chat.dart';
import 'package:indigo24/pages/chat_contacts.dart';
import 'package:indigo24/services/socket.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'chat_page_view_test.dart';

class ChatsListPage extends StatefulWidget {
  ChatsListPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ChatsListPageState createState() => _ChatsListPageState();
}

List<ChatsModel> dbChats = [];
List myList = [];
List<ChatsModel> chatsModel = [];
int chatsPage = 1;

class _ChatsListPageState extends State<ChatsListPage>
    with AutomaticKeepAliveClientMixin {
  bool isOffline = false;

  int _counter = 0;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    
    print("_onRefresh");

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()

    // items.add((items.length+1).toString());
    print("_onLoading");
    if(mounted)
    setState(() {
      // print("_onLoading CHATS with page $chatsPage");
      // ChatRoom.shared.forceGetChat(page: chatsPage);
    });
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  goToChat(name, chatID, {memberCount, userIds}) {
    ChatRoom.shared.setCabinetStream();
    ChatRoom.shared.checkUserOnline(userIds);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChatPage(name, chatID,
              memberCount: memberCount, userIds: userIds)),
    ).whenComplete(() {
      ChatRoom.shared.forceGetChat();
      ChatRoom.shared.closeCabinetStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    String string = 'Чаты';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          string,
          style: TextStyle(color: Color(0xFF001D52)),
        ),
        brightness: Brightness.light,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.contact_phone),
            iconSize: 30,
            color: Color(0xFF001D52),
            onPressed: () {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatContactsPage()))
                  .whenComplete(() {
                ChatRoom.shared.contactController.close();
                ChatRoom.shared.forceGetChat();
                ChatRoom.shared.closeContactsStream();
              });
            },
          )
        ],
      ),
      body: Container(child: _listView(context, string)),
    );
  }

  _listView(context, status) {
    return myList.isEmpty
        // ? dbChats.isNotEmpty
        //     ? localChatBuilder(dbChats)
            ? Center(child: CircularProgressIndicator())
            : 
            SmartRefresher(
              enablePullDown: false,
              enablePullUp: true,
              // header: WaterDropHeader(),
              footer: CustomFooter(
                builder: (BuildContext context,LoadStatus mode){
                  Widget body ;
                  return Container(
                    height: 55.0,
                    child: Center(child:body),
                  );
                },
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: ListView.builder(
                  itemCount: myList.length,
                  itemBuilder: (context, i) {
                    // print(myList[i]);
                    return Column(
                      children: <Widget>[
                        ListTile(
                          onTap: () {
                            // ChatRoom.shared.checkUserOnline(ids);
                            ChatRoom.shared.getMessages(myList[i]['id']);
                            goToChat(
                              myList[i]['name'],
                              myList[i]['id'],
                              memberCount: myList[i]['members_count'],
                              userIds: myList[i]['another_user_id'],
                            );
                          },
                          leading: CircleAvatar(
// <<<<<<< HEAD

//                         backgroundImage: (myList[i]["avatar"] == null ||
//                                 myList[i]["avatar"] == '' ||
//                                 myList[i]["avatar"] == false)
//                             ? CachedNetworkImageProvider(
//                                 "https://media.indigo24.com/avatars/noAvatar.png")
//                             : CachedNetworkImageProvider(
//                                 'https://indigo24.xyz/uploads/avatars/${myList[i]["avatar"]}')),
//                     title: Text("${myList[i]["name"]}"),
// =======
                            radius: 25.0,
                            backgroundImage: //"https://bizraise.pro/wp-content/uploads/2014/09/no-avatar-300x300.png"
                            CachedNetworkImageProvider("https://bizraise.pro/wp-content/uploads/2014/09/no-avatar-300x300.png")
                            // (myList[i]["avatar"] == null || myList[i]["avatar"] == '' || myList[i]["avatar"] == false)
                            //     ? CachedNetworkImageProvider(
                            //         "https://media.indigo24.com/avatars/noAvatar.png")
                            //     : CachedNetworkImageProvider(
                            //         'https://indigo24.xyz/uploads/avatars/${myList[i]["avatar"]}'),
                          ),
                          title: Text(
                            myList[i]["name"].length != 0 ? "${myList[i]["name"][0].toUpperCase() + myList[i]["name"].substring(1)}" : "",
                            style: TextStyle(
                                color: Color(0xFF001D52),
                                fontWeight: FontWeight.w400),
                          ),
// >>>>>>> 222314f78ca2c8bd1c63a5e2b9c9a1fbe7409c5f
                          subtitle: Text(
                            myList[i]["last_message"].length != 0 ? myList[i]["last_message"]['text'].length != 0 ? "${myList[i]["last_message"]['text'][0].toUpperCase() + myList[i]["last_message"]['text'].substring(1)}"  : "" : "",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(color: Color(0xFF5E5E5E)),
                          ),
                          trailing: Wrap(
                            direction: Axis.vertical,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            alignment: WrapAlignment.center,
                            children: <Widget>[
                              Text(
                                myList[i]['last_message']["time"] == null
                                    ? "null"
                                    : time("${myList[i]['last_message']["time"]}"),
                                style: TextStyle(color: Color(0xFF001D52)),
                              ),
                              myList[i]['unread_messages'] == 0
                                  ? Container()
                                  : Container(
                                      // width: 20,
                                      decoration: BoxDecoration(
                                          color: Color(0xFFA9C7D2),
                                          borderRadius: BorderRadius.circular(10)),
                                      child: Text(" ${myList[i]['unread_messages']} ",
                                          style: TextStyle(color: Colors.white)))
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 70),
                          height: 1,
                          color: Colors.grey.shade300
                        )
                      ],
                    );
                  },
                ),
            );
  }

  String time(timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(
      int.parse("$timestamp") * 1000,
    );
    TimeOfDay roomBooked = TimeOfDay.fromDateTime(DateTime.parse('$date'));
    var hours;
    var minutes;
    // messageMinutes = '${roomBooked.minute}';
    hours = '${roomBooked.hour}';
    minutes = '${roomBooked.minute}';

    if (roomBooked.hour.toString().length == 1) hours = '0${roomBooked.hour}';
    if (roomBooked.minute.toString().length == 1)
      minutes = '0${roomBooked.minute}';
    return '$hours:$minutes';
  }

  @override
  bool get wantKeepAlive => true;
}
