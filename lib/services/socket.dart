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

  Stream<MyEvent> get onChange => changeController.stream;
  Stream<MyContactEvent> get onContactChange => contactController.stream;
  Stream<MyCabinetEvent> get onCabinetChange => cabinetController.stream;

  var lastMessage;
  var userId = user.id;
  var userToken = user.unique;

  setStream() {
    print("Setting StreamController for Events");
    changeController = new StreamController<MyEvent>();
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

  getMessages(String chatID) {
    print("getMessages is called");

    var data = json.encode({
      "cmd": 'chat:get',
      "data": {
        "chat_id": "$chatID",
        "user_id": "$userId",
        "userToken": "$userToken",
        "page": 1,
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

  cabinetCreate(ids, type) {
    var data = json.encode({
      "cmd": "chat:create",
      "data": {
        "user_id": userId,
        "userToken": "$userToken",
        "user_ids": ids,
        "type": type
      }
    });
    print('cabinet created $data');
    channel.sink.add(data);
  }

  forceGetChat(){
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
    print("Listen is called");

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
          forceGetChat();
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
        case "chat:create":
          contactController.add(new MyContactEvent(json));
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
