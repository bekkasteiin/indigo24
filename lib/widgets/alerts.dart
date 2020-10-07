import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/services/localization.dart' as localization;

indigoCupertinoDialogAction(
  BuildContext context,
  String title, {
  rightButtonCallBack(),
  leftButtonCallBack(),
  String content,
  bool isDestructiveAction,
  String rightButtonText,
  String leftButtonText,
}) {
  List<Widget> actions = [];

  CupertinoDialogAction rightButton = CupertinoDialogAction(
    child: Text('$rightButtonText'),
    isDestructiveAction: isDestructiveAction,
    onPressed: () {
      rightButtonCallBack();
    },
  );
  CupertinoDialogAction leftButton = CupertinoDialogAction(
    child: Text(
      '${leftButtonText == null ? localization.cancel : leftButtonText}',
    ),
    onPressed: () {
      leftButtonCallBack == null
          ? Navigator.pop(context)
          : leftButtonCallBack();
    },
  );
  actions.add(leftButton);
  rightButtonText != null ? actions.add(rightButton) : Center();

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
