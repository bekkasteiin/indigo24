import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProgressBar {

  OverlayEntry _progressOverlayEntry;

  void show(BuildContext context, percent){
      _progressOverlayEntry = _createdProgressEntry(context, percent);
      Overlay.of(context).insert(_progressOverlayEntry);
  }

  void hide(){
      if(_progressOverlayEntry != null){
      _progressOverlayEntry.remove();
      _progressOverlayEntry = null;
      }
  }

  OverlayEntry _createdProgressEntry(BuildContext context, String percent) =>
      OverlayEntry(
          builder: (BuildContext context) =>
              Scaffold(
                body: Stack(
                    children: <Widget>[
                    Container(
                        color: Colors.lightBlue.withOpacity(0.5),
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