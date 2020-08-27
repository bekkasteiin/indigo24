import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

indigoCupertinoDialogAction(
  BuildContext context,
  String title, {
  rightButtonCallBack(),
  leftButtonCallBacK(),
  String content,
  bool isDestructiveAction,
  String rightButtonText,
  String leftButtonText,
}) {
  CupertinoDialogAction rightButton = CupertinoDialogAction(
    child: Text(leftButtonText),
    isDestructiveAction: isDestructiveAction,
    onPressed: () {
      rightButtonCallBack();
    },
  );
  CupertinoDialogAction leftButton = CupertinoDialogAction(
    child: Text(rightButtonText),
    onPressed: () {
      leftButtonCallBacK();
    },
  );
  List<Widget> actions = [];

  rightButtonText != null ? actions.add(leftButton) : Center();
  leftButtonText != null ? actions.add(rightButton) : Center();

  CupertinoAlertDialog alert = CupertinoAlertDialog(
    title: Text(title),
    content: Text(content != null ? content : ''),
    actions: actions,
  );
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
