import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audio_cache.dart';
import 'package:web_socket_channel/io.dart';
import 'package:indigo24/services/user.dart' as user;

class ChatRoom {
  static var shared = ChatRoom();
  var channel =
      new IOWebSocketChannel.connect('wss://chat.indigo24.xyz:9502');

  var changeController;
  var cabinetController;
  var contactController;
  var chatInfoController;
  var cabinetInfoController;

  Stream<MyEvent> get onChange => changeController.stream;
  Stream<MyContactEvent> get onContactChange => contactController.stream;
  Stream<MyCabinetEvent> get onCabinetChange => cabinetController.stream;
  Stream<MyChatInfoEvent> get onChatInfoChange => chatInfoController.stream;
  Stream<MyCabinetInfoEvent> get onCabinetInfoChange => cabinetInfoController.stream;

  var lastMessage;

  void outSound(){
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
  
  // var userId = user.id;
  // var userToken = user.unique;

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


  closeConnection(){
    channel.sink.close();
  }
  
  init() {
    print("Init is called");

    var data = json.encode({
      "cmd": 'init',
      "data": {
        "user_id": "${user.id}",
        "userToken": "${user.unique}",
      }
    });
    print("INIT DATA $data");
    channel.sink.add(data);
  }

  makeAdmin(chatId,members) {
    var data = json.encode({
      "cmd": 'chat:members:privileges',
      "data": {
        "user_id": '${user.id}',
        "chat_id": '$chatId',
        "role": '2',
        "userToken": "${user.unique}",
        "members":"$members",
      }
    });
    channel.sink.add(data);
  }

  checkUserOnline(ids) {
    var data = json.encode({
      "cmd": 'user:check:online',
      "data": {
        "user_id": '${user.id}',
        "users_ids": '$ids',
        "userToken": "${user.unique}",
      }
    });
    print('user:check:online ids $ids');
    channel.sink.add(data);
  }

  deleteMembers(String chatID, members) {
    print("delete members is called $chatID $members");
    var data = json.encode({
      "cmd": 'chat:members:delete',
      "data": {
        "chat_id": "$chatID",
        "user_id": "${user.id}",
        "userToken": "${user.unique}",
        "members": "$members",
      }
    });
    channel.sink.add(data);
  }

  getMessages(String chatID, {page}) {
    print("getMessages is called");
    var data = json.encode({
      "cmd": 'chat:get',
      "data": {
        "chat_id": "$chatID",
        "user_id": "${user.id}",
        "userToken": "${user.unique}",
        "page": page == null ? 1 : page,
      }
    });
    print(data);
    channel.sink.add(data);
  }

  sendMessage(String chatID, String message, {int type, attachments}) {
    outSound();

    message = message.replaceAll(new RegExp(r"\s{2,}"), " ");
    message = message.trimLeft();
    message = message.trimRight();
    if (message.isNotEmpty) {
      var data = json.encode({
        "cmd": 'message:create',
        "data": {
          "user_id": "${user.id}",
          "userToken": "${user.unique}",
          "chat_id": "$chatID",
          "text": '$message',
          "message_type": type==null?0:type,
          "attachments": attachments==null?null:attachments
        }
      });
      print('added message');
      print("$data");
      channel.sink.add(data);
    } else {
      print('message is empty');
    }
  }

  chatMembers(users_ids, chatId) {
    var data = json.encode({
      "cmd": "chat:members",
      "data": {
        "userToken": "${user.unique}",
        "users_ids": "$users_ids",
        "chat_id": chatId,
        "user_id": '${user.id}',
      }
    });
    print('checked members');
    channel.sink.add(data);
  }

  userCheck(phone) {
    var data = json.encode({
      "cmd": "user:check",
      "data": {
        "user_id": "${user.id}",
        "userToken": "${user.unique}",
        "phone": phone,
      }
    });
    print('added user check');
    channel.sink.add(data);
  }

  deleteFromAll(chatId, messageId){
    var data = json.encode({
      "cmd": "message:deleted:all",
      "data": {
        "user_id": "${user.id}",
        "userToken": "${user.unique}",
        "chat_id": chatId,
        "message_id": messageId,
      }
    });
    print('message deleted from all $data');
    channel.sink.add(data);
  }
  
  typing(chatId){
    var data = json.encode({
      "cmd": "user:writing",
      "data": {
        "user_id": "${user.id}",
        "chat_id": chatId,
        "userToken": "${user.unique}"        
      }
    });
    print('sending status with $data');
    channel.sink.add(data);
  }


  cabinetCreate(ids, type, {title}) {
    var data = json.encode({
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
    channel.sink.add(data);
  }

  forceGetChat({page}) {
    print("Force updating chats");
    var data = {
      "cmd": 'chats:get',
      "data": {
        "user_id": "${user.id}",
        "userToken": "${user.unique}",
        "page": '1',
      }
    };
    channel.sink.add(jsonEncode(data));
  }

  connect(){
    channel = new IOWebSocketChannel.connect('wss://chat.indigo24.xyz:9502');
    listen();
  }

  listen() {
    
    channel.stream.listen(
      (event) {
        var json = jsonDecode(event);

        var cmd = json['cmd'];
        var data = json['data'];
        switch (cmd) {
          case "init":

            print(user.id);
            print(data);
            if (data['status'].toString() == 'true') {
              print("INIT status is ${data['status']}");
              forceGetChat();
              // var obj = {
              //   "cmd": 'chats:get',
              //   "data": {
              //     "user_id": "$userId",
              //     "userToken": "$userToken",
              //     "page": '1',
              //   }
              // };
              // channel.sink.add(jsonEncode(obj));
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
              inSound();
              changeController.add(new MyEvent(json));
              print("new message in CHATS null page");
            } else {
              if (!cabinetController.isClosed) {
                print("new message in CHAT page");
                // inSound();
                cabinetController.add(new MyCabinetEvent(json));
              } else {
                inSound();
                changeController.add(new MyEvent(json));
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
            forceGetChat();
            contactController.add(new MyContactEvent(json));
            break;
          case "chat:members":
            print('added to chatInfoController');
            chatInfoController.add(new MyChatInfoEvent(json));
            break;
          case "chat:members:privileges":
            print('added to chatInfoController');
            chatInfoController.add(new MyChatInfoEvent(json));
            break;
          case "user:writing": 
            if(cabinetController != null) cabinetController.add(new MyCabinetEvent(json));
            break;
          default:
            print('default print cmd: $cmd json: $json');
        }
      },
      onDone: () {
        print("ON DONE IS CALLED");
        connect();
        init();
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

