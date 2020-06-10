import 'package:flutter/material.dart';

import '../services/api.dart';

class TransferHistoryPage extends StatefulWidget {
  @override
  _TransferHistoryPageState createState() => _TransferHistoryPageState();
}

class _TransferHistoryPageState extends State<TransferHistoryPage> {
  Api api = Api();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: FutureBuilder(
        future: api.getTransactions(1).then((transactions) {
          print('ho $transactions');
          return transactions;
        }),
        builder: (context, snapshot) {
          print(snapshot.data);
          return _transferHistoryBody();
        },
      ),
    );
  }

  Container _transferLogo(String logo) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      alignment: Alignment.topCenter,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Image.network('$logo', width: 50.0),
      ),
    );
  }

  Text _transferAmount(String type, String amount) {
    return Text(
      type == 'in' ? '+$amount KZT' : "-$amount KZT",
      style: TextStyle(
        fontSize: 18,
        color: Color(0xFF001D52),
      ),
    );
  }

  Expanded _transferInfo(String name, String date) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "$name",
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF001D52),
              fontWeight: FontWeight.w500,
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

  Widget _historyBuilder(BuildContext context, String logo, String amount,
      String title, String type, String date, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        SizedBox(height: 20),
        Row(
          children: <Widget>[
            SizedBox(width: 20),
            _transferLogo(logo),
            _transferInfo(title, date),
            _transferAmount(type, amount),
            SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Container(
                  height: 10,
                  width: 10,
                  color: type == 'in' ? Color(0xFF77E7B1) : Color(0xFFEB818E)),
            ),
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

  SafeArea _transferHistoryBody() {
    return SafeArea(
      child: ListView.builder(
        itemCount: 15,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(top: 5),
            child: _historyBuilder(
              context,
              "https://lh3.googleusercontent.com/IeNJWoKYx1waOhfWF6TiuSiWBLfqLb18lmZYXSgsH1fvb8v1IYiZr5aYWe0Gxu-pVZX3",
              "200,00",
              "Aseke",
              'in',
              "08.06.2020",
              index,
            ),
          );
        },
      ),
    );
  }

  Future getTransactions() async {
    // try {
    //   var response = await client.post(
    //     'https://api.indigo24.xyz/api/v2.1/get/transactions',
    //     headers: <String, String>{
    //       'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
    //     },
    //     body: "customerID=${customerID}&unique=${unique}&page=1",
    //   );
    //   var result = json.decode(response.body);
    //   if (response.statusCode == 200) {
    //     // print(result['success'] + 'this si res');
    //     transactions = await result['transactions'];
    //     logoUrl = await result['avatarURL'];
    //     return result;
    //   } else {
    //     return "error";
    //   }
    // } catch (_) {
    //   return "disconnect";
    // }
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
        "Переводы",
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
}
