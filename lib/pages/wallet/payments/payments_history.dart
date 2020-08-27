import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../filter.dart';
import 'payments_service.dart';

class PaymentHistoryPage extends StatefulWidget {
  @override
  _PaymentHistoryPageState createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage>
    with TickerProviderStateMixin {
  bool _emptyResponse;

  String _logoUrl;
  String _text;

  List _splittedDates;
  List _resultList = [];

  Api _api;

  RefreshController _refreshController;

  TextEditingController _filterController;

  int _page;

  @override
  void initState() {
    _emptyResponse = false;

    _page = 1;
    _logoUrl = "";
    _text = '';

    _api = Api();

    _splittedDates = [];

    _filterController = TextEditingController();
    _refreshController = RefreshController(initialRefresh: false);

    _api.getHistories(_page).then((histories) {
      if (histories['message'] == 'Not authenticated' &&
          histories['success'].toString() == 'false') {
        logOut(context);
      } else {
        setState(() {
          _logoUrl = histories['logoURL'];

          if (histories['payments'].toList().isEmpty) {
            _emptyResponse = true;
          }

          if (_page == 1) _resultList = histories['payments'].toList();
        });
        _page++;
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
        body: _paymentHistroyBody(_resultList, context));
  }

  void _onRefresh() {
    print("_onRefresh ");
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    print("_onLoading ");
    if (_filterController.text.isNotEmpty) {
      _api
          .getFilteredHistories(
        _page,
        _splittedDates[0],
        _splittedDates[1],
      )
          .then((histories) {
        if (histories['message'] == 'Not authenticated' &&
            histories['success'].toString() == 'false') {
          logOut(context);
        } else {
          setState(() {
            _resultList.addAll(histories['payments'].toList());
          });
          _page++;
        }
      });
    } else {
      _loadData();
    }
    _refreshController.loadComplete();
  }

  // TODO ADD THIS WHEN WE CAN ABLE TO DOWNLOAD PDF
  // void _showDownloadProgress(received, total) {
  //   if (total != -1) {
  //     print((received / total * 100).toStringAsFixed(0) + "%");
  //   }
  // }

  // Future _download(Dio dio, String url, String savePath) async {
  //   try {
  //     Response response = await dio.get(
  //       url,
  //       onReceiveProgress: _showDownloadProgress,
  //       options: Options(
  //           responseType: ResponseType.bytes,
  //           followRedirects: false,
  //           validateStatus: (status) {
  //             return status < 500;
  //           }),
  //     );
  //     print(response.headers);
  //     File file = File(savePath);
  //     var raf = file.openSync(mode: FileMode.write);
  //     raf.writeFromSync(response.data);

  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => PDFViewer(raf.path)),
  //     );
  //     await raf.close();
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  Widget _historyBuilder(
    BuildContext context,
    String logo,
    String account,
    String amount,
    String title,
    String date,
    String status,
    int index,
    String url,
    int serviceID,
  ) {
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
              SizedBox(width: 5),
              Container(
                width: 40,
                child: InkWell(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Image.asset(
                            'assets/images/repeat.png',
                            width: 20,
                            height: 20,
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            localization.repeat,
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
                        builder: (context) => PaymentsServicePage(
                          serviceID,
                          logo,
                          title,
                          account: account,
                          amount: amount,
                        ),
                      ),
                    );
                  },
                ),
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

  Container _paymentAmount(amount, String status, {type}) {
    amount = double.parse(amount);
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            type != null
                ? type == 'out'
                    ? "-${amount.toStringAsFixed(2)} KZT"
                    : "+${amount.toStringAsFixed(2)} KZT"
                : "${amount.toStringAsFixed(2)} KZT",
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
                          : (status == '1' || status == '0')
                              ? Colors.yellow
                              : Colors.grey,
            ),
          ),
        ],
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
            title,
            style: TextStyle(
              fontSize: 14,
              color: brightGreyColor2,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            account,
            style: TextStyle(
              fontSize: 14,
              color: blackPurpleColor,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
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
        localization.payments,
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

  Future _loadData() async {
    _api.getHistories(_page).then((histories) {
      print(histories);
      if (histories['payments'].isNotEmpty) {
        List temp = histories['payments'].toList();
        setState(() {
          _resultList.addAll(temp);
        });
        _page++;
        print(_page);
      }
    });
  }

  Widget _paymentHistroyBody(snapshot, context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          // width: MediaQuery.of(context).size.width / 1.5,
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: size.width * 0.8 - 20,
                child: TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'YYYY-MM-DD / YYYY-MM-DD',
                  ),
                  controller: _filterController,
                  textAlign: TextAlign.center,
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
                  _page = 1;
                  _api
                      .getFilteredHistories(
                          _page, selectedDate[0], selectedDate[1])
                      .then((histories) {
                    if (histories['message'] == 'Not authenticated' &&
                        histories['success'].toString() == 'false') {
                      logOut(context);
                    } else {
                      if (histories['message'] != null) {
                        setState(() {
                          _text = histories['message'];
                        });
                      } else {
                        _text = '';
                        setState(() {
                          _resultList = histories['payments'].toList();
                        });
                        _page++;
                      }
                    }
                  });
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        _text == ''
            ? !_emptyResponse
                ? _resultList.isNotEmpty
                    ? Flexible(
                        child: SafeArea(
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
                                    "$_logoUrl${snapshot[index]['logo']}",
                                    "${snapshot[index]['account']}",
                                    "${snapshot[index]['amount']}",
                                    "${snapshot[index]['title']}",
                                    "${snapshot[index]['data']}",
                                    "${snapshot[index]['status']}",
                                    index,
                                    "${snapshot[index]['pdf']}",
                                    snapshot[index]['serviceID'],
                                  ),
                                );
                              },
                            ),
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
                  )
            : Center(
                child: Text(
                  _text,
                ),
              ),
      ],
    );
  }
}
