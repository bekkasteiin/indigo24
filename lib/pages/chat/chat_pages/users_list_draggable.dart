import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:indigo24/pages/wallet/transfers/transfer.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/api/socket/socket.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/services/localization/localization.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/widgets/indigo_ui_kit/indigo_appbar_widget.dart';

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
    _listen();
    ChatRoom.shared.chatMembers(widget.chatId);
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
    await subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IndigoAppBarWidget(
        title: Text(
          "${Localization.language.chats}",
          style: TextStyle(
            color: blackPurpleColor,
            fontWeight: FontWeight.w400,
            fontSize: 22,
          ),
          textAlign: TextAlign.center,
        ),
        elevation: 0.5,
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

                    return true;
                  },
                  child: ScrollablePositionedList.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, i) {
                      if ('${_users[i]['user_id']}' == '${user.id}')
                        return SizedBox(
                          height: 0,
                          width: 0,
                        );
                      return Column(
                        children: [
                          ListTile(
                            leading: Container(
                              width: 35,
                              height: 35,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25.0),
                                child: CachedNetworkImage(
                                  errorWidget: (context, url, error) =>
                                      Image.network(
                                    '${avatarUrl}noAvatar.png',
                                  ),
                                  imageUrl:
                                      '$avatarUrl${_users[i]['avatar'].toString().replaceAll("AxB", "200x200")}',
                                ),
                              ),
                            ),
                            title: Text(
                              '${_users[i]['user_name']}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: blackPurpleColor,
                              ),
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

  StreamSubscription subscription;

  _listen() {
    subscription = ChatRoom.shared.userListStream.listen((e) {
      print("USERS DRAGABLE EVENT ${e.json['cmd']}");
      var cmd = e.json['cmd'];
      var data = e.json['data'];
      switch (cmd) {
        case "chat:members":
          _isMembersLoading = false;
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
}
