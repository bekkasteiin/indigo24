import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BalanceHistoryPage extends StatefulWidget {
  @override
  _BalanceHistoryPageState createState() => _BalanceHistoryPageState();
}

class _BalanceHistoryPageState extends State<BalanceHistoryPage>
    with TickerProviderStateMixin {
  bool _emptyResponse;

  int _balanceHistoryPage;

  List _historyBalanceList;

  Api _api;

  RefreshController _balanceRefreshController;

  @override
  void initState() {
    _emptyResponse = false;

    _balanceHistoryPage = 1;

    _historyBalanceList = [];

    _api = Api();

    _balanceRefreshController = RefreshController(initialRefresh: false);

    _api.getHistoryBalance(_balanceHistoryPage).then((histories) {
      if (histories['message'] == 'Not authenticated' &&
          histories['success'].toString() == 'false') {
        logOut(context);
      } else {
        setState(() {
          if (histories['result'].isEmpty) {
            _emptyResponse = true;
          }
          _historyBalanceList.addAll(histories['result']);
        });
        _balanceHistoryPage++;
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _paymentHistroyBalance(_historyBalanceList),
    );
  }

  void _onBalanceRefresh() {
    print("_onRefresh ");
    _balanceRefreshController.refreshCompleted();
  }

  void _onBalanceLoading() async {
    print("_onBalanceLoading ");
    _loadBalanceData();
    _balanceRefreshController.loadComplete();
  }

  Future _loadBalanceData() async {
    _api.getHistoryBalance(_balanceHistoryPage + 1).then((balanceHistory) {
      print(balanceHistory);
      if (balanceHistory['result'].isNotEmpty) {
        _balanceHistoryPage++;
        List temp = balanceHistory['result'].toList();
        setState(() {
          _historyBalanceList.addAll(temp);
        });
      }
    });
  }

  Widget _historyBalanceBuilder(BuildContext context, snapshot) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        InkWell(
          child: Row(
            children: <Widget>[
              SizedBox(width: 20),
              _paymentLogo('https://api.indigo24.com/logos/${snapshot['logo']}',
                  type: '${snapshot['type']}'),
              _historyBalanceInfo(snapshot['description'], snapshot['date']),
              _paymentAmount(
                '${snapshot['amount']}',
                '${snapshot['status']}',
                type: '${snapshot['type']}',
              ),
              SizedBox(width: 20),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 10, right: 20, left: 20),
          height: 0.2,
          color: greyColor,
        ),
      ],
    );
  }

  Container _paymentLogo(String logo, {type}) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      alignment: Alignment.topCenter,
      child: ClipRRect(
        child: type != null
            ? Image.asset(
                '$type' == 'out'
                    ? 'assets/images/payOut.png'
                    : 'assets/images/payIn.png',
                width: 40,
                height: 40,
              )
            : Image.network(
                '${logo.replaceAll("AxB", "200x200")}',
                width: 50,
                height: 50,
              ),
      ),
    );
  }

  Container _paymentAmount(String amount, String status, {type}) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            type != null
                ? type == 'out' ? "-$amount KZT" : "+$amount KZT"
                : "$amount KZT",
            style: TextStyle(
              fontSize: 18,
              color: blackPurpleColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Container(
              height: 15,
              width: 15,
              color: status == '4'
                  ? Colors.green
                  : status == '3'
                      ? Colors.orange
                      : status == '2'
                          ? Colors.red
                          : (status == '1') || (status == '0')
                              ? Colors.yellow
                              : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Expanded _historyBalanceInfo(String title, String date) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: brightGreyColor2,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            date,
            style: TextStyle(
              fontSize: 10,
              color: blackPurpleColor,
              fontWeight: FontWeight.w300,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
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
        "${localization.historyBalance}",
        style: TextStyle(
          color: blackPurpleColor,
          fontSize: 22,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.white,
    );
  }

  SafeArea _paymentHistroyBalance(snapshot) {
    return !_emptyResponse
        ? _historyBalanceList.isNotEmpty
            ? SafeArea(
                child: SmartRefresher(
                  enablePullDown: false,
                  enablePullUp: true,
                  footer: CustomFooter(
                    builder: (BuildContext context, LoadStatus mode) {
                      Widget body;
                      return Container(
                        height: 55.0,
                        child: Center(child: body),
                      );
                    },
                  ),
                  controller: _balanceRefreshController,
                  onLoading: _onBalanceLoading,
                  onRefresh: _onBalanceRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 10),
                    itemCount: snapshot != null ? snapshot.length : 0,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        padding: const EdgeInsets.only(top: 10),
                        child: _historyBalanceBuilder(
                          context,
                          snapshot[index],
                        ),
                      );
                    },
                  ),
                ),
              )
            : SafeArea(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
        : SafeArea(
            child: Container(
              child: Center(child: Text('${localization.empty}')),
            ),
          );
  }
}
