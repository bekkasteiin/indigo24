import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/chat/ui/new_chat/chat_models/messages_model.dart';
import 'package:indigo24/chat/ui/new_chat/chat_widgets/message_category.dart';
import 'package:indigo24/chat/ui/new_chat/chat_widgets/message_frame.dart';
import 'package:indigo24/chat/ui/new_chat/chat_widgets/message_types/text_message.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/indigo_appbar_widget.dart';

class SettingsDecorPage extends StatefulWidget {
  @override
  _SettingsDecorPageState createState() => _SettingsDecorPageState();
}

class _SettingsDecorPageState extends State<SettingsDecorPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  MessageModel chatModel = MessageModel(
    id: '1',
    chatId: 1,
    userId: 1,
    avatar: '1',
    read: true,
    username: ';hellol',
    text: 'hi',
    type: 1,
    time: 100,
    attachments: null,
    reply_data: null,
    forward_data: null,
    edited: true,
    moneyData: null,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IndigoAppBarWidget(
        title: Text(
          "${localization.decor}",
          style: TextStyle(
            color: blackPurpleColor,
            fontWeight: FontWeight.w400,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                child: Text(
                  '${localization.decorForChat}',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fitWidth,
                    image: AssetImage(
                      user.chatBackground == 'ligth'
                          ? "assets/images/background_chat.png"
                          : "assets/images/background_chat_2.png",
                    ),
                  ),
                ),
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: <Widget>[
                      MessageCategoryWidget(
                        messageCategory: 0,
                        chatType: 0,
                        read: true,
                        chatId: 1000,
                        messageId: null,
                        message: null,
                        child: MessageFrameWidget(
                          messageCategory: 0,
                          chatId: -1000,
                          time: '11:00',
                          message: chatModel,
                          read: true,
                          messageId: chatModel.id,
                          child: TextMessageWidget(text: chatModel),
                        ),
                      ),
                      MessageCategoryWidget(
                        messageCategory: 2,
                        chatType: 0,
                        read: true,
                        chatId: 1000,
                        messageId: null,
                        message: null,
                        child: MessageFrameWidget(
                          messageCategory: 0,
                          chatId: -1000,
                          time: '11:01',
                          message: chatModel,
                          read: false,
                          messageId: chatModel.id,
                          child: TextMessageWidget(text: chatModel),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: blackPurpleColor, width: 1),
                          image: DecorationImage(
                            fit: BoxFit.fitWidth,
                            image: AssetImage(
                              "assets/images/background_chat.png",
                            ),
                          ),
                        ),
                        child: Container(
                          height: 100,
                          width: 100,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          user.chatBackground = 'ligth';
                        });
                      },
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: blackPurpleColor, width: 1),
                          image: DecorationImage(
                            fit: BoxFit.fitWidth,
                            image: AssetImage(
                              "assets/images/background_chat_2.png",
                            ),
                          ),
                        ),
                        child: Container(
                          height: 100,
                          width: 100,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          user.chatBackground = 'dark';
                        });
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
