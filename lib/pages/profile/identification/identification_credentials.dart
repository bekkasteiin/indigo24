import 'package:flutter/material.dart';
import 'package:indigo24/widgets/indigo_appbar_widget.dart';

class CredentialsPage extends StatefulWidget {
  @override
  _CredentialsPageState createState() => _CredentialsPageState();
}

class _CredentialsPageState extends State<CredentialsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IndigoAppBarWidget(),
      body: Center(child: FlatButton(child: Text('123'), onPressed: () {
       },),),
    );
  }
}
