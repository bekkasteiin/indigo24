import 'package:flutter/material.dart';
import 'package:indigo24/style/colors.dart';

showIndigoDialog({
  @required BuildContext context,
  @required Widget builder,
  bool barrierDismissible = true,
}) {
  showDialog(
    barrierDismissible: barrierDismissible,
    barrierColor: blackPurpleColor.withOpacity(0.2),
    context: context,
    builder: (BuildContext context) => builder,
  );
}
