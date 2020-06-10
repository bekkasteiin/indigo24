import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api.dart';
import 'payments_service.dart';

class PaymentsGroupPage extends StatefulWidget {
  final int categoryID;
  final String title;
  PaymentsGroupPage(this.categoryID, this.title);

  @override
  _PaymentsGroupPageState createState() => _PaymentsGroupPageState();
}

class _PaymentsGroupPageState extends State<PaymentsGroupPage> {
  Api api = Api();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: api.getServices(widget.categoryID).then((services) {
          return services;
        }),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: buildAppBar(),
            body: snapshot.hasData == true
                ? ListView.builder(
                    itemCount: snapshot.data["services"].length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: _paymentsList(
                          context,
                          "https://api.indigo24.xyz/logos/${snapshot.data["services"][index]['logo']}",
                          "${snapshot.data["services"][index]['title']}",
                          snapshot.data["services"][index]['id'],
                        ),
                      );
                    },
                  )
                : Center(child: CircularProgressIndicator()),
          );
        });
  }

  AppBar buildAppBar() {
    return AppBar(
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.black,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      brightness: Brightness.light,
      title: Text(
        "Платежи",
        style: TextStyle(
          color: Color(0xFF001D52),
          fontSize: 22,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.white,
    );
  }

  Container _paymentsList(BuildContext context, String _serviceLogo,
      String _serviceTitle, int index) {
    return Container(
      child: FlatButton(
        child: Row(
          children: <Widget>[
            Container(
              width: 35,
              height: 40,
              margin: EdgeInsets.only(right: 20, top: 10, bottom: 10),
              child: Image.network(
                '$_serviceLogo',
                width: 30.0,
              ),
            ),
            Expanded(
              child: Text(
                '$_serviceTitle',
                style: TextStyle(fontSize: 14, color: Color(0xFF001D52)),
              ),
            ),
          ],
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PaymentsServicePage(index, _serviceLogo, _serviceTitle),
            ),
          );
        },
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26.withOpacity(0.2),
            blurRadius: 10.0,
            spreadRadius: -2,
          )
        ],
        color: Colors.white,
      ),
      margin: EdgeInsets.only(left: 20, right: 20, top: 10),
    );
  }

  @override
  void dispose() {
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
}
