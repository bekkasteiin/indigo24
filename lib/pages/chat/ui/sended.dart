

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/pages/chat/chat_page_view_test.dart';
import 'package:indigo24/pages/chat/ui/replyMessage.dart';
import 'package:indigo24/pages/tapes/tapes.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/widgets/linkMessage.dart';
import 'package:video_player/video_player.dart';

class Sended extends StatelessWidget {
  final m;
  final chatId;
  Sended(this.m, {this.chatId});
  @override
  Widget build(BuildContext context) {
    var a = (m['attachments']==false || m['attachments']==null)?false:jsonDecode(m['attachments']);
    var replyData = (m['reply_data']==false || m['reply_data']==null)? false: m['reply_data'];

    return Align(
        alignment: Alignment(1, 0),
        child: Container(
          child: CupertinoContextMenu(
            actions: [
                CupertinoContextMenuAction(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Удалить', style: TextStyle(color:Colors.red, fontSize: 14),),
                      const Icon(CupertinoIcons.delete, color: Colors.red, size: 20)
                    ],
                  ),
                  onPressed: () {
                    ChatRoom.shared.deleteFromAll(chatId, m['id']==null?m['message_id']:m['id']);
                    Navigator.pop(context);
                  },
                ),
                CupertinoContextMenuAction(
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Редактировать', style: TextStyle(fontSize: 14)),
                        const Icon(CupertinoIcons.pen, size: 20,)
                      ],
                    ),
                  ),
                  onPressed: () {
                    ChatRoom.shared.editingMessage(m);
                    Navigator.pop(context);
                  },
                ),
                CupertinoContextMenuAction(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Ответить', style: TextStyle(fontSize: 14)),
                      const Icon(CupertinoIcons.reply_thick_solid, size: 20)
                    ],
                  ),
                  onPressed: () {
                    ChatRoom.shared.replyingMessage(m);
                    Navigator.pop(context);
                  },
                ),
                
            ],
            child: Material(
              color: Colors.transparent,
              child: SendedMessageWidget(
                content: '${m['text']}',
                time: time('${m['time']}'),
                write: '${m['write']}',
                type: "${m["type"]}",
                media: (a==false || a==null)? null : "${m["type"]}" == '12' ? a[0]['link'] : a[0]['filename'],
                rMedia: (a==false || a==null)? null : a[0]['r_filename']==null?a[0]['filename']:a[0]['r_filename'],
                mediaUrl: (a==false || a==null)? null : m['attachment_url'],
                edit: "${m["edit"]}",
                replyData: (replyData==false || replyData==null)? null : replyData
              ),
            ),
          ),
        ));
  }

  String time(timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(
      int.parse(timestamp) * 1000,
    );
    TimeOfDay roomBooked = TimeOfDay.fromDateTime(DateTime.parse('$date'));
    var hours;
    var minutes;
    hours = '${roomBooked.hour}';
    minutes = '${roomBooked.minute}';

    if (roomBooked.hour.toString().length == 1) hours = '0${roomBooked.hour}';
    if (roomBooked.minute.toString().length == 1)
      minutes = '0${roomBooked.minute}';
    return '$hours:$minutes';
  }
}



class SendedMessageWidget extends StatelessWidget {
  final String content;
  final String time;
  final String write;
  final String media;
  final String mediaUrl;
  final String rMedia;
  final String type;
  final String edit;
  final replyData;

  const SendedMessageWidget({
    Key key,
    this.content,
    this.time,
    this.write,
    this.media,
    this.mediaUrl,
    this.rMedia,
    this.type,
    this.edit,
    this.replyData
  }) : super(key: key);

  

  @override
  Widget build(BuildContext context) {
    var a = parser.unemojify(content);
    int l = a.length-1;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: edit=='1'?140.0:120.0,
      ),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(
              right: 8.0, left: 50.0, top: 4.0, bottom: 4.0),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(0),
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15)),
            child: Container(
              color: Colors.white,
              child: Stack(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      right: 12.0, left: 8.0, top: 8.0, bottom: 15.0),
                  child: 
                  (type=="12")?
                    LinkMessage("$media")
                  :
                  (a[0]==":" && a[l]==":" && content.length<9)?
                    Text(content, style: TextStyle(fontSize: 40))
                  :
                  (a[0]==":" && a[l]==":" && content.length>8)?
                    Text(content, style: TextStyle(fontSize: 24))
                  :
                  (type=="1")?
                  ImageMessage("$mediaUrl$rMedia", "$mediaUrl$media")
                  :
                  (type=="2")?
                  FileMessage(url:"$mediaUrl$media")
                  :
                  (type=="3")?
                  new AudioMessage("$mediaUrl$media")
                  :
                  (type=="4")?
                  Container(
                    width: MediaQuery.of(context).size.width*0.7,
                    height: MediaQuery.of(context).size.width*0.7,
                    child: new ChewieVideo(controller: VideoPlayerController.network("$mediaUrl$media"), 
                      size: MediaQuery.of(context).size.width*0.7,),
                  )
                  :
                  (type=="10")?
                  ReplyMessage(content, replyData)
                  :
                  (type=="uploading")?
                  Container(
                    width: MediaQuery.of(context).size.width*0.7,
                    height: MediaQuery.of(context).size.width*0.7,
                    child: uploadingImage!=null?
                    Stack(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width*0.7,
                          height: MediaQuery.of(context).size.width*0.7,
                          child: Image.file(uploadingImage, fit: BoxFit.cover,),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width*0.7,
                          height: MediaQuery.of(context).size.width*0.7,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        Center(
                          child: Image.asset("assets/preloader.gif", width: MediaQuery.of(context).size.width*0.3),
                        ),
                      ],
                    )
                    :
                    Center(
                      child: Image.asset("assets/preloader.gif", width: MediaQuery.of(context).size.width*0.3),
                    ),
                  )
                  :
                  Text(
                    content,
                  ),
                ),
                Positioned(
                  bottom: -1,
                  right: 3,
                  child: write == '1'
                      ? Icon(
                          Icons.done_all,
                          size: 16,
                          color: Colors.blue,
                        )
                      : Icon(
                          Icons.done,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                ),
                Positioned(
                  bottom: 1,
                  left: 10,
                  child: Row(children: [
                    Text(
                      time,
                      style: TextStyle(
                          fontSize: 10, color: Colors.black.withOpacity(0.6)),
                    ), 
                    edit=='1'?
                    Text(" ред.", style:TextStyle(fontSize: 10, color: Colors.black.withOpacity(0.6)))
                    :
                    Container()
                  ],),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}