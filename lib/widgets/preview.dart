import 'dart:io';
import 'package:flutter/material.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/backgrounds.dart';
import 'package:indigo24/widgets/video_player_widget.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:photo_view/photo_view.dart';

class PreviewMedia extends StatefulWidget {
  final filePath;
  final type;
  PreviewMedia({this.filePath, this.type});

  @override
  _PreviewMediaState createState() => _PreviewMediaState();
}

class _PreviewMediaState extends State<PreviewMedia> {
  TextEditingController _messageController;
  File file;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    file = File(widget.filePath);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.white,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: previewBackgoundProvider, fit: BoxFit.fitWidth)),
      child: ClipRect(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.white.withOpacity(0.2),
            elevation: 0,
          ),
          body: Container(
            color: Colors.transparent,
            child: Column(
              children: [
                Expanded(
                    flex: 11,
                    child: widget.type == 'video'
                        ? VideoPlayerWidget(widget.filePath, "file")
                        // ChewieVideo(
                        //     controller: VideoPlayerController.file(file),
                        //   )
                        : PhotoView(
                            imageProvider: FileImage(file),
                            minScale: PhotoViewComputedScale.contained,
                            maxScale: PhotoViewComputedScale.contained * 3,
                            backgroundDecoration:
                                BoxDecoration(color: Colors.transparent),
                          )
                    // Container(
                    //   child: Image.file(file),
                    // ),
                    ),
                Expanded(
                  flex: 1,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 40,
                    color: Colors.white.withOpacity(0.2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: 30,
              ),
              Flexible(
                child: TextField(
                  controller: _messageController,
                  style: TextStyle(color: whiteColor),
                  decoration: InputDecoration(
                    hintText: "${localization.enterMessage}",
                    hintStyle: TextStyle(color: greyColor),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 10),
                width: 70,
                height: 70,
                child: FittedBox(
                  child: FloatingActionButton(
                    heroTag: "btn1",
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      'assets/images/send.png',
                      width: 30,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(
                          {'cmd': 'sending', 'text': _messageController.text});
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
