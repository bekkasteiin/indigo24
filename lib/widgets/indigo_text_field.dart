import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/style/colors.dart';

class IndigoTextField extends StatelessWidget {
  const IndigoTextField({
    Key key,
    this.onChangeCallback,
    @required TextEditingController textEditingController,
    this.suffixIcon,
    this.hintText,
    this.inputFormatters,
    this.minLines = 1,
    this.maxLines = 4,
  })  : _textEditingController = textEditingController,
        super(key: key);

  final Function onChangeCallback;
  final TextEditingController _textEditingController;
  final Widget suffixIcon;
  final String hintText;
  final List<TextInputFormatter> inputFormatters;
  final int minLines;
  final int maxLines;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(55),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            spreadRadius: -5,
            offset: Offset(0.0, 6.0),
          )
        ],
      ),
      child: TextField(
        minLines: minLines,
        maxLines: maxLines,
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          isDense: true,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: const BorderRadius.all(
              const Radius.circular(20.0),
            ),
          ),
          contentPadding: EdgeInsets.only(
            left: 15,
            bottom: 10,
            top: 10,
            right: 15,
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: darkPrimaryColor,
          ),
          fillColor: whiteColor,
        ),
        inputFormatters: inputFormatters,
        onChanged: onChangeCallback,
        controller: _textEditingController,
      ),
    );
  }
}
