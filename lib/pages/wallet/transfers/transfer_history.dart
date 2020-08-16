import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/style/colors.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:indigo24/services/localization.dart' as localization;

import 'transfer.dart';

class TransferHistoryPage extends StatefulWidget {
  @override
  _TransferHistoryPageState createState() => _TransferHistoryPageState();
}

List _transferHistories;

class _TransferHistoryPageState extends State<TransferHistoryPage> {
  Api _api;
  String _avatarUrl;
  bool _emptyResponse;
  RefreshController _refreshController;

  int _page;

  MaskTextInputFormatter _filterFormatter;

  @override
  void initState() {
    super.initState();

    _page = 1;
    _emptyResponse = false;
    _api = Api();
    _transferHistories = [];
    _avatarUrl = "";

    _refreshController = RefreshController(initialRefresh: false);

    _filterFormatter = MaskTextInputFormatter(
      mask: '****-**-** / ****-**-**',
      filter: {
        "*": RegExp(r'[0-9]'),
      },
    );

    _api.getTransactions(_page).then((transactions) {
      if (transactions['message'] == 'Not authenticated' &&
          transactions['success'].toString() == 'false') {
        logOut(context);
      } else {
        setState(() {
          _avatarUrl = transactions['avatarURL'];
          if (_page == 1) {
            _transferHistories = transactions['transactions'].toList();
            if (transactions['transactions'].isEmpty) {
              _emptyResponse = true;
            }
            _page++;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _refreshController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: size.width * 0.8 - 20,
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    inputFormatters: [_filterFormatter],
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
                  onTap: () {
                    String maskedText =
                        _filterFormatter.getMaskedText().replaceAll(' ', '');

                    var splittedDates = maskedText.split("/");
                    _page = 1;
                    api
                        .getTransactions(_page,
                            fromDate: splittedDates[0],
                            toDate: splittedDates[1])
                        .then((transactions) {
                      print(transactions);
                      if (transactions['message'] == 'Not authenticated' &&
                          transactions['success'].toString() == 'false') {
                        logOut(context);
                        return transactions;
                      } else {
                        setState(() {
                          _avatarUrl = transactions['avatarURL'];
                          if (_page == 1) {
                            print('setStates');

                            _transferHistories =
                                transactions['transactions'].toList();
                            if (transactions['transactions'].isEmpty) {
                              _emptyResponse = true;
                            }
                            _page++;
                          }
                        });

                        return transactions;
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          !_emptyResponse
              ? _transferHistories.isNotEmpty
                  ? Flexible(
                      child: _transferHistoryBody(_transferHistories, context))
                  : Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: Container(
                    child: Center(child: Text('${localization.empty}')),
                  ),
                ),
        ],
      ),
    );
  }

  Container _transferLogo(String logo) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      alignment: Alignment.topCenter,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Image.network(
          '${logo.replaceAll("AxB", "200x200")}',
          width: 50,
          height: 50,
        ),
      ),
    );
  }

  Widget _transferAmount(String type, String amount, phone) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(),
            Text(
              type == 'in' ? '+$amount KZT' : "-$amount KZT",
              style: TextStyle(
                fontSize: 14,
                color: blackPurpleColor,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  height: 15,
                  width: 15,
                  color: type == 'in' ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: 5),
        InkWell(
          child: Container(
            width: 40,
            padding: EdgeInsets.all(5),
            child: Column(
              children: <Widget>[
                Container(
                  child: Image.asset(
                    type == 'in'
                        ? 'assets/images/repeat.png'
                        : 'assets/images/replyTransfer.png',
                    width: 20,
                    height: 20,
                  ),
                ),
                FittedBox(
                  child: Text(
                    '${type == 'in' ? localization.repeat : localization.reply}',
                    style: TextStyle(
                      color: Color(0xFF0543B8),
                    ),
                  ),
                )
              ],
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransferPage(
                  phone: phone,
                  amount: amount,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Expanded _transferInfo(
      String name, String date, String phone, String comment) {
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
              color: blackPurpleColor,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "$phone",
            style: TextStyle(
              fontSize: 12,
              color: blackPurpleColor,
              fontWeight: FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          comment.toString() != null.toString()
              ? Text(
                  '$comment',
                  style: TextStyle(
                    fontSize: 12,
                    color: blackPurpleColor,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                )
              : Center(),
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

  Widget _historyBuilder(
    BuildContext context,
    String logo,
    String amount,
    String title,
    String phone,
    String type,
    String date,
    String comment,
    int index,
  ) {
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
                _transferInfo(title, date, phone, comment),
                _transferAmount(type, amount, phone),
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
      ),
    );
  }

  void _onLoading() async {
    _loadData();
    _refreshController.loadComplete();
  }

  Future _loadData() async {
    _api.getTransactions(_page).then((histories) {
      List temp = histories['transactions'].toList();
      setState(() {
        _transferHistories.addAll(temp);
      });
      _page++;
    });
  }

  SafeArea _transferHistoryBody(snapshot, context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
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
              controller: _refreshController,
              onLoading: _onLoading,
              child: ListView.builder(
                itemCount: snapshot != null ? snapshot.length : 0,
                padding: const EdgeInsets.only(bottom: 10),
                shrinkWrap: false,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    padding: const EdgeInsets.only(top: 10),
                    child: _historyBuilder(
                      context,
                      "${_avatarUrl + snapshot[index]['avatar']}",
                      "${snapshot[index]['amount']}",
                      "${snapshot[index]['name']}",
                      "${snapshot[index]['phone']}",
                      '${snapshot[index]['type']}',
                      "${snapshot[index]['data']}",
                      '${snapshot[index]['comment']}',
                      index,
                    ),
                  );
                },
              ),
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
          color: blackPurpleColor,
          fontSize: 22,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.white,
    );
  }
}
