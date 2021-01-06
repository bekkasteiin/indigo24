import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

showIndigoBottomDialog({
  @required BuildContext context,
  @required List<Widget> children,
  bool barrierDismissible = true,
}) {
  showModalBottomSheet(
    barrierColor: blackPurpleColor.withOpacity(0.3),
    context: context,
    backgroundColor: transparentColor,
    builder: (BuildContext bc) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Theme(
          data: ThemeData(
            splashColor: transparentColor,
            highlightColor: transparentColor,
          ),
          child: InkWell(
            onTap: () {
              SystemChannels.textInput.invokeMethod('TextInput.hide');
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              Navigator.of(context).pop();
            },
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.width * 0.05),
                margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                  child: Container(
                    color: whiteColor.withOpacity(0.9),
                    child: ListView.separated(
                      itemCount: children.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(child: children[index]);
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(
                            color: darkPrimaryColor,
                            height: 0.5,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
