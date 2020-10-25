import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/indigo_appbar_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'filter.dart';

class BalanceHistoryPage extends StatefulWidget {
  @override
  _BalanceHistoryPageState createState() => _BalanceHistoryPageState();
}

class _BalanceHistoryPageState extends State<BalanceHistoryPage>
    with TickerProviderStateMixin {
  bool _emptyResponse;
  bool _isProccessing;

  int _balanceHistoryPage;

  String _text;
  String _emptyResponseString = '';
  List _historyBalanceList;
  List _splittedDates;

  Api _api;

  RefreshController _balanceRefreshController;

  TextEditingController _filterController;

  @override
  void initState() {
    _emptyResponse = false;
    _isProccessing = false;

    _balanceHistoryPage = 1;

    _api = Api();

    _balanceRefreshController = RefreshController(initialRefresh: false);

    _filterController = TextEditingController();

    _api.getHistoryBalance(_balanceHistoryPage).then((histories) {
      if (histories['message'] == 'Not authenticated' &&
          histories['success'].toString() == 'false') {
        logOut(context);
      } else {
        setState(() {
          if (histories['result'].isEmpty) {
            _emptyResponse = true;
          }
          _historyBalanceList = histories['result'];
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
      appBar: IndigoAppBarWidget(
        title: Text(
          "${localization.historyBalance}",
          style: TextStyle(
            color: blackPurpleColor,
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            _isProccessing == true
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Center(),
            _paymentHistroyBalance(_historyBalanceList, context)
          ],
        ),
      ),
    );
  }

  void _onBalanceLoading() async {
    if (_filterController.text.isNotEmpty) {
      _loadFilteredBalanceData();
    } else {
      _loadBalanceData();
    }
    _balanceRefreshController.loadComplete();
  }

  Future _loadFilteredBalanceData() async {
    _balanceHistoryPage += 1;
    _api
        .getFilteredHistoryBalance(
            _balanceHistoryPage, _splittedDates[0], _splittedDates[1])
        .then((historyBalance) {
      if (historyBalance['message'] == 'Not authenticated' &&
          historyBalance['success'].toString() == 'false') {
        logOut(context);
        return historyBalance;
      } else {
        if (historyBalance['result'].isNotEmpty) {
          _balanceHistoryPage++;
          List temp = historyBalance['result'].toList();
          setState(() {
            _historyBalanceList.addAll(temp);
          });
        }
      }
    });
  }

  Future _loadBalanceData() async {
    _api.getHistoryBalance(_balanceHistoryPage + 1).then((balanceHistory) {
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

  Widget paymentStatus(int status) {
    String text = '';

    Color color = greyColor;
    switch (status) {
      case 0:
        text = localization.newPayment;
        color = Colors.yellow;
        break;
      case 1:
        text = localization.newPayment;
        color = Colors.yellow;

        break;

      case 2:
        text = localization.error;
        color = Colors.red;
        break;
      case 3:
        text = localization.pending;
        color = Colors.orange;

        break;
      case 4:
        text = localization.success;
        color = Colors.green;
        break;
      default:
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        color: color,
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
          paymentStatus(int.parse(status)),
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

  SafeArea _paymentHistroyBalance(snapshot, context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: size.width * 0.8 - 20,
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'YYYY-MM-DD / YYYY-MM-DD',
                    ),
                    controller: _filterController,
                    textAlign: TextAlign.center,
                    readOnly: true,
                  ),
                ),
                InkWell(
                  child: Container(
                    width: size.width * 0.2 - 20,
                    padding: EdgeInsets.all(5),
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Image.asset(
                            'assets/images/filter.png',
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () async {
                    List selectedDate = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryFiletPage(),
                      ),
                    );
                    _filterController.text = selectedDate.join(' / ');

                    _splittedDates = selectedDate;
                    _balanceHistoryPage = 1;

                    setState(() {
                      _isProccessing = true;
                    });
                    _api
                        .getFilteredHistoryBalance(
                      _balanceHistoryPage,
                      selectedDate[0],
                      selectedDate[1],
                    )
                        .then((historyBalance) {
                      setState(() {
                        _isProccessing = false;
                      });
                      if (historyBalance['message'] == 'Not authenticated' &&
                          historyBalance['success'].toString() == 'false') {
                        logOut(context);
                        return historyBalance;
                      } else {
                        if (historyBalance['succcess'].toString() == 'false') {
                          _historyBalanceList = null;
                          _text = historyBalance['message'];
                        } else {
                          _historyBalanceList = historyBalance['result'];
                          if (historyBalance['result'].isEmpty) {
                            setState(() {
                              _emptyResponse = true;
                              _emptyResponseString = 'Нет историй';
                            });
                          } else {
                            setState(() {
                              _emptyResponse = false;
                            });
                          }
                          _balanceHistoryPage++;
                        }
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          _historyBalanceList != null
              ? !_emptyResponse
                  ? _historyBalanceList.isNotEmpty
                      ? Flexible(
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
                          child: Container(
                            child: Center(child: Text('${localization.empty}')),
                          ),
                        )
                  : SafeArea(
                      child: Center(
                        child: Text('$_emptyResponseString'),
                      ),
                    )
              : Center(
                  child: _text != null
                      ? Text(
                          '$_text',
                        )
                      : CircularProgressIndicator(),
                ),
        ],
      ),
    );
  }
}
