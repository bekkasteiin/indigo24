import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/widgets/alerts/indigo_logout.dart';
import 'package:indigo24/services/constants.dart';
import 'package:web_socket_channel/io.dart';
import 'package:indigo24/services/user.dart' as user;

class SocketEvent {
  var json;

  SocketEvent(var json) {
    this.json = json;
  }
}

class ChatRoom {
  static ChatRoom shared = ChatRoom();
  IOWebSocketChannel channel = IOWebSocketChannel.connect('$socket');

  StreamController mainS = StreamController<SocketEvent>.broadcast();
  StreamController contactS = StreamController<SocketEvent>.broadcast();
  StreamController infoS = StreamController<SocketEvent>.broadcast();
  StreamController profileS = StreamController<SocketEvent>.broadcast();
  StreamController settingsS = StreamController<SocketEvent>.broadcast();
  StreamController chatsListS = StreamController<SocketEvent>.broadcast();
  StreamController userListS = StreamController<SocketEvent>.broadcast();
  StreamController chatS = StreamController<SocketEvent>.broadcast();
  StreamController chatsS = StreamController<SocketEvent>.broadcast();

  Stream<SocketEvent> get chatStream => chatS.stream;
  Stream<SocketEvent> get chatsStream => chatsS.stream;
  Stream<SocketEvent> get userListStream => userListS.stream;
  Stream<SocketEvent> get mainStream => mainS.stream;
  Stream<SocketEvent> get contactStream => contactS.stream;
  Stream<SocketEvent> get infoStream => infoS.stream;
  Stream<SocketEvent> get profileStream => profileS.stream;
  Stream<SocketEvent> get settingsStream => settingsS.stream;
  Stream<SocketEvent> get chatsListStream => chatsListS.stream;

  connect(context) {
    channel = new IOWebSocketChannel.connect('$socket');
    listen(context);
  }

  closeConnection() {}

  void outSound() {
    final player = AudioCache();
    player.play("sound/msg_out.mp3");
  }

  void inSound1() async {
    final player = AudioCache();
    await player.play("sound/messageIn.mp3");
  }

  void inSound() async {
    final player = AudioCache();
    await player.play('sound/' + user.sound);
  }

  sendSocketData(data) {
    print('adding to socket ${json.decode(data)}');
    channel.sink.add(data);
  }

  init() {
    String data = json.encode({
      "cmd": 'init',
      "data": {
        "user_id": "${user.id}",
        "userToken": "${user.unique}",
      }
    });
    sendSocketData(data);
  }

  changePrivileges(chatId, List<int> members, int role) {
    String data = json.encode({
      "cmd": 'chat:members:privileges',
      "data": {
        "user_id": '${user.id}',
        "chat_id": '$chatId',
        "role": role,
        "userToken": "${user.unique}",
        "members": members,
      }
    });
    sendSocketData(data);
  }

  getUserSettings() {
    String data = json.encode({
      "cmd": 'user:settings:get',
      "data": {
        "user_id": '${user.id}',
        "userToken": "${user.unique}",
      }
    });
    sendSocketData(data);
  }

  checkUserOnline(ids) {
    String data = json.encode({
      "cmd": 'user:check:online',
      "data": {
        "user_id": '${user.id}',
        "users_ids": '$ids',
        "userToken": "${user.unique}",
      }
    });
    sendSocketData(data);
  }

  deleteMembers(String chatID, members) {
    String data = json.encode({
      "cmd": 'chat:members:delete',
      "data": {
        "chat_id": "$chatID",
        "user_id": "${user.id}",
        "userToken": "${user.unique}",
        "members": "$members",
      }
    });
    sendSocketData(data);
  }

  leaveChat(chatID) {
    String data = json.encode({
      "cmd": 'chat:member:leave',
      "data": {
        "chat_id": "$chatID",
        "user_id": "${user.id}",
        "userToken": "${user.unique}",
      }
    });
    sendSocketData(data);
  }

  addMembers(String chatID, members) {
    String data = json.encode({
      "cmd": 'chat:members:add',
      "data": {
        "chat_id": "$chatID",
        "user_id": "${user.id}",
        "userToken": "${user.unique}",
        "members_id": "$members",
      }
    });
    sendSocketData(data);
  }

  getMessages(chatID, {page}) {
    String data = json.encode({
      "cmd": 'chat:get',
      "data": {
        "chat_id": chatID,
        "user_id": "${user.id}",
        "userToken": "${user.unique}",
        "page": page == null ? 1 : page,
      }
    });
    sendSocketData(data);
  }

  readMessage(chatId, messageId) {
    String data = json.encode({
      "cmd": "message:read",
      "data": {
        "userToken": "${user.unique}",
        "chat_id": chatId,
        "user_id": '${user.id}',
        "message_id": '$messageId',
      }
    });
    sendSocketData(data);
  }

  sendMessage(chatID, String message,
      {int stickerId, int type, var fileId, attachments}) {
    outSound();
    message = message.replaceAll(new RegExp(r"\s{2,}"), " ");
    message = message.trimLeft();
    message = message.trimRight();
    List wordsList = message.split(' ');
    int maxWordCount = 200;
    String text;
    String data;
    if (wordsList.length > maxWordCount) {
      int repeatCount = wordsList.length ~/ maxWordCount;

      for (int i = 1; i < repeatCount + 1; i++) {
        text = wordsList.sublist(0, maxWordCount * i).join(' ');
        data = json.encode({
          "cmd": 'message:create',
          "data": {
            "user_id": "${user.id}",
            "userToken": "${user.unique}",
            "chat_id": "$chatID",
            "text": '$text',
            "message_type": type == null ? 0 : type,
            "file_id": fileId == null ? 0 : fileId,
            "attachments": attachments == null ? null : attachments
          }
        });
        sendSocketData(data);
      }
    } else {
      text = message;
      data = json.encode({
        "cmd": 'message:create',
        "data": {
          "user_id": "${user.id}",
          "userToken": "${user.unique}",
          "chat_id": "$chatID",
          "text": '$text',
          "message_type": type == null ? 0 : type,
          "file_id": fileId == null ? 0 : fileId,
          "attachments": attachments == null ? null : attachments
        }
      });
      sendSocketData(data);
    }
  }

  setUserSettings(int boolean) {
    String data = json.encode({
      "cmd": "user:settings:set",
      "data": {
        "userToken": "${user.unique}",
        "user_id": int.parse(user.id),
        "settings": {
          "chat_all_mute": '$boolean',
        },
      }
    });
    sendSocketData(data);
  }

  chatMembers(chatId, {page}) {
    String data = json.encode({
      "cmd": "chat:members",
      "data": {
        "userToken": "${user.unique}",
        "chat_id": chatId,
        "user_id": '${user.id}',
        'page': '$page' != 'null' ? '$page' : '1',
      }
    });
    sendSocketData(data);
  }

  getStickers() {
    String data = json.encode({
      "cmd": "chat:stickers",
      "data": {
        "userToken": "${user.unique}",
        "user_id": '${user.id}',
      }
    });
    sendSocketData(data);
  }

  deleteChatMember(chatId, memberId) {
    String data = json.encode({
      "cmd": "chat:members:delete",
      "data": {
        "userToken": "${user.unique}",
        "member_id": "$memberId",
        "chat_id": '$chatId',
        "user_id": '${user.id}',
      }
    });
    sendSocketData(data);
  }

  userCheck(phone) {
    String data = json.encode({
      "cmd": "user:check",
      "data": {
        "user_id": "${user.id}",
        "userToken": "${user.unique}",
        "phone": phone,
      }
    });
    sendSocketData(data);
  }

  userCheckById(id) {
    String data = json.encode({
      "cmd": "check:user:id",
      "data": {
        "user_id": "${user.id}",
        "userToken": "${user.unique}",
        "check_user_id": id,
      }
    });
    sendSocketData(data);
  }

  changeChatName(chatId, chatName) {
    String data = json.encode({
      "cmd": "chat:change:name",
      "data": {
        "user_id": "${user.id}",
        "userToken": "${user.unique}",
        "chat_id": "$chatId",
        "chat_name": "$chatName",
      }
    });
    sendSocketData(data);
  }

  deleteFromAll(chatId, messageId) {
    String data = json.encode({
      "cmd": "message:deleted:all",
      "data": {
        "user_id": "${user.id}",
        "userToken": "${user.unique}",
        "chat_id": chatId,
        "message_id": messageId,
      }
    });
    sendSocketData(data);
  }

  typing(chatId) {
    String data = json.encode({
      "cmd": "user:writing",
      "data": {
        "user_id": "${user.id}",
        "chat_id": chatId,
        "userToken": "${user.unique}"
      }
    });
    sendSocketData(data);
  }

  cabinetCreate(ids, type, {title}) {
    String data = json.encode({
      "cmd": "chat:create",
      "data": {
        "user_id": "${user.id}",
        "userToken": "${user.unique}",
        "user_ids": ids,
        "type": type,
        "chat_name": title,
      }
    });
    sendSocketData(data);
  }

  forceGetChat({page}) {
    String data = json.encode({
      "cmd": 'chats:get',
      "data": {
        "user_id": "${user.id}",
        "userToken": "${user.unique}",
        "page": page == null ? 1 : page,
      }
    });
    sendSocketData(data);
  }

  editingMessage(m) {
    var object = {
      "cmd": "editMessage",
      "text": m.text,
      "message_id": m.id,
      "message": m.toJson()
    };

    if (chatS != null) chatS.add(SocketEvent(object));
  }

  localForwardMessage(String id) {
    var object = {
      "cmd": "forwardMessage",
      "id": id,
    };
    var json = jsonDecode(jsonEncode(object));

    chatS.add(SocketEvent(json));
  }

  findMessage(id) {
    var object = {
      "cmd": "findMessage",
      "index": id,
    };

    if (chatS != null) chatS.add(SocketEvent(object));
  }

  replyingMessage(m) {
    var object = {
      "cmd": "replyMessage",
      "text": m.text,
      "message_id": m.id,
      "message": m.toJson()
    };
    if (chatS != null) chatS.add(SocketEvent(object));
  }

  forwardMessage(m, String text, String chatIds) {
    String data = json.encode({
      "cmd": 'message:forward',
      "data": {
        "user_id": "${user.id}",
        "userToken": "${user.unique}",
        "chat_id": chatIds,
        "text": text,
        "forward_messages_id": m,
      }
    });
    sendSocketData(data);
  }

  editMessage(message, chatID, type, time, mId) {
    outSound();

    message = message.replaceAll(new RegExp(r"\s{2,}"), " ");
    message = message.trimLeft();
    message = message.trimRight();
    if (message.isNotEmpty) {
      String data = json.encode({
        "cmd": 'message:edit',
        "data": {
          "user_id": "${user.id}",
          "userToken": "${user.unique}",
          "chat_id": "$chatID",
          "text": '$message',
          "message_id": mId,
          "message_type": type == null ? 0 : type,
          "time": time
          // "attachments": attachments==null?null:attachments
        }
      });
      sendSocketData(data);
    } else {}
  }

  sendMoney(token, chatId) {
    String data = json.encode({
      "cmd": "message:create",
      "data": {
        "user_id": "${user.id}",
        "userToken": "${user.unique}",
        "payment_chat_token": '$token',
        "chat_id": '$chatId',
        "message_type": '11',
      }
    });
    sendSocketData(data);
  }

  muteChat(chatId, mute) {
    String data = json.encode({
      "cmd": "chat:mute",
      "data": {
        "userToken": "${user.unique}",
        "chat_id": '$chatId',
        "user_id": '${user.id}',
        'mute': '$mute',
      }
    });
    sendSocketData(data);
  }

  deleteChat(chatId) {
    String data = json.encode({
      "cmd": "chat:delete",
      "data": {
        "user_id": '${user.id}',
        "userToken": "${user.unique}",
        "chat_id": '$chatId',
      }
    });
    sendSocketData(data);
  }

  setGroupAvatar(int chatId, String fileName) {
    String data = json.encode({
      "cmd": "set:group:avatar",
      "data": {
        "user_id": "${user.id}",
        "userToken": "${user.unique}",
        'file_name': fileName,
        "chat_id": '$chatId',
      }
    });
    sendSocketData(data);
  }

  getMessagesByType(int chatId, String type, {int page = 1}) {
    String data = json.encode({
      "cmd": "chat:message:by:type",
      "data": {
        "user_id": "${user.id}",
        "userToken": "${user.unique}",
        "page": '$page',
        'chat_id': '$chatId',
        "type": '$type',
      }
    });
    sendSocketData(data);
  }

  searchChatMembers(search, chatId) {
    String data = json.encode({
      "cmd": "chat:member:search",
      "data": {
        "user_id": "${user.id}",
        "chat_id": '$chatId',
        "userToken": "${user.unique}",
        "search": '$search',
      }
    });
    sendSocketData(data);
  }

  replyMessage(message, chatID, type, mId) {
    outSound();

    message = message.replaceAll(new RegExp(r"\s{2,}"), " ");
    message = message.trimLeft();
    message = message.trimRight();
    if (message.isNotEmpty) {
      String data = json.encode({
        "cmd": 'message:create',
        "data": {
          "user_id": "${user.id}",
          "userToken": "${user.unique}",
          "chat_id": "$chatID",
          "text": '$message',
          "message_id": mId,
          "message_type": type == null ? 0 : type,
        }
      });
      sendSocketData(data);
    } else {}
  }

  listen(BuildContext context) {
    channel.stream.listen(
      (event) {
        var json = jsonDecode(event);
        if (json['logout'] != null && json['logout'] == true) {
          logOut(context);
        } else {
          var cmd = json['cmd'];
          var data = json['data'];
          switch (cmd) {
            case "init":
              if (data['status'].toString() == 'true') {
                forceGetChat();
              }
              break;
            case "chats:get":
              if (chatsS != null) chatsS.add(SocketEvent(json));
              if (chatsListS != null && !chatsListS.isClosed) {
                chatsListS.add(SocketEvent(json));
              } else {
                mainS.add(SocketEvent(json));
              }
              break;
            case "chat:get":
              if (chatS != null && !chatS.isClosed) {
                chatS.add(SocketEvent(json));
              }
              break;
            case "message:create":
              mainS.add(SocketEvent(json));
              if (chatS != null) chatS.add(SocketEvent(json));
              if (chatsS != null && !chatsS.isClosed) {
                chatsS.add(SocketEvent(json));
              }

              break;
            case "chat:message:by:type":
              if (infoS != null) {
                infoS.add(SocketEvent(json));
              }
              break;
            case "user:check":
              if (contactS != null && !contactS.isClosed) {
                contactS.add(SocketEvent(json));
              }
              if (infoS != null) {
                if (!infoS.isClosed) infoS.add(SocketEvent(json));
              }
              if (profileS != null) {
                if (!profileS.isClosed) {
                  profileS.add(SocketEvent(json));
                }
              }
              if (mainS != null) {
                mainS.add(SocketEvent(json));
              }
              break;
            case "chat:members:add":
              contactS.add(SocketEvent(json));
              break;
            case "user:check:online":
              if (chatS != null) chatS.add(SocketEvent(json));
              break;
            case "chat:create":
              infoS.add(SocketEvent(json));
              if (contactS != null) contactS.add(SocketEvent(json));
              break;
            case "chat:members":
              if (userListS != null) {
                userListS.add(SocketEvent(json));
              }
              if (infoS != null) {
                infoS.add(SocketEvent(json));
              }
              chatS.add(SocketEvent(json));
              break;
            case "chat:member:search":
              infoS.add(SocketEvent(json));
              break;
            case "set:group:avatar":
              infoS.add(SocketEvent(json));
              break;
            case "chat:members:privileges":
              infoS.add(SocketEvent(json));
              break;
            case "user:writing":
              if (chatS != null) chatS.add(SocketEvent(json));
              if (chatsS != null) chatsS.add(SocketEvent(json));
              break;
            case "message:deleted:all":
              if (chatS != null) chatS.add(SocketEvent(json));
              break;
            case "message:edit":
              if (chatS != null) chatS.add(SocketEvent(json));
              break;
            case "chat:members:delete":
              infoS.add(SocketEvent(json));
              break;
            case "chat:member:leave":
              infoS.add(SocketEvent(json));
              break;
            case "message:write":
              chatS.add(SocketEvent(json));
              break;
            case "message:read":
              chatS.add(SocketEvent(json));
              break;
            case "check:user:id":
              infoS.add(SocketEvent(json));
              break;
            case 'user:settings:get':
              user.settings = data;

              if (settingsS != null) {
                settingsS.add(SocketEvent(json));
              }
              user.settings = data;
              break;
            case 'chat:delete':
              chatsS.add(SocketEvent(json));
              break;
            case 'chat:mute':
              chatsS.add(SocketEvent(json));
              break;
            case 'chat:stickers':
              if (chatS != null) chatS.add(SocketEvent(json));
              break;
            default:
              print('default print cmd: $cmd json: $json');
          }
        }
      },
      onDone: () {
        print("ON DONE IS CALLED");
        Future.delayed(const Duration(seconds: 1), () {
          connect(context);
          init();
        });
      },
    );
  }
}
