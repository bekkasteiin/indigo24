import 'package:flutter/material.dart';

class PaymentHistoryPage extends StatefulWidget {
  @override
  _PaymentHistoryPageState createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  
  Widget _historyBuilder(BuildContext context, String logo, String account,
      String amount, String title, String date, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        SizedBox(height: 20),
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
          margin: EdgeInsets.only(top: 20, right: 20, left: 20),
          height: 1,
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

  Text _paymentAmount(String amount) {
    return Text(
            "$amount KZT",
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF001D52),
            ),
          );
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
                    color: Color(0xFF001D52),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Аккаунт $account",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF001D52),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  "$date",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
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
      backgroundColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: _paymentHistroyBody(),
    );
  }

  SafeArea _paymentHistroyBody() {
    return SafeArea(
      child: ListView.builder(
        itemCount: 15,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(top: 5),
            child: _historyBuilder(
              context,
              "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/BMW_logo_%28white_%2B_grey_background_square%29.svg/600px-BMW_logo_%28white_%2B_grey_background_square%29.svg.png",
              "8707 123 45 68",
              "200,00",
              "Beeline",
              "08.06.2020",
              index,
            ),
          );
        },
      ),
    );
  }
}
