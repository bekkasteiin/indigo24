import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/services/api.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:indigo24/services/localization.dart' as localization;

class TransferHistoryPage extends StatefulWidget {
  @override
  _TransferHistoryPageState createState() => _TransferHistoryPageState();
}

class _TransferHistoryPageState extends State<TransferHistoryPage> {
  Api api = Api();
  List transferHistories = [];
  String avatarUrl = "";

  @override
  void initState() { 
    super.initState();
    api.getTransactions(page).then((transactions) {
      if (transactions['message'] == 'Not authenticated' && transactions['success'].toString() == 'false') {
        logOut(context);
        return transactions;
      } else {
        setState(() {
          avatarUrl = transactions['avatarURL'];
          print(transactions);
          if (page == 1) 
            transferHistories = transactions['transactions'].toList();
        });
        return transactions;
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: transferHistories.isNotEmpty ? _transferHistoryBody(transferHistories) : Center(child: CircularProgressIndicator()),
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

  Widget _transferAmount(String type, String amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(),
        Text(
          type == 'in' ? '+$amount KZT' : "-$amount KZT",
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF001D52),
          ),
        ),
        SizedBox(height: 5,),
        Container(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Container(
                height: 15,
                width: 15,
                color: type == 'in' ? Colors.green : Colors.red),
          ),
        ),
      ],
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(width: 20),
                _transferLogo(logo),
                _transferInfo(title, date, phone),
                _transferAmount(type, amount),
                SizedBox(width: 20),
              ],
            ),
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
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onLoading() async {
    print("_onLoading ");
    _loadData();
    _refreshController.loadComplete();
  }
  bool isLoaded = false;
  int page = 1;

  Future _loadData() async {
    api.getTransactions(page).then((histories){
      List temp = histories['transactions'].toList();
      setState((){
        transferHistories.addAll(temp);
      });
      page++;
    });
  }

  SafeArea _transferHistoryBody(snapshot) {
    return SafeArea(
      child: SmartRefresher(
        enablePullDown: false,
        enablePullUp: true,
        footer: CustomFooter(
          builder:(BuildContext context, LoadStatus mode) {
            Widget body;
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        controller: _refreshController,
        onLoading: _onLoading,
        child: ListView.builder(
          itemCount: snapshot != null ? snapshot.length : 0,
          padding: EdgeInsets.only(top: 20),
          itemBuilder: (BuildContext context, int index) {
            return Container(
              padding: const EdgeInsets.only(top: 5),
              child: _historyBuilder(
                context,
                "${avatarUrl + snapshot[index]['avatar']}",
                "${snapshot[index]['amount']}",
                "${snapshot[index]['name']}",
                "${snapshot[index]['phone']}",
                '${snapshot[index]['type']}',
                "${snapshot[index]['data']}",
                index,
              ),
            );
          },
        ),
      ),
    );
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
        "${localization.transfers}",
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
