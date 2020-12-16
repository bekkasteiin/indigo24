import 'package:flutter/material.dart';
import 'package:indigo24/services/localization.dart' as localization;

class ForwardMessageWidget extends StatefulWidget {
  final text;
  final Widget child;

  const ForwardMessageWidget({Key key, this.text, this.child})
      : super(key: key);
  @override
  _ForwardMessageWidgetState createState() => _ForwardMessageWidgetState();
}

class _ForwardMessageWidgetState extends State<ForwardMessageWidget> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width * 0.2,
        maxWidth: MediaQuery.of(context).size.width * 0.8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${localization.forwardFrom} ${widget.text.username}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
