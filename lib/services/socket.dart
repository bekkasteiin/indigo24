import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/io.dart';
import 'package:indigo24/services/user.dart' as user;

class ChatRoom {
  static var shared = ChatRoom();
  final channel =
      new IOWebSocketChannel.connect('wss://chat.indigo24.xyz:9502');

  var changeController;
  var cabinetController;
  var contactController;
  var chatInfoController;

  Stream<MyEvent> get onChange => changeController.stream;
  Stream<MyContactEvent> get onContactChange => contactController.stream;
  Stream<MyCabinetEvent> get onCabinetChange => cabinetController.stream;
  Stream<MyChatInfoEvent> get onChatInfoChange => chatInfoController.stream;

  var lastMessage;
  var userId = user.id;
  var userToken = user.unique;

  setStream() {
    print("Setting StreamController for Events");
    changeController = new StreamController<MyEvent>();
  }

  setChatInfoStream() {
    print("Setting StreamController for Chat Info Events");
    chatInfoController = new StreamController<MyChatInfoEvent>();
  }

  setContactsStream() {
    print("Setting StreamController for Contact Events");
    contactController = new StreamController<MyContactEvent>();
  }

  setCabinetStream() {
    print("Setting StreamController for Cabinet Events");
    cabinetController = new StreamController<MyCabinetEvent>();
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

  closeContactsStream() {
    contactController.close();
  }

  closeStream() {
    changeController.close();
  }

  init() {
    print("Init is called");

    var data = json.encode({
      "cmd": 'init',
      "data": {
        "user_id": "$userId",
        "userToken": "$userToken",
      }
    });
    channel.sink.add(data);
  }

  checkUserOnline(ids) {
    var data = json.encode({
      "cmd": 'user:check:online',
      "data": {
        "user_id": '$userId',
        "users_ids": '$ids',
        "userToken": "$userToken",
      }
    });
    print('user:check:online ids $ids');
    channel.sink.add(data);
  }

  getMessages(String chatID, {page}) {
    print("getMessages is called");
    var data = json.encode({
      "cmd": 'chat:get',
      "data": {
        "chat_id": "$chatID",
        "user_id": "$userId",
        "userToken": "$userToken",
        "page": page == null ? 1 : page,
      }
    });
    channel.sink.add(data);
  }

  sendMessage(String chatID, String message) {
    message = message.replaceAll(new RegExp(r"\s{2,}"), " ");
    message = message.trimLeft();
    message = message.trimRight();
    if (message.isNotEmpty) {
      var data = json.encode({
        "cmd": 'message:create',
        "data": {
          "user_id": "$userId",
          "userToken": "$userToken",
          "chat_id": "$chatID",
          "text": '$message'
        }
      });
      print('added');
      channel.sink.add(data);
    } else {
      print('message is empty');
    }
  }

  chatMembers(users_ids, chatId) {
    var data = json.encode({
      "cmd": "chat:members",
      "data": {
        "userToken": "$userToken",
        "users_ids": "$users_ids",
        "chat_id": chatId,
        "user_id": userId,
      }
    });
    print('checked members');
    channel.sink.add(data);
  }

  userCheck(phone) {
    var data = json.encode({
      "cmd": "user:check",
      "data": {
        "user_id": userId,
        "userToken": "$userToken",
        "phone": phone,
      }
    });
    print('added');
    channel.sink.add(data);
  }

  cabinetCreate(ids, type, {title}) {
    var data = json.encode({
      "cmd": "chat:create",
      "data": {
        "user_id": userId,
        "userToken": "$userToken",
        "user_ids": ids,
        "type": type,
        "chat_name": title,
      }
    });
    print('cabinet created $data');
    channel.sink.add(data);
  }

  forceGetChat() {
    print("Force updating chats");
    var data = {
      "cmd": 'chats:get',
      "data": {
        "user_id": "$userId",
        "userToken": "$userToken",
        "page": '1',
      }
    };
    channel.sink.add(jsonEncode(data));
  }

  listen() {
    channel.stream.listen((event) {
      var json = jsonDecode(event);

      var cmd = json['cmd'];
      var data = json['data'];
      switch (cmd) {
        case "init":
          print(userId);
          print(data);
          if (data['status'] == 'true') {
            var data = {
              "cmd": 'chats:get',
              "data": {
                "user_id": "$userId",
                "userToken": "$userToken",
                "page": '1',
              }
            };
            channel.sink.add(jsonEncode(data));
          }
          break;
        case "chats:get":
          changeController.add(new MyEvent(json));
          break;
        case "chat:get":
          cabinetController.add(new MyCabinetEvent(json));
          break;
        case "message:create":
          if (cabinetController == null) {
            print("new message in CHATS null page");
          } else {
            if (!cabinetController.isClosed) {
              print("new message in CHAT page");
              cabinetController.add(new MyCabinetEvent(json));
            } else {
              print("new message in CHATS page");
            }
          }
          break;
        case "user:check":
          contactController.add(new MyContactEvent(json));
          break;
        case "user:check:online":
          cabinetController.add(new MyCabinetEvent(json));
          break;
        case "chat:create":
          contactController.add(new MyContactEvent(json));
          break;
        case "chat:members":
          print('added to chatInfoController');
          chatInfoController.add(new MyChatInfoEvent(json));
          break;
        default:
          print('default print cmd: $cmd json: $json');
      }
    });
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
