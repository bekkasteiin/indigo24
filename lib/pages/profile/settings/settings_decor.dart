import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/pages/chat/chat_models/messages_model.dart';
import 'package:indigo24/pages/chat/chat_widgets/message_category.dart';
import 'package:indigo24/pages/chat/chat_widgets/message_frame.dart';
import 'package:indigo24/pages/chat/chat_widgets/message_types/text_message.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/localization/localization.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_appbar_widget.dart';

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
    username: 'username',
    text: Localization.language.hi,
    type: 1,
    time: 100,
    attachments: null,
    replyData: null,
    forwardData: null,
    edited: true,
    moneyData: null,
  );

  MessageModel chatModel2 = MessageModel(
    id: '1',
    chatId: 1,
    userId: 1,
    avatar: '1',
    read: true,
    username: 'username',
    text: Localization.language.hello,
    type: 1,
    time: 100,
    attachments: null,
    replyData: null,
    forwardData: null,
    edited: false,
    moneyData: null,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IndigoAppBarWidget(
        title: Text(
          "${Localization.language.decor}",
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
                  '${Localization.language.decorForChat.toUpperCase()}',
                  style: TextStyle(
                    color: brightGreyColor2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fitWidth,
                    image: AssetImage(
                      user.chatBackground == 'ligth'
                          ? "${assetsPath}background_chat.png"
                          : "${assetsPath}background_chat_2.png",
                    ),
                  ),
                ),
                child: Container(
                  margin: EdgeInsets.all(20),
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
                          message: chatModel2,
                          read: false,
                          messageId: chatModel.id,
                          child: TextMessageWidget(text: chatModel2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
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
                              "${assetsPath}background_chat.png",
                            ),
                          ),
                        ),
                        child: Container(
                          height: 70,
                          width: 70,
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
                              "${assetsPath}background_chat_2.png",
                            ),
                          ),
                        ),
                        child: Container(
                          height: 70,
                          width: 70,
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
