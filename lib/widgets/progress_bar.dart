import 'package:flutter/material.dart';

String downloadPercent = "0 %";

class ProgressBar {

  OverlayEntry _progressOverlayEntry;
  String percent = '0 %';

  void show(BuildContext context, percent){
      _progressOverlayEntry = _createdProgressEntry(context);
      Overlay.of(context).insert(_progressOverlayEntry);
  }

  void change(p){
    percent = p;
  }

  void hide(){
      if(_progressOverlayEntry != null){
      _progressOverlayEntry.remove();
      _progressOverlayEntry = null;
      }
  }

  OverlayEntry _createdProgressEntry(BuildContext context) =>
      OverlayEntry(
          builder: (BuildContext context) =>
              Scaffold(
                body: Stack(
                    children: <Widget>[
                    Container(
                        color: Colors.lightBlue.withOpacity(0.3),
                    ),
                    Center(
                      child: LinearProgressIndicator(),
                    )
                    ],

                ),
              )
      );

  double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

}
