// import 'dart:async';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:indigo24/db/chats_model.dart';
// import 'package:indigo24/pages/chat/chat.dart';
// import 'package:indigo24/pages/chat/chat_contacts.dart';
// import 'package:indigo24/pages/chat/chat_group_selection.dart';
// import 'package:indigo24/pages/chat/chat_page_view_test.dart';
// import 'package:indigo24/services/socket.dart';
// import 'package:indigo24/services/constants.dart';
// import 'package:indigo24/style/colors.dart';
// import 'package:indigo24/widgets/alerts.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';
// import 'package:indigo24/services/localization.dart' as localization;

// identifyDay(int day) {
//   switch (day) {
//     case 1:
//       return '${localization.monday}';
//       break;
//     case 2:
//       return '${localization.tuesday}';
//       break;
//     case 3:
//       return '${localization.wednesday}';
//       break;
//     case 4:
//       return '${localization.thursday}';
//       break;
//     case 5:
//       return '${localization.friday}';
//       break;
//     case 6:
//       return '${localization.saturday}';
//       break;
//     case 7:
//       return '${localization.sunday}';
//       break;
//     default:
//       return 'dayOfWeek';
//   }
// }

// class ChatsListPage extends StatefulWidget {
//   ChatsListPage({Key key, this.title}) : super(key: key);

//   final String title;

//   @override
//   _ChatsListPageState createState() => _ChatsListPageState();
// }

// List<ChatsModel> dbChats = [];
// List myList = [];
// List chatList = [];
// List<ChatsModel> chatsModel = [];
// int chatsPage = 1;

// bool globalBoolForForceGetChat = false;

// class _ChatsListPageState extends State<ChatsListPage>
//     with AutomaticKeepAliveClientMixin {
//   RefreshController _refreshController;
//   int _currentDate;
//   bool showSelection;
//   dynamic message;
//   @override
//   void initState() {
//     showSelection = false;
//     _currentDate = DateTime.now().toUtc().millisecondsSinceEpoch;
//     _refreshController = RefreshController(initialRefresh: false);
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     SystemChannels.textInput.invokeMethod('TextInput.hide');
//   }

//   @override
//   // ignore: must_call_super
//   Widget build(BuildContext context) {
//     String string = '${localization.chats}';
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0.5,
//         title: Column(
//           children: <Widget>[
//             Text(
//               string,
//               style: TextStyle(
//                 fontSize: 22.0,
//                 color: blackPurpleColor,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             showSelection
//                 ? Text(
//                     '${localization.selectChat}',
//                     style: TextStyle(
//                       fontSize: 14.0,
//                       color: blackPurpleColor,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   )
//                 : SizedBox(height: 0, width: 0)
//           ],
//         ),
//         brightness: Brightness.light,
//         actions: <Widget>[
//           IconButton(
//             icon: Container(
//               height: 20,
//               width: 20,
//               child: Image(
//                 image: AssetImage(
//                   'assets/images/contacts.png',
//                 ),
//               ),
//             ),
//             iconSize: 30,
//             color: blackPurpleColor,
//             onPressed: () {
//               ChatRoom.shared.setChatUserProfileInfoStream();
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ChatContactsPage(),
//                 ),
//               ).whenComplete(
//                 () {
//                   // ChatRoom.shared.contactController.close();
//                   // this is bool for check load more is needed or not
//                   globalBoolForForceGetChat = false;
//                   ChatRoom.shared.forceGetChat();
//                   ChatRoom.shared.closeContactsStream();
//                 },
//               );
//             },
//           )
//         ],
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Container(
//             margin: EdgeInsets.only(left: 10),
//             child: ButtonTheme(
//               height: 0,
//               child: RaisedButton(
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 10),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisSize: MainAxisSize.min,
//                     children: <Widget>[
//                       Text(
//                         '${localization.createGroup}',
//                         style: TextStyle(color: blackPurpleColor),
//                       ),
//                       SizedBox(
//                         width: 10,
//                       ),
//                       Container(
//                         height: 10,
//                         width: 10,
//                         child: Image(
//                           image: AssetImage(
//                             'assets/images/add.png',
//                           ),
//                         ),
//                       ),
//                       Container(
//                         height: 30,
//                         width: 20,
//                         child: Image(
//                           image: AssetImage(
//                             'assets/images/group.png',
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10)),
//                 textColor: blackPurpleColor,
//                 color: whiteColor,
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ChatGroupSelection(),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//           Expanded(
//             child: _listView(
//               context,
//               string,
//               myList: myList.isEmpty ? chatList : myList,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _onRefresh() async {
//     await Future.delayed(Duration(milliseconds: 1000));
//     print("_onRefresh");
//     _refreshController.refreshCompleted();
//   }

//   void _onLoading() async {
//     await Future.delayed(Duration(milliseconds: 1000));
//     print("_onLoading");
//     //if (myList.length % 20 == 0) {
//     globalBoolForForceGetChat = true;
//     print("_onLoading CHATS with paasdasdadsdasasdasdasdge $chatsPage");
//     chatsPage++;
//     if (mounted)
//       setState(() {
//         print("_onLoading CHATS with page $chatsPage");
//         ChatRoom.shared.forceGetChat(page: chatsPage);
//       });
//     globalBoolForForceGetChat = false;

//     _refreshController.loadComplete();
//     //}
//   }

//   _goToChat(
//     name,
//     chatID, {
//     phone,
//     chatType,
//     memberCount,
//     userIds,
//     avatar,
//     avatarUrl,
//     members,
//     data,
//   }) async {
//     ChatRoom.shared.setChatStream();
//     ChatRoom.shared.checkUserOnline(userIds);
//     var test = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ChatPage(
//           name,
//           chatID,
//           phone: phone,
//           members: members,
//           chatType: chatType,
//           memberCount: memberCount,
//           userIds: userIds,
//           avatar: avatar,
//           avatarUrl: avatarUrl,
//           data: data,
//         ),
//       ),
//     ).whenComplete(
//       () {
//         setState(() {
//           uploadingImage = null;
//         });
//         // this is bool for check load more is needed or not
//         globalBoolForForceGetChat = false;
//         ChatRoom.shared.forceGetChat();
//         ChatRoom.shared.closeChatStream();
//       },
//     );
//     if (test != null) {
//       setState(() {
//         message = test;
//         showSelection = true;
//       });
//     } else {
//       setState(() {
//         showSelection = false;
//       });
//     }
//   }

//   _showAlertDialog(BuildContext context, String title, var chat) {
//     void rightButtonCallBack() {
//       Navigator.pop(context);
//       ChatRoom.shared.deleteChat(chat);
//       globalBoolForForceGetChat = false;

//       ChatRoom.shared.forceGetChat();
//     }

//     void leftButtonCallBacK() {
//       Navigator.pop(context);
//     }

//     indigoCupertinoDialogAction(
//       context,
//       title,
//       leftButtonCallBacK: leftButtonCallBacK,
//       rightButtonCallBack: rightButtonCallBack,
//       isDestructiveAction: true,
//       leftButtonText: localization.yes,
//       rightButtonText: localization.no,
//     );
//   }

//   _listView(context, status, {myList}) {
//     return myList.isEmpty
//         // ? dbChats.isNotEmpty
//         //     ? localChatBuilder(dbChats)
//         ? InkWell(
//             onTap: () {
//               print("чат");
//               Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => ChatContactsPage()))
//                   .whenComplete(() {
//                 // ChatRoom.shared.contactController.close();
//                 // this is bool for check load more is needed or not
//                 ChatRoom.shared.forceGetChat();
//                 globalBoolForForceGetChat = false;

//                 ChatRoom.shared.closeContactsStream();
//               });
//             },
//             child: Container(
//               color: Colors.white,
//               child: Center(
//                 child: Wrap(
//                   alignment: WrapAlignment.center,
//                   crossAxisAlignment: WrapCrossAlignment.center,
//                   children: <Widget>[
//                     Image.asset("assets/chat_animation.gif"),
//                     Container(
//                       child: Text(
//                         "${localization.noChats} \n${localization.clickToStart}",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(fontSize: 20),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           )
//         // Center(child: CircularProgressIndicator())
//         : SmartRefresher(
//             enablePullDown: false,
//             enablePullUp: true,
//             // header: WaterDropHeader(),
//             footer: CustomFooter(
//               builder: (BuildContext context, LoadStatus mode) {
//                 Widget body;
//                 return Container(
//                   height: 55.0,
//                   child: Center(child: body),
//                 );
//               },
//             ),
//             controller: _refreshController,
//             onRefresh: _onRefresh,
//             onLoading: _onLoading,
//             child: ListView.builder(
//               itemCount: myList.length,
//               itemBuilder: (context, i) {
//                 // print(myList[i]);
//                 return Column(
//                   children: <Widget>[
//                     showSelection
//                         ? _chatListTile(myList, i, data: message)
//                         : Slidable(
//                             actionPane: SlidableDrawerActionPane(),
//                             actionExtentRatio: 0.25,
//                             secondaryActions: <Widget>[
//                               IconSlideAction(
//                                 caption:
//                                     '${myList[i]['mute'].toString() == '0' ? localization.mute : localization.unmute}',
//                                 color: myList[i]['mute'].toString() == '0'
//                                     ? redColor
//                                     : Colors.grey,
//                                 icon: myList[i]['mute'].toString() == '0'
//                                     ? Icons.volume_mute
//                                     : Icons.settings_backup_restore,
//                                 onTap: () {
//                                   myList[i]['mute'].toString() == '0'
//                                       ? ChatRoom.shared
//                                           .muteChat(myList[i]['id'], 1)
//                                       : ChatRoom.shared
//                                           .muteChat(myList[i]['id'], 0);
//                                   globalBoolForForceGetChat = false;

//                                   ChatRoom.shared.forceGetChat();
//                                 },
//                               ),
//                               IconSlideAction(
//                                 caption: '${localization.delete}',
//                                 color: Colors.red,
//                                 icon: Icons.delete,
//                                 onTap: () {
//                                   _showAlertDialog(
//                                     context,
//                                     '${localization.delete} ${localization.chat} ${myList[i]['name']}?',
//                                     myList[i]['id'],
//                                   );
//                                   ChatRoom.shared.forceGetChat();
//                                 },
//                               )
//                             ],
//                             child: _chatListTile(myList, i),
//                           ),
//                     Container(
//                       margin: EdgeInsets.only(left: 80, right: 20),
//                       height: 1,
//                       color: Colors.grey.shade300,
//                     )
//                   ],
//                 );
//               },
//             ),
//           );
//   }

//   ListTile _chatListTile(myList, int i, {data}) {
//     return ListTile(
//       onTap: () {
//         print('get message');
//         ChatRoom.shared.getMessages(myList[i]['id']);
//         _goToChat(
//           myList[i]['name'],
//           myList[i]['id'],
//           phone: myList[i]['another_user_phone'],
//           members: myList[i]['members'],
//           memberCount: myList[i]['members_count'],
//           chatType: myList[i]['type'],
//           userIds: myList[i]['another_user_id'],
//           avatar: myList[i]['avatar'].toString().replaceAll("AxB", "200x200"),
//           avatarUrl: myList[i]['avatar_url'],
//         );
//       },
//       leading: ClipRRect(
//         borderRadius: BorderRadius.circular(25.0),
//         child: Container(
//           height: 50,
//           width: 50,
//           color: greyColor,
//           child: ClipOval(
//             child: Image.network(
//               (myList[i]["avatar"] == null ||
//                       myList[i]["avatar"] == '' ||
//                       myList[i]["avatar"] == false)
//                   ? '${myList[i]['type'].toString() == '1' ? groupAvatarUrl : avatarUrl}noAvatar.png'
//                   : '${myList[i]['type'].toString() == '1' ? groupAvatarUrl : avatarUrl}${myList[i]["avatar"].toString().replaceAll("AxB", "200x200")}',
//             ),
//           ),
//         ),
//       ),
//       title: Text(
//         myList[i]["name"].toString().length != 0
//             ? "${myList[i]["name"][0].toUpperCase() + myList[i]["name"].substring(1)}"
//             : "",
//         maxLines: 1,
//         style: TextStyle(color: blackPurpleColor, fontWeight: FontWeight.w400),
//       ),
//       subtitle: Text(
//         myList[i]["last_message"].toString().length != 0
//             ? myList[i]["last_message"]['text'].toString().length != 0
//                 ? "${myList[i]["last_message"]['text'].toString()[0].toUpperCase() + myList[i]["last_message"]['text'].toString().substring(1)}"
//                 : myList[i]["last_message"]['message_for_type'] != null
//                     ? "${myList[i]["last_message"]['message_for_type'][0].toUpperCase() + myList[i]["last_message"]['message_for_type'].substring(1)}"
//                     : ""
//             : "",
//         overflow: TextOverflow.ellipsis,
//         maxLines: 1,
//         style: TextStyle(color: darkGreyColor2),
//       ),
//       trailing: Wrap(
//         direction: Axis.vertical,
//         crossAxisAlignment: WrapCrossAlignment.center,
//         alignment: WrapAlignment.center,
//         children: <Widget>[
//           Text(
//             myList[i]['last_message']["time"] == null
//                 ? "null"
//                 : _time(myList[i]['last_message']["time"]),
//             style: TextStyle(
//               color: blackPurpleColor,
//             ),
//             textAlign: TextAlign.right,
//           ),
//           myList[i]['unread_messages'] == 0
//               ? Container()
//               : Container(
//                   decoration: BoxDecoration(
//                       color: brightGreyColor4,
//                       borderRadius: BorderRadius.circular(10)),
//                   child: Text(
//                     " ${myList[i]['unread_messages']} ",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 )
//         ],
//       ),
//     );
//   }

//   String _time(timestamp) {
//     if (timestamp != null) {
//       if (timestamp != '') {
//         var messageUnixDate = DateTime.fromMillisecondsSinceEpoch(
//           int.parse("$timestamp") * 1000,
//         );
//         TimeOfDay messageDate =
//             TimeOfDay.fromDateTime(DateTime.parse('$messageUnixDate'));
//         var hours;
//         var minutes;
//         hours = '${messageDate.hour}';
//         minutes = '${messageDate.minute}';
//         var diff = DateTime.now().difference(messageUnixDate);
//         if (messageDate.hour.toString().length == 1)
//           hours = '0${messageDate.hour}';
//         if (messageDate.minute.toString().length == 1)
//           minutes = '0${messageDate.minute}';
//         if (diff.inDays == 0) {
//           return '${localization.today}\n$hours:$minutes';
//         } else if (diff.inDays < 7) {
//           int weekDay = messageUnixDate.weekday;
//           return identifyDay(weekDay) + '\n$hours:$minutes';
//         } else {
//           return '$messageUnixDate'.substring(0, 10).replaceAll('-', '.') +
//               '\n$hours:$minutes';
//         }
//       }
//     }
//     return '??:??';
//   }

//   @override
//   bool get wantKeepAlive => true;
// }
