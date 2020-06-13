import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
          return transactions;
        }),
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return _transferHistoryBody(snapshot.data);
          else
            return Center(child: CircularProgressIndicator());
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

  Expanded _transferInfo(String name, String date, String phone) {
    date = date.substring(0, date.length - 3);
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
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "$phone",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF001D52),
              fontWeight: FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
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
      String title, String phone, String type, String date, int index) {
    return Container(
      height: 90.6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          SizedBox(height: 20),
          Row(
            children: <Widget>[
              SizedBox(width: 20),
              _transferLogo(logo),
              _transferInfo(title, date, phone),
              _transferAmount(type, amount),
              SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Container(
                    height: 10,
                    width: 10,
                    color:
                        type == 'in' ? Color(0xFF77E7B1) : Color(0xFFEB818E)),
              ),
              SizedBox(width: 20),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 20, right: 20, left: 20),
            height: 0.6,
            color: Color(0xFF7D8E9B),
          ),
        ],
      ),
    );
  }

  SafeArea _transferHistoryBody(snapshot) {
    print(snapshot);
    return SafeArea(
      child: ListView.builder(
        itemCount: snapshot['transactions'].length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: const EdgeInsets.only(top: 5),
            child: _historyBuilder(
              context,
              "${snapshot['avatarURL'] + snapshot['transactions'][index]['avatar']}",
              // "https://lh3.googleusercontent.com/IeNJWoKYx1waOhfWF6TiuSiWBLfqLb18lmZYXSgsH1fvb8v1IYiZr5aYWe0Gxu-pVZX3",
              "${snapshot['transactions'][index]['amount']}",
              "${snapshot['transactions'][index]['name']}",
              "${snapshot['transactions'][index]['phone']}",
              // 'asdiads0oafskojasfkodfokfdsokfssfdfdsokfsdjfdsfds',
              '${snapshot['transactions'][index]['type']}',
              "${snapshot['transactions'][index]['data']}",
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
  @override
  void dispose() {
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
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
