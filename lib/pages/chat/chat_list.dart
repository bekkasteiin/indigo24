import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/db/chats_model.dart';
import 'package:indigo24/pages/chat/chat.dart';
import 'package:indigo24/pages/chat/chat_contacts.dart';
import 'package:indigo24/pages/chat/chat_group_selection.dart';
import 'package:indigo24/pages/chat/chat_page_view_test.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/widgets/constants.dart';
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
List<ChatsModel> chatsModel = [];
int chatsPage = 1;

class _ChatsListPageState extends State<ChatsListPage>
    with AutomaticKeepAliveClientMixin {
  bool isOffline = false;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));

    print("_onRefresh");

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()

    // items.add((items.length+1).toString());
    print("_onLoading");
    // print(myList.length);
    // if(myList.length % 20 == 0){
    //   chatsPage++;
    //   if (mounted)
    //     setState(() {
    //       // print("_onLoading CHATS with page $chatsPage");
    //       ChatRoom.shared.forceGetChat(page: chatsPage);
    //     });
    //   _refreshController.loadComplete();
    // }

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

  goToChat(name, chatID,
      {phone, chatType, memberCount, userIds, avatar, avatarUrl, members}) {
    ChatRoom.shared.setCabinetStream();
    ChatRoom.shared.checkUserOnline(userIds);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChatPage(
                name, chatID,
                phone: phone, // TODO CHECK IT ADIL
                members: members,
                chatType: chatType,
                memberCount: memberCount, userIds: userIds,
                avatar: avatar, avatarUrl: avatarUrl,
              )),
    ).whenComplete(() {
      setState(() {
        uploadingImage = null;
      });
      ChatRoom.shared.forceGetChat();
      ChatRoom.shared.closeCabinetStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    String string = '${localization.chats}';
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          string,
          style: TextStyle(color: Color(0xFF001D52)),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 10, top: 10),
            child: InkWell(
              child: Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '${localization.createGroup}',
                      style: TextStyle(color: Color(0xFF001D52)),
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
                        builder: (context) => ChatGroupSelection()));
              },
            ),
          ),
          Expanded(child: _listView(context, string)),
        ],
      ),
    );
  }

  _listView(context, status) {
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
                      "Нажмите чтобы начать чат",
                      style: TextStyle(fontSize: 20),
                    ))
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
                // print(myList[i]);
                return Column(
                  children: <Widget>[
                    ListTile(
                      onTap: () {
                        // ChatRoom.shared.checkUserOnline(ids);
                        print('get message');
                        ChatRoom.shared.getMessages(myList[i]['id']);
                        goToChat(myList[i]['name'], myList[i]['id'],
                            phone: myList[i]
                                ['another_user_phone'], //@TODO ADIL CHECK DIS
                            members: myList[i]['members'],
                            memberCount: myList[i]['members_count'],
                            chatType: myList[i]['type'],
                            userIds: myList[i]['another_user_id'],
                            avatar: myList[i]['avatar']
                                .toString()
                                .replaceAll("AxB", "200x200"),
                            avatarUrl: myList[i]['avatar_url']);
                      },
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(25.0),
                        child: Container(
                          height: 50,
                          width: 50,
                          child: ClipOval(
                              child: CachedNetworkImage(
                            imageUrl: (myList[i]["avatar"] == null ||
                                    myList[i]["avatar"] == '' ||
                                    myList[i]["avatar"] == false)
                                ? "${avatarUrl}noAvatar.png"
                                : '${avatarUrl}${myList[i]["avatar"].toString().replaceAll("AxB", "200x200")}',
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                CachedNetworkImage(
                              imageUrl:
                                  "${avatarUrl}noAvatar.png",
                            ),
                          )),
                        ),
                      ),
                      title: Text(
                        myList[i]["name"].length != 0
                            ? "${myList[i]["name"][0].toUpperCase() + myList[i]["name"].substring(1)}"
                            : "",
                            maxLines: 1,
                        style: TextStyle(
                            color: Color(0xFF001D52),
                            fontWeight: FontWeight.w400),
                      ),
                      subtitle: Text(
                        myList[i]["last_message"].length != 0
                            ? myList[i]["last_message"]['text'].length != 0
                                ? "${myList[i]["last_message"]['text'][0].toUpperCase() + myList[i]["last_message"]['text'].substring(1)}"
                                : myList[i]["last_message"]
                                            ['message_for_type'] !=
                                        null
                                    ? myList[i]["last_message"]
                                        ['message_for_type']
                                    : ""
                            : "",
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
                              // :
                              // myList[i]['unread_messages'].toString().startsWith('-')?
                              // Container()
                              : Container(
                                  // width: 20,
                                  decoration: BoxDecoration(
                                      color: Color(0xFFA9C7D2),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Text(
                                      " ${myList[i]['unread_messages']} ",
                                      style: TextStyle(color: Colors.white)))
                        ],
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 80, right: 20),
                        height: 1,
                        color: Colors.grey.shade300)
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
