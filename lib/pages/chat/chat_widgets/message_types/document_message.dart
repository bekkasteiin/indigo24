import 'package:flutter/material.dart';

class DocumentMessageWidget extends StatefulWidget {
  final String text;

  const DocumentMessageWidget({Key key, this.text}) : super(key: key);
  @override
  _DocumentMessageWidgetState createState() => _DocumentMessageWidgetState();
}

class _DocumentMessageWidgetState extends State<DocumentMessageWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('document ${widget.text}'),
    );
  }
}
