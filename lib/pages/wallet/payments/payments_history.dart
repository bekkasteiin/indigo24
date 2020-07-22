import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/pages/chat/chat_page_view_test.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PaymentHistoryPage extends StatefulWidget {
  @override
  _PaymentHistoryPageState createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage>
    with TickerProviderStateMixin {
  bool emptyResponse = false;
  String logoUrl = "";
  @override
  void initState() {
    api.getHistories(page).then((histories) {
      if (histories['message'] == 'Not authenticated' &&
          histories['success'].toString() == 'false') {
        logOut(context);
      } else {
        setState(() {
          logoUrl = histories['logoURL'];
          if (histories['payments'].toList().isEmpty) {
            emptyResponse = true;
          }
          if (page == 1) test = histories['payments'].toList();
        });
        page++;
      }
    });

    super.initState();
  }

  Api api = Api();

  void showDownloadProgress(received, total) {
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  Future download2(Dio dio, String url, String savePath) async {
    try {
      Response response = await dio.get(
        url,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status < 500;
            }),
      );
      print(response.headers);
      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PDFViewer(raf.path)),
      );
      await raf.close();
    } catch (e) {
      print(e);
    }
  }

  Dio dio = Dio();

  Widget _historyBuilder(
      BuildContext context,
      String logo,
      String account,
      String amount,
      String title,
      String date,
      String status,
      int index,
      String url) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        InkWell(
          child: Row(
            children: <Widget>[
              SizedBox(width: 20),
              _paymentLogo(logo),
              _paymentInfo(title, account, date),
              _paymentAmount(amount, status),
              SizedBox(width: 20),
            ],
          ),
          // onTap: () async{
          //   var tempDir = await getTemporaryDirectory();
          //   String fullPath = tempDir.path + "/boo2.pdf'";
          //   print('full path ${fullPath}');

          //   download2(dio, url, fullPath);
          // },
        ),
        Container(
          margin: EdgeInsets.only(top: 10, right: 20, left: 20),
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
        child: Image.network(
          '${logo.replaceAll("AxB", "200x200")}',
          width: 50.0,
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
                ? '$type' == 'out' ? "-$amount KZT" : "+$amount KZT"
                : "$amount KZT",
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF001D52),
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
                                : Colors.grey),
          ),
        ],
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
              fontSize: 14,
              color: Color(0xFF636973),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "$account",
            style: TextStyle(
              fontSize: 14,
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

  List test = [];
  List historyBalanceList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: buildAppBar(), body: _paymentHistroyBody(test));
  }

  void onRefresh() {
    print("_onRefresh ");
    _refreshController.refreshCompleted();
  }

  void onBalanceLoading() async {
    print("_onBalanceLoading ");
    _loadBalanceData();
    _balanceRefreshController.loadComplete();
  }

  void _onLoading() async {
    print("_onLoading ");
    _loadData();
    _refreshController.loadComplete();
  }

  bool isLoaded = false;
  int page = 1;
  int balanceHistoryPage = 1;

  Future _loadBalanceData() async {
    api.getHistoryBalance(balanceHistoryPage + 1).then((balanceHistory) {
      print(balanceHistory);
      if (balanceHistory['result'].isNotEmpty) {
        balanceHistoryPage++;
        List temp = balanceHistory['result'].toList();
        setState(() {
          historyBalanceList.addAll(temp);
        });
        print(balanceHistoryPage);
      }
    });
  }

  Future _loadData() async {
    api.getHistories(page).then((histories) {
      print(histories);
      if (histories['payments'].isNotEmpty) {
        List temp = histories['payments'].toList();
        setState(() {
          test.addAll(temp);
        });
        page++;
        print(page);
      }
    });
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  RefreshController _balanceRefreshController =
      RefreshController(initialRefresh: false);

  SafeArea _paymentHistroyBody(snapshot) {
    return !emptyResponse
        ? test.isNotEmpty
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
                  controller: _refreshController,
                  onLoading: _onLoading,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 10),
                    itemCount: snapshot != null ? snapshot.length : 0,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        padding: const EdgeInsets.only(top: 10),
                        child: _historyBuilder(
                            context,
                            "$logoUrl${snapshot[index]['logo']}",
                            "${snapshot[index]['account']}",
                            "${snapshot[index]['amount']}",
                            "${snapshot[index]['title']}",
                            "${snapshot[index]['data']}",
                            "${snapshot[index]['status']}",
                            index,
                            "${snapshot[index]['pdf']}"),
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
