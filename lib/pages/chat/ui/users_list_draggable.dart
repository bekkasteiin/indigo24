import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:indigo24/pages/wallet/transfers/transfer.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/services/user.dart' as user;

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
                        leading: Container(
                          width: 35,
                          height: 35,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25.0),
                            child: CachedNetworkImage(
                              errorWidget: (context, url, error) => Image.asset(
                                'assets/preloader.gif',
                              ),
                              imageUrl:
                                  '$avatarUrl${_users[i]['avatar'].toString().replaceAll("AxB", "200x200")}',
                            ),
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
}
