import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:indigo24/pages/auth/intro.dart';
import 'package:indigo24/pages/chat/chat_models/chat_model.dart';
import 'package:indigo24/pages/chat/chat_models/hive_names.dart';
import 'package:indigo24/pages/chat/chat_models/messages_model.dart';
import 'package:indigo24/services/api/socket/socket.dart';
import 'package:indigo24/services/localization/localization.dart';
import 'package:indigo24/services/shared_preference/shared_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'indigo_alert.dart';
import 'indigo_show_dialog.dart';

logOut(BuildContext context) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  ChatRoom.shared.channel = null;
  preferences.setString(SharedStrings.phone, 'null');
  preferences.setString(SharedStrings.pin, 'false');
  Hive.box<MessageModel>(HiveBoxes.messages).clear();
  Hive.box<ChatModel>(HiveBoxes.chats).clear();

  showIndigoDialog(
    barrierDismissible: false,
    context: context,
    builder: CustomDialog(
      description: "${Localization.language.sessionIsOver}",
      yesCallBack: () {
        Navigator.pop(context);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => IntroPage(),
          ),
          (r) => false,
        );
      },
    ),
  );
}
