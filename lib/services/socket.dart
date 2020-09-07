import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/pages/chat/chat_list.dart';
import 'package:indigo24/services/constants.dart';
import 'package:web_socket_channel/io.dart';
import 'package:indigo24/services/user.dart' as user;

class NewChatEvent {
  var json;

  NewChatEvent(var json) {
    this.json = json;
  }
}

class NewChatsEvent {
  var json;

  NewChatsEvent(var json) {
    this.json = json;
  }
}

class UsersListEvent {
  var json;

  UsersListEvent(var json) {
    this.json = json;
  }
}

class ChatRoom {
  static ChatRoom shared = ChatRoom();
  IOWebSocketChannel channel = new IOWebSocketChannel.connect('$socket');

  StreamController chatsListController;
  // StreamController chatController;
  StreamController contactController;
  StreamController chatInfoController;
  StreamController chatUserProfileController;
  StreamController notificationSettingsController;
  StreamController settingsController;
  StreamController chatsListDialogController;
  StreamController newUsersListDialogController;
  StreamController newChatController;
  StreamController newChatsController;
  Stream<NewChatEvent> get onNewChatChange => newChatController.stream;
  Stream<NewChatsEvent> get onNewChatsChange => newChatsController.stream;
  Stream<UsersListEvent> get onUsersListDialogChange =>
      newUsersListDialogController.stream;
  setNewUsersListStream() {
    print("Setting StreamControllers for Events");
    newUsersListDialogController = StreamController<UsersListEvent>();
  }

  setNewChatsStream() {
    print("Setting StreamControllers for Events");
    newChatsController = StreamController<NewChatsEvent>();
  }

  setNewChatStream() {
    print("Setting StreamController for Events");
    newChatController = StreamController<NewChatEvent>();
  }

  closeNewChatStream() {
    // newChatController.close();
  }

  Stream<ChatsListEvent> get onMainChange => chatsListController.stream;
  Stream<MyContactEvent> get onContactChange => contactController.stream;
  // Stream<MyChatEvent> get onChatChange => chatController.stream;
  Stream<MyChatInfoEvent> get onChatInfoChange => chatInfoController.stream;
  Stream<MyChatUserProfileEvent> get onChatUserProfileChange =>
      chatUserProfileController.stream;
  Stream<NotificationSettingsEvent> get onNotificationSettingsChange =>
      notificationSettingsController.stream;
  Stream<SettingsEvent> get onSettingsChange => settingsController.stream;

  Stream<ChatListDialog> get onChatsListDialog =>
      chatsListDialogController.stream;

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

  sendSocketData(data) {
    print('adding to socket $channel $data');
    channel.sink.add(data);
  }

  setChatsListStream() {
    print("Setting StreamController for Events");
    chatsListController = StreamController<ChatsListEvent>();
  }

  closeChatsListStream() {
    // chatsListController.close();
  }

  setChatInfoStream() {
    print("Setting StreamController for Chat Info Events");
    chatInfoController = StreamController<MyChatInfoEvent>();
  }

  closeChatInfoStream() {
    // chatInfoController.close();
  }

  setChatUserProfileInfoStream() {
    print("Setting StreamController for Chat User Profile Stream");
    chatUserProfileController = StreamController<MyChatUserProfileEvent>();
  }

  chatUserProfileStream() {
    // chatUserProfileController.close();
  }

  setContactsStream() {
    print("Setting StreamController for Contact Events");
    contactController = StreamController<MyContactEvent>();
  }

  closeContactsStream() {
    // contactController.close();
  }

  // setChatStream() {
  //   print("Setting StreamController for Cabinet Events");
  //   // chatController = StreamController<MyChatEvent>();
  // }

  closeChatStream() {
    // chatController.close();
  }

  setSettingsStream() {
    print("Setting StreamController for Settings Event");
    settingsController = StreamController<SettingsEvent>();
  }

  closeSettingsStream() {
    // settingsController.close();
  }

  setNotificationSettingsStream() {
    print("Setting StreamController for Notifcation Settings Event");
    notificationSettingsController =
        StreamController<NotificationSettingsEvent>();
  }

  closeNotificationSettingsStream() {
    // notificationSettingsController.close();
  }

  setChatsListDialogStream() {
    print("Setting StreamController for Settings Event");
    chatsListDialogController = StreamController<ChatListDialog>();
  }

  closeChatsListDialogStream() {
    // chatsListDialogController.close();
  }

  connect(context) {
    channel = new IOWebSocketChannel.connect('$socket');
    listen(context);
  }

  closeConnection() {
    // channel.sink.close();
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

  getMessages(chatID, {page}) {
    print("getMessages is called");
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
        print(
          wordsList.length - maxWordCount * i,
        );

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
        print('added message');
        print("$data");
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
      print('added message');
      print("$data");
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

  getStickers() {
    String data = json.encode({
      "cmd": "chat:stickers",
      "data": {
        "userToken": "${user.unique}",
        "user_id": '${user.id}',
      }
    });
    print('get stickers');
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

    // if (chatController != null) chatController.add(new MyChatEvent(json));
    if (newChatController != null) newChatController.add(NewChatEvent(json));
  }

  localForwardMessage(String id) {
    var object = {
      "cmd": "forwardMessage",
      "id": id,
    };
    var json = jsonDecode(jsonEncode(object));

    // if (chatController != null) chatController.add(new MyChatEvent(json));
    newChatController.add(NewChatEvent(json));
  }

  findMessage(i) {
    var object = {
      "cmd": "findMessage",
      "index": i,
    };
    var json = jsonDecode(jsonEncode(object));

    // if (chatController != null) chatController.add(new MyChatEvent(json));
    if (newChatController != null) newChatController.add(NewChatEvent(json));
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
    if (newChatController != null) newChatController.add(NewChatEvent(json));
  }

  forwardMessage(m, String text, String chatIds) {
    print("FORWARD MESSAGE TO SOCKET $m $text $chatIds");
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
    print('changing $chatId avatar to $fileName');
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

        print('main listen ${json['cmd']}');

        if (json['logout'] != null && json['logout'] == true) {
          logOut(context);
        } else {
          var cmd = json['cmd'];
          var data = json['data'];
          switch (cmd) {
            case "init":
              print(user.id);
              print(data);
              if (data['status'].toString() == 'true') {
                print("INIT status is ${data['status']}");
                // this is bool for check load more is needed or not
                forceGetChat();
              }
              break;
            case "chats:get":
              newChatsController.add(NewChatsEvent(json));
              if (chatsListDialogController != null &&
                  !chatsListDialogController.isClosed) {
                chatsListDialogController.add(ChatListDialog(json));
              } else {
                chatsListController.add(ChatsListEvent(json));
              }
              break;
            case "chat:get":
              if (newChatController != null && !newChatController.isClosed) {
                newChatController.add(NewChatEvent(json));
              }
              // if (chatController != null && !chatController.isClosed) {
              //   chatController.add(MyChatEvent(json));
              // }
              break;
            case "message:create":
              // this is bool for check load more is needed or not
              forceGetChat();
              // if (chatController == null) {
              // inSound();
              chatsListController.add(ChatsListEvent(json));
              print("new message in CHATS null page");
              // } else {
              // if (!chatController.isClosed) {
              //   print("new message in CHAT page");
              //   // chatController.add(MyChatEvent(json));
              // } else {
              // chatsListController.add(ChatsListEvent(json));
              // print("new message in CHATS page");
              // }
              // }
              if (newChatController != null)
                newChatController.add(NewChatEvent(json));
              break;
            case "user:check":
              if (contactController != null && !contactController.isClosed) {
                print('added to contactController');

                contactController.add(MyContactEvent(json));
              }
              if (chatInfoController != null) {
                print('added to chatInfoController');
                if (!chatInfoController.isClosed)
                  chatInfoController.add(MyChatInfoEvent(json));
                print('contoller');
              }
              if (chatUserProfileController != null) {
                if (!chatUserProfileController.isClosed) {
                  print('added to cabinet info');
                  chatUserProfileController.add(MyChatUserProfileEvent(json));
                }
              }
              if (chatsListController != null) {
                chatsListController.add(ChatsListEvent(json));
              }
              break;
            case "chat:members:add":
              contactController.add(MyContactEvent(json));
              break;
            case "user:check:online":
              // if (chatController != null) chatController.add(MyChatEvent(json));
              if (newChatController != null)
                newChatController.add(NewChatEvent(json));
              break;
            case "chat:create":
              // this is bool for check load more is needed or not
              forceGetChat();
              if (contactController != null)
                contactController.add(MyContactEvent(json));
              break;
            case "chat:members":
              if (newUsersListDialogController != null) {
                newUsersListDialogController.add(UsersListEvent(json));
              }
              if (chatInfoController != null) {
                print('added to chatInfoController $json');
                chatInfoController.add(MyChatInfoEvent(json));
              }
              // if (chatController != null && !chatController.isClosed) {
              // chatController.add(MyChatEvent(json));
              // }
              break;
            case "chat:member:search":
              print('added to chatInfoController');
              chatInfoController.add(MyChatInfoEvent(json));
              break;
            case "set:group:avatar":
              print('added to chatInfoController');
              chatInfoController.add(MyChatInfoEvent(json));
              break;
            case "chat:members:privileges":
              print('added to chatInfoController');
              chatInfoController.add(MyChatInfoEvent(json));
              break;
            case "user:writing":
              if (newChatController != null)
                newChatController.add(NewChatEvent(json));
              if (newChatsController != null)
                newChatsController.add(NewChatsEvent(json));
              // if (chatController != null && !chatController.isClosed)
              // chatController.add(MyChatEvent(json));
              break;
            case "message:deleted:all":
              if (chatsListController != null) forceGetChat();
              // if (chatController != null) chatController.add(MyChatEvent(json));
              if (newChatController != null)
                newChatController.add(NewChatEvent(json));
              break;
            case "message:edit":
              // if (chatController != null) chatController.add(MyChatEvent(json));
              if (newChatController != null)
                newChatController.add(NewChatEvent(json));
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
              newChatController.add(NewChatEvent(json));
              // chatController.add(MyChatEvent(json));
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
            case 'chat:delete':
              newChatsController.add(NewChatsEvent(json));
              break;
            case 'chat:mute':
              newChatsController.add(NewChatsEvent(json));
              break;
            case 'chat:stickers':
              if (newChatController != null)
                newChatController.add(NewChatEvent(json));
              break;
            default:
              print('default print cmd: $cmd json: $json');
          }
        }
      },
      onDone: () {
        print("ON DONE IS CALLED"); // TODO
        Future.delayed(const Duration(seconds: 1), () {
          connect(context);
          init();
        });
      },
    );
  }
}

class ChatsListEvent {
  var json;

  ChatsListEvent(var json) {
    this.json = json;
  }
}

class MyContactEvent {
  var json;

  MyContactEvent(var json) {
    this.json = json;
  }
}

class MyChatEvent {
  var json;

  MyChatEvent(var json) {
    this.json = json;
  }
}

class MyChatInfoEvent {
  var json;

  MyChatInfoEvent(var json) {
    this.json = json;
  }
}

class MyChatUserProfileEvent {
  var json;

  MyChatUserProfileEvent(var json) {
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

class ChatListDialog {
  var json;

  ChatListDialog(var json) {
    this.json = json;
  }
}
