import 'dart:io';

import 'package:flutter/material.dart';

class PreviewMedia extends StatefulWidget {
  final filePath;
  final type;
  PreviewMedia({this.filePath, this.type});

  @override
  _PreviewMediaState createState() => _PreviewMediaState();
}

class _PreviewMediaState extends State<PreviewMedia> {

  File file;

  @override
  void initState() {
    super.initState();
    file = File(widget.filePath);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              flex: 9,
              child: Container(
                child: Image.file(file),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                color: Colors.blue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: (){
                        Navigator.of(context).pop("sending");
                      },
                    )
                  ],
                ),
              ),
            )
            
          ],
        ),
      )
    );
  }
}