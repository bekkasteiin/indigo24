import 'package:flutter/material.dart';
import 'package:indigo24/style/colors.dart';

class ProgressBar {
  OverlayEntry _progressOverlayEntry;

  void show(BuildContext context, percent) {
    _progressOverlayEntry = _createdProgressEntry(context);
    Overlay.of(context).insert(_progressOverlayEntry);
  }

  void hide() {
    if (_progressOverlayEntry != null) {
      _progressOverlayEntry.remove();
      _progressOverlayEntry = null;
    }
  }

  OverlayEntry _createdProgressEntry(BuildContext context) => OverlayEntry(
        builder: (BuildContext context) => Scaffold(
          body: Stack(
            children: <Widget>[
              Container(
                color: blueColor,
              ),
              Center(
                child: LinearProgressIndicator(),
              )
            ],
          ),
        ),
      );
}
