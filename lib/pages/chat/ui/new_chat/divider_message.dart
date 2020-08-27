import 'package:flutter/material.dart';
import 'package:indigo24/style/colors.dart';

class DividerMessageWidget extends StatefulWidget {
  final Widget child;

  const DividerMessageWidget({Key key, this.child}) : super(key: key);
  @override
  _DividerMessageWidgetState createState() => _DividerMessageWidgetState();
}

class _DividerMessageWidgetState extends State<DividerMessageWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width / 2,
        decoration: BoxDecoration(
          color: whiteColor.withOpacity(0.9),
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}
