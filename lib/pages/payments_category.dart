import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api.dart';
import 'payments_history.dart';
import 'payments_services.dart';

class PaymentsCategoryPage extends StatefulWidget {
  @override
  _PaymentsCategoryPageState createState() => _PaymentsCategoryPageState();
}

class _PaymentsCategoryPageState extends State<PaymentsCategoryPage> {
  var logoUrl;

  Api api = Api();

  @override
  void initState() {
    super.initState();
  }

  Widget mainScreen2(BuildContext context, String logo, String account,
      String amount, String title, String date, int index) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                "$date",
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          padding: EdgeInsets.only(left: 20, right: 20),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          height: 60,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: 35,
                            margin: EdgeInsets.only(right: 20),
                            padding: EdgeInsets.only(top: 5),
                            alignment: Alignment.topCenter,
                            child: Image.network('$logo', width: 30.0),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "$title",
                                  style: TextStyle(fontSize: 15),
                                ),
                                Text(
                                  "Аккаунт $account",
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  "$amount ₸",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 60,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          padding: EdgeInsets.only(left: 20, right: 20),
          margin: EdgeInsets.only(left: 20, right: 20),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: api.getCategories().then((categories) {
        return categories;
      }),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: buildAppBar(),
          body: snapshot.hasData == true
              ? ListView.builder(
                  itemCount: snapshot.data["categories"].length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: _paymentsList(
                        context,
                        snapshot.data["logoURL"] +
                            snapshot.data["categories"][index]['logo'],
                        snapshot.data["categories"][index]['title'],
                        snapshot.data["categories"][index]['ID'],
                      ),
                    );
                  },
                )
              : Center(child: CircularProgressIndicator()),
        );
      },
    );
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
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.history,
            color: Colors.black,
          ),
          onPressed: () {
            // StudentDao().deleteAll();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PaymentHistoryPage()),
            );
          },
        )
      ],
      backgroundColor: Colors.white,
    );
  }

  Container _paymentsList(
      BuildContext context, String logo, String name, int index) {
    return Container(
      child: FlatButton(
        child: Row(
          children: <Widget>[
            Container(
              width: 35,
              height: 40,
              margin: EdgeInsets.only(right: 20, top: 10, bottom: 10),
              child: Image.network(
                '$logo',
                width: 30.0,
              ),
            ),
            Expanded(
              child: Text(
                '$name',
                style: TextStyle(fontSize: 14, color: Color(0xFF001D52)),
              ),
            ),
          ],
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentsGroupPage(
                index,
                name,
              ),
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
