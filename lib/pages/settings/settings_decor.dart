import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/pages/chat/ui/new_chat/new_ui/message_category.dart';
import 'package:indigo24/pages/chat/ui/new_chat/new_ui/message_frame.dart';
import 'package:indigo24/pages/chat/ui/new_chat/new_ui/text_message.dart';
import 'package:indigo24/pages/chat/ui/received.dart';
import 'package:indigo24/pages/chat/ui/sended.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/style/colors.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(10),
            child: Image(
              image: AssetImage(
                'assets/images/back.png',
              ),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "${localization.decor}",
          style:
              TextStyle(color: blackPurpleColor, fontWeight: FontWeight.w400),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.white,
        brightness: Brightness.light,
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
                        child: MessageFrameWidget(
                          messageCategory: 0,
                          chatId: -1000,
                          time: '11:00',
                          read: true,
                          child:
                              TextMessageWidget(text: '${localization.hello}'),
                        ),
                      ),
                      MessageCategoryWidget(
                        messageCategory: 2,
                        chatType: 0,
                        read: false,
                        chatId: 1000,
                        child: MessageFrameWidget(
                          messageCategory: 1,
                          chatId: -1000,
                          time: '11:02',
                          read: true,
                          child: TextMessageWidget(text: '${localization.hi}'),
                        ),
                      ),
                      // Container(
                      //   alignment: Alignment.centerRight,
                      //   child: SendedMessageWidget(
                      //     content: '${localization.hi}',
                      //     time: '13:45',
                      //     write: '1',
                      //     type: "0",
                      //   ),
                      // ),
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
                        print('${user.chatBackground}');
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
                        print('${user.chatBackground}');
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
