import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/localization.dart' as localization;

class PaymentHistoryPage extends StatefulWidget {
  @override
  _PaymentHistoryPageState createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  Api api = Api();

  Widget _historyBuilder(BuildContext context, String logo, String account,
      String amount, String title, String date, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Row(
          children: <Widget>[
            SizedBox(width: 20),
            _paymentLogo(logo),
            _paymentInfo(title, account, date),
            _paymentAmount(amount),
            SizedBox(width: 20),
          ],
        ),
        Container(
          margin: EdgeInsets.only(top: 5, right: 20, left: 20),
          height: 0.2,
          color: Color(0xFF7D8E9B),
        ),
      ],
    );
  }

  Container _paymentLogo(String logo) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      alignment: Alignment.topCenter,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Image.network('$logo', width: 50.0),
      ),
    );
  }

  Container _paymentAmount(String amount) {
    return Container(
      child: Text(
        "$amount KZT",
        style: TextStyle(
          fontSize: 18,
          color: Color(0xFF001D52),
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  Expanded _paymentInfo(String title, String account, String date) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "$title",
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF636973),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "${localization.account} $account",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF001D52),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "$date",
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF001D52),
              fontWeight: FontWeight.w300,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      centerTitle: true,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(10),
          child: Image(
            image: AssetImage(
              'assets/images/back.png',
            ),
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      brightness: Brightness.light,
      title: Text(
        "${localization.payments}",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: FutureBuilder(
          future: api.getHistories(),
          builder: (context, snapshot) {
            print(snapshot.data);
            if (snapshot.hasData)
              return _paymentHistroyBody(snapshot.data);
            else
              return Center(
                child: CircularProgressIndicator(),
              );
          }),
    );
  }

  SafeArea _paymentHistroyBody(snapshot) {
    return SafeArea(
      child: ListView.builder(
        itemCount: snapshot['payments'].length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: const EdgeInsets.only(top: 10),
            height: 96,
            child: _historyBuilder(
              context,
              "${snapshot['logoURL']}${snapshot['payments'][index]['logo']}",
              "${snapshot['payments'][index]['account']}",
              "${snapshot['payments'][index]['amount']}",
              "${snapshot['payments'][index]['title']}",
              "${snapshot['payments'][index]['data']}",
              index,
            ),
          );
        },
      ),
    );
  }
}
