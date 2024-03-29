import 'package:flutter/material.dart';
import 'package:indigo24/style/colors.dart';

typedef KeyboardTapCallback = void Function(String text);

@immutable
class KeyboardUIConfig {
  //Digits have a round thin borders, [digitBorderWidth] define their thickness
  final double digitBorderWidth;
  final TextStyle digitTextStyle;
  final TextStyle deleteButtonTextStyle;
  final Color primaryColor;
  final Color digitFillColor;
  final EdgeInsetsGeometry keyboardRowMargin;
  final EdgeInsetsGeometry digitInnerMargin;
  //Size for the keyboard can be define and provided from the app. If it will not be provided the size will be adjusted to a screen size.
  final Size keyboardSize;

  const KeyboardUIConfig({
    this.digitBorderWidth = 2,
    this.keyboardRowMargin = const EdgeInsets.only(top: 15, left: 4, right: 4),
    this.digitInnerMargin = const EdgeInsets.all(24),
    this.primaryColor = whiteColor,
    this.digitFillColor = transparentColor,
    this.digitTextStyle = const TextStyle(fontSize: 30, color: whiteColor),
    this.deleteButtonTextStyle =
        const TextStyle(fontSize: 16, color: whiteColor),
    this.keyboardSize,
  });
}

class Keyboard extends StatelessWidget {
  final KeyboardUIConfig keyboardUIConfig;
  final KeyboardTapCallback onKeyboardTap;

  Keyboard({
    Key key,
    @required this.keyboardUIConfig,
    @required this.onKeyboardTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => _buildKeyboard(context);

  Widget _buildKeyboard(BuildContext context) {
    List<String> keyboardItems = List.filled(10, '0');
    keyboardItems = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
    final screenSize = MediaQuery.of(context).size;
    final keyboardHeight = screenSize.height > screenSize.width
        ? screenSize.height / 2
        : screenSize.height - 80;
    final keyboardWidth = keyboardHeight * 3 / 4;
    final keyboardSize = this.keyboardUIConfig.keyboardSize != null
        ? this.keyboardUIConfig.keyboardSize
        : Size(keyboardWidth, keyboardHeight);
    return Container(
      width: keyboardSize.width,
      height: keyboardSize.height,
      margin: EdgeInsets.only(top: 16),
      child: AlignedGrid(
        keyboardSize: keyboardSize,
        children: List.generate(10, (index) {
          return _buildKeyboardDigit(keyboardItems[index]);
        }),
      ),
    );
  }

  Widget _buildKeyboardDigit(String text) {
    return Container(
      margin: EdgeInsets.all(4),
      child: ClipOval(
        child: Material(
          color: blueColor.withOpacity(0.2),
          child: InkWell(
            splashColor: keyboardUIConfig.primaryColor.withOpacity(0.4),
            onTap: () {
              onKeyboardTap(text);
            },
            child: Container(
              child: Center(
                child: Text(
                  text,
                  style: keyboardUIConfig.digitTextStyle,
                  semanticsLabel: text,
                ),
              ),
              decoration: BoxDecoration(
                color: brightBlue3,
                shape: BoxShape.circle,
                border: Border.all(
                    color: keyboardUIConfig.primaryColor,
                    width: keyboardUIConfig.digitBorderWidth),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AlignedGrid extends StatelessWidget {
  final double runSpacing = 4;
  final double spacing = 4;
  final int listSize;
  final columns = 3;
  final List<Widget> children;
  final Size keyboardSize;

  const AlignedGrid(
      {Key key, @required this.children, @required this.keyboardSize})
      : listSize = children.length,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final primarySize = keyboardSize.width > keyboardSize.height
        ? keyboardSize.height
        : keyboardSize.width;
    final itemSize = (primarySize - runSpacing * (columns - 1)) / columns;
    return Wrap(
      runSpacing: runSpacing,
      spacing: spacing,
      alignment: WrapAlignment.center,
      children: children
          .map((item) => Container(
                width: itemSize,
                height: itemSize,
                child: item,
              ))
          .toList(growable: false),
    );
  }
}
