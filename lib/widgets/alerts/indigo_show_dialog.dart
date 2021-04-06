import 'dart:ui';

import 'package:flutter/cupertino.dart';
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

void showCupertinoDatePicker(
    BuildContext context, {
      Key key,
      CupertinoDatePickerMode mode = CupertinoDatePickerMode.dateAndTime,
      @required Function(DateTime value) onDateTimeChanged,
      DateTime initialDateTime,
      DateTime minimumDate,
      DateTime maximumDate,
      int minimumYear = 1,
      int maximumYear,
      int minuteInterval = 1,
      bool use24hFormat = false,
      Color backgroundColor,
      ImageFilter filter,
      bool useRootNavigator = true,
      bool semanticsDismissible,
      Widget cancelText,
      Widget doneText,
      bool useText = false,
      bool leftHanded = false,
    }) {
  // Default to right now.
  initialDateTime ??= DateTime.now();

  if (!useText) {
    cancelText = Icon(CupertinoIcons.clear_circled);
  } else {
    if (cancelText == null)
      cancelText = Text(
        'Cancel',
        style: CupertinoTheme.of(context).textTheme.actionTextStyle.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.red,
        ),
      );
  }

  if (!useText) {
    doneText = Icon(CupertinoIcons.check_mark_circled);
  } else {
    if (doneText == null)
      doneText = Text(
        'Save',
        style: CupertinoTheme.of(context)
            .textTheme
            .actionTextStyle
            .copyWith(fontWeight: FontWeight.w600),
      );
  }

  var cancelButton = CupertinoButton(
    padding: const EdgeInsets.symmetric(horizontal: 15.0),
    child: cancelText,
    onPressed: () {
      onDateTimeChanged(DateTime(0000, 01, 01, 0, 0, 0, 0, 0));
      Navigator.of(context).pop();
    },
  );

  var doneButton = CupertinoButton(
    padding: const EdgeInsets.symmetric(horizontal: 15.0),
    child: doneText,
    onPressed: () {
      Navigator.pop(context);
    }
      );

      //
      showCupertinoModalPopup(
      context: context,
      builder: (context) => SizedBox(
      height: 240.0,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
      Container(
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
      color: const Color.fromRGBO(249, 249, 247, 1.0),
      border: Border(
      bottom: const BorderSide(width: 0.5, color: Colors.black38),
      ),
      ),
      child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                leftHanded ? doneButton : cancelButton,
                leftHanded ? cancelButton : doneButton,
              ],
            ),
          ),
          Expanded(
              child: CupertinoDatePicker(
                key: key,
                mode: mode,
                onDateTimeChanged: (DateTime value) {
                  if (onDateTimeChanged == null) return;
                  if (mode == CupertinoDatePickerMode.time) {
                    onDateTimeChanged(
                        DateTime(0000, 01, 01, value.hour, value.minute));
                  } else {
                    onDateTimeChanged(value);
                  }
                },
                initialDateTime: initialDateTime,
                minimumDate: minimumDate,
                maximumDate: maximumDate,
                minimumYear: minimumYear,
                maximumYear: maximumYear,
                minuteInterval: minuteInterval,
                use24hFormat: use24hFormat,
                backgroundColor: backgroundColor,
              )),
        ],
      ),
    ),
    filter: filter,
    useRootNavigator: useRootNavigator,
    semanticsDismissible: semanticsDismissible,
  );
}
