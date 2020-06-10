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
  Stream<MyEvent> get onChange => changeController.stream;
  Stream<MyCabinetEvent> get onCabinetChange => cabinetController.stream;

  var lastMessage;
  var user_id = user.id;
  var user_token = user.unique;

  setStream() {
    print("Setting StreamController for Events");
    changeController = new StreamController<MyEvent>();
  }

  setCabinetStream() {
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

  closeStream() {
    changeController.close();
  }

  init() {
    print("Init is called");

    var data = json.encode({
      "cmd": 'init',
      "data": {
        "user_id": "$user_id",
        "userToken": "$user_token",
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
        "user_id": "$user_id",
        "userToken": "$user_token",
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
          "user_id": "$user_id",
          "userToken": "$user_token",
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


  listen() {
    print("Listen is called");

    channel.stream.listen((event) {
      var json = jsonDecode(event);

      var cmd = json['cmd'];
      var data = json['data'];

      switch (cmd) {
        case "init":
          print(data);
          if (data['status'] == 'true') {
            var data = {
              "cmd": 'chats:get',
              "data": {
                "user_id": "$user_id",
                "userToken": "$user_token",
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

        default:
          print('default print: $json');
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

class MyCabinetEvent {
  var json;

  MyCabinetEvent(var json) {
    this.json = json;
  }
}
