import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/pages/chat/chat_list.dart';
import 'package:indigo24/services/constants.dart';
import 'package:web_socket_channel/io.dart';
import 'package:indigo24/services/user.dart' as user;

class ChatRoom {
  static ChatRoom shared = ChatRoom();
  IOWebSocketChannel channel = new IOWebSocketChannel.connect('$socket');

  var changeController;
  var cabinetController;
  var contactController;
  var chatInfoController;
  var cabinetInfoController;
  var notificationSettingsController;
  var settingsController;

  Stream<MyEvent> get onChange => changeController.stream;
  Stream<MyContactEvent> get onContactChange => contactController.stream;
  Stream<MyCabinetEvent> get onCabinetChange => cabinetController.stream;
  Stream<MyChatInfoEvent> get onChatInfoChange => chatInfoController.stream;
  Stream<MyCabinetInfoEvent> get onCabinetInfoChange =>
      cabinetInfoController.stream;
  Stream<NotificationSettingsEvent> get onNotificationSettingsChange =>
      notificationSettingsController.stream;
  Stream<SettingsEvent> get onSettingsChange => settingsController.stream;

  void outSound() {
    print("msg out sound is called");
    final player = AudioCache();
    player.play("sound/msg_out.mp3");
  }

  void inSound1() async {
    print("msg in sound is called");
    final player = AudioCache();
    await player.play("sound/messageIn.mp3");
  }

  void inSound() async {
    print("msg in sound is called");
    final player = AudioCache();
    await player.play("sound/message_in.mp3");
  }

  setStream() {
    print("Setting StreamController for Events");
    changeController = new StreamController<MyEvent>();
  }

  setChatInfoStream() {
    print("Setting StreamController for Chat Info Events");
    chatInfoController = new StreamController<MyChatInfoEvent>();
  }

  setCabinetInfoStream() {
    print("Setting StreamController for Chat Info Events");
    cabinetInfoController = new StreamController<MyCabinetInfoEvent>();
  }

  setContactsStream() {
    print("Setting StreamController for Contact Events");
    contactController = new StreamController<MyContactEvent>();
  }

  setCabinetStream() {
    print("Setting StreamController for Cabinet Events");
    cabinetController = new StreamController<MyCabinetEvent>();
  }

  setSettingsStream() {
    print("Setting StreamController for Settings Event");
    settingsController = new StreamController<SettingsEvent>();
  }

  setNotificationSettingsStream() {
    print("Setting StreamController for Notifcation Settings Event");
    notificationSettingsController =
        new StreamController<NotificationSettingsEvent>();
  }

  csIsClosed() {
    return cabinetController.isClosed ? true : false;
  }

  sIsClosed() {
    return changeController.isClosed ? true : false;
  }

  closeCabinetStream() {
    cabinetController.close();
  }

  closeCabinetInfoStream() {
    cabinetInfoController.close();
  }

  closeContactsStream() {
    contactController.close();
  }

  closeStream() {
    changeController.close();
  }

  closeNotificationSettingsStream() {
    notificationSettingsController.close();
  }

  closeSettingsStream() {
    settingsController.close();
  }

  closeConnection() {
    channel.sink.close();
  }

  sendSocketData(data) {
    print('adding $data');
    channel.sink.add(data);
  }

  connect(context) {
    channel = new IOWebSocketChannel.connect('$socket');
    listen(context);
  }

  init() {
    print("Init is called");
    String data = json.encode({
      "cmd": 'init',
      "data": {
        "user_id": "${user.id}",
        "userToken": "${user.unique}",
      }
    });
    sendSocketData(data);
  }

  changePrivileges(chatId, members, role) {
    String data = json.encode({
      "cmd": 'chat:members:privileges',
      "data": {
        "user_id": '${user.id}',
        "chat_id": '$chatId',
        "role": '$role',
        "userToken": "${user.unique}",
        "members": "$members",
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
    print('getting user data');
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
    print("delete members is called $chatID $members");
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

  getMessages(String chatID, {page}) {
    print("getMessages is called");
    String data = json.encode({
      "cmd": 'chat:get',
      "data": {
        "chat_id": "$chatID",
        "user_id": "${user.id}",
        "userToken": "${user.unique}",
        "page": page == null ? 1 : page,
      }
    });
    sendSocketData(data);
  }

  readMessage(chatId, messageId) {
    String data = json.encode({
      "cmd": "message:write",
      "data": {
        "userToken": "${user.unique}",
        "chat_id": chatId,
        "user_id": '${user.id}',
        "message_id": '$messageId',
      }
    });
    sendSocketData(data);
  }

  sendMessage(String chatID, String message,
      {int type, var fileId, attachments}) {
    outSound();

    message = message.replaceAll(new RegExp(r"\s{2,}"), " ");
    message = message.trimLeft();
    message = message.trimRight();
    String data = json.encode({
      "cmd": 'message:create',
      "data": {
        "user_id": "${user.id}",
        "userToken": "${user.unique}",
        "chat_id": "$chatID",
        "text": '$message',
        "message_type": type == null ? 0 : type,
        "file_id": fileId == null ? 0 : fileId,
        "attachments": attachments == null ? null : attachments
      }
    });
    print('added message');
    print("$data");
    sendSocketData(data);
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
    print('settings setted $boolean');
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
    print('chat members');
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
    print('deleted members');
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
    print('chat name changed $data');
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
    print('message deleted from all $data');
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
    print('sending status with $data');
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
    print('cabinet created $data');
    sendSocketData(data);
  }

  forceGetChat({page}) {
    print("Force updating chats");
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
    print("EDITING IN SOCKET $m");
    var object = {
      "cmd": "editMessage",
      "text": m['text'],
      "message_id": m['id'],
      "message": m
    };
    var json = jsonDecode(jsonEncode(object));

    if (cabinetController != null)
      cabinetController.add(new MyCabinetEvent(json));
  }

  findMessage(i) {
    var object = {
      "cmd": "findMessage",
      "index": i,
    };
    var json = jsonDecode(jsonEncode(object));

    if (cabinetController != null)
      cabinetController.add(new MyCabinetEvent(json));
  }

  replyingMessage(m) {
    print("REPLYING IN SOCKET $m");
    var object = {
      "cmd": "replyMessage",
      "text": m['text'],
      "message_id": m['id'],
      "message": m
    };
    var json = jsonDecode(jsonEncode(object));

    if (cabinetController != null)
      cabinetController.add(new MyCabinetEvent(json));
  }

  forwardMessage(m, String text, String chatIds) {
    print("FORWARD MESSAGE TO SOCKET $m");
    String data = json.encode({
      "cmd": 'message:forward',
      "data": {
        "user_id": "${user.id}",
        "userToken": "${user.unique}",
        "chat_id": chatIds,
        "text": text,
        "forward_messages_id": m['id'],
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
      print('added message');
      print("$data");
      sendSocketData(data);
    } else {
      print('message is empty');
    }
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
    print('send money to chat created $data');
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
    print('muting chat $chatId');
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
    print('deleting chat $chatId');
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
    print('searching $search chat members in chat N$chatId $data');
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
      print('added message');
      print("$data");
      sendSocketData(data);
    } else {
      print('message is empty');
    }
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
          print(json);
          switch (cmd) {
            case "init":
              print(user.id);
              print(data);
              if (data['status'].toString() == 'true') {
                print("INIT status is ${data['status']}");
                // this is bool for check load more is needed or not
                globalBoolForForceGetChat = false;
                forceGetChat();
              }
              break;
            case "chats:get":
              changeController.add(MyEvent(json));
              break;
            case "chat:get":
              if (!cabinetController.isClosed) {
                cabinetController.add(MyCabinetEvent(json));
              }
              break;
            case "message:create":
              // this is bool for check load more is needed or not
              globalBoolForForceGetChat = false;
              forceGetChat();
              if (cabinetController == null) {
                // inSound();
                changeController.add(MyEvent(json));
                print("new message in CHATS null page");
              } else {
                if (!cabinetController.isClosed) {
                  print("new message in CHAT page");
                  cabinetController.add(MyCabinetEvent(json));
                } else {
                  changeController.add(MyEvent(json));
                  print("new message in CHATS page");
                }
              }
              break;
            case "user:check":
              if (contactController != null) {
                contactController.add(MyContactEvent(json));
              }
              if (cabinetInfoController != null) {
                if (!cabinetInfoController.isClosed) {
                  print('added to cabinet info');
                  cabinetInfoController.add(MyCabinetInfoEvent(json));
                }
              }
              if (changeController != null) {
                changeController.add(MyEvent(json));
              }
              break;
            case "chat:members:add":
              contactController.add(MyContactEvent(json));
              break;
            case "user:check:online":
              cabinetController.add(MyCabinetEvent(json));
              break;
            case "chat:create":
              // this is bool for check load more is needed or not
              globalBoolForForceGetChat = false;
              forceGetChat();
              contactController.add(MyContactEvent(json));
              break;
            case "chat:members":
              print('added to chatInfoController');
              if (chatInfoController != null) {
                chatInfoController.add(MyChatInfoEvent(json));
              }
              if (cabinetController != null && !cabinetController.isClosed) {
                cabinetController.add(MyCabinetEvent(json));
              }
              break;
            case "chat:member:search":
              print('added to chatInfoController');
              chatInfoController.add(MyChatInfoEvent(json));
              break;
            case "chat:members:privileges":
              print('added to chatInfoController');
              chatInfoController.add(MyChatInfoEvent(json));
              break;
            case "user:writing":
              if (cabinetController != null && !cabinetController.isClosed)
                cabinetController.add(MyCabinetEvent(json));
              break;
            case "message:deleted:all":
              if (cabinetController != null)
                cabinetController.add(MyCabinetEvent(json));
              break;
            case "message:edit":
              if (cabinetController != null)
                cabinetController.add(MyCabinetEvent(json));
              break;
            case "chat:members:delete":
              print('added to chatInfoController');
              chatInfoController.add(MyChatInfoEvent(json));
              break;
            case "chat:member:leave":
              print('added to chatInfoController');
              chatInfoController.add(MyChatInfoEvent(json));
              break;
            case "message:write":
              changeController.add(MyEvent(json));
              print("adding message write to chat");
              break;
            case 'user:settings:get':
              user.settings = data;

              if (settingsController != null) {
                settingsController.add(SettingsEvent(json));
              }
              user.settings = data;
              print("adding settings get to settings");
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

class MyEvent {
  var json;

  MyEvent(var json) {
    this.json = json;
  }
}

class MyContactEvent {
  var json;

  MyContactEvent(var json) {
    this.json = json;
  }
}

class MyCabinetEvent {
  var json;

  MyCabinetEvent(var json) {
    this.json = json;
  }
}

class MyChatInfoEvent {
  var json;

  MyChatInfoEvent(var json) {
    this.json = json;
  }
}

class MyCabinetInfoEvent {
  var json;

  MyCabinetInfoEvent(var json) {
    this.json = json;
  }
}

class NotificationSettingsEvent {
  var json;

  NotificationSettingsEvent(var json) {
    this.json = json;
  }
}

class SettingsEvent {
  var json;

  SettingsEvent(var json) {
    this.json = json;
  }
}
