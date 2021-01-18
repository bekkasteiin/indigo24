import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/pages/wallet/filter.dart';
import 'package:indigo24/pages/wallet/payments/payments_service/payments_service.dart';
import 'package:indigo24/widgets/alerts/indigo_logout.dart';
import 'package:indigo24/services/api/http/api.dart';
import 'package:indigo24/services/localization/localization.dart';
import 'package:indigo24/pages/wallet/payments/payments_history/payment_history_model.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/alerts/indigo_show_dialog.dart';
import 'package:indigo24/widgets/alerts/payments_voucher.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_appbar_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:indigo24/services/constants.dart';

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
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: IndigoAppBarWidget(
          title: Text(
            Localization.language.paymentsHistory,
            style: TextStyle(
              color: blackPurpleColor,
              fontSize: 22,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        body: _paymentHistroyBody(_resultList, context));
  }

  void _onLoading() async {
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

  // void _showDownloadProgress(received, total) {
  //   if (total != -1) {
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
  //     File file = File(savePath);
  //     var raf = file.openSync(mode: FileMode.write);
  //     raf.writeFromSync(response.data);

  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => PDFViewer(raf.path)),
  //     );
  //     await raf.close();
  //   } catch (e) {
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
      height: 40,
      width: 40,
      margin: EdgeInsets.only(right: 10),
      alignment: Alignment.topCenter,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: CachedNetworkImage(imageUrl: '$logo'),
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
              fontSize: 16,
              color: blackPurpleColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 5),
          paymentStatus(int.tryParse(status)),
        ],
      ),
    );
  }

  Widget paymentStatus(int status) {
    String text = '';
    Color color = greyColor;
    switch (status) {
      case 0:
        text = Localization.language.newPayment;
        color = pendingColor;
        break;
      case 1:
        text = Localization.language.newPayment;
        color = pendingColor;
        break;
      case 2:
        text = Localization.language.error;
        color = errorColor;
        break;
      case 3:
        text = Localization.language.pending;
        color = pendingColor;
        break;
      case 4:
        text = Localization.language.success;
        color = succesColor;
        break;
      default:
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: whiteColor,
          ),
        ),
        color: color,
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
            maxLines: 5,
            style: TextStyle(
              fontSize: 14,
              color: brightGreyColor2,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '+' + account,
            maxLines: 2,
            style: TextStyle(
              fontSize: 14,
              color: blackPurpleColor,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            date,
            maxLines: 2,
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

  Future _loadData() async {
    _api.getHistories(_page).then((histories) {
      if (histories['payments'].isNotEmpty) {
        List temp = histories['payments'].toList();
        setState(() {
          _resultList.addAll(temp);
        });
        _page++;
      }
    });
  }

  Widget _paymentHistroyBody(snapshot, context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          color: whiteColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: size.width * 0.8 - 20,
                child: Text(
                  _filterController.text.isEmpty
                      ? 'YYYY-MM-DD / YYYY-MM-DD'
                      : _filterController.text,
                  style: TextStyle(
                    color: primaryColor,
                  ),
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
                          '${assetsPath}filter.png',
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
                                PaymentHistoryModel paymentHistoryModel =
                                    PaymentHistoryModel.fromJson(
                                  snapshot[index],
                                );
                                return InkWell(
                                  onTap: () {
                                    showIndigoDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: PaymentVoucher(
                                        paymentHistoryModel:
                                            paymentHistoryModel,
                                        buttonCallBack: () {
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PaymentsServicePage(
                                                paymentHistoryModel.serviceId,
                                                paymentHistoryModel.logo,
                                                paymentHistoryModel.title,
                                                account:
                                                    paymentHistoryModel.account,
                                                amount: paymentHistoryModel
                                                    .amount
                                                    .toString(),
                                                providerId: null,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: _historyBuilder(
                                      context,
                                      "$_logoUrl${paymentHistoryModel.logo}",
                                      "${paymentHistoryModel.account}",
                                      "${paymentHistoryModel.amount}",
                                      "${paymentHistoryModel.title}",
                                      "${paymentHistoryModel.data}",
                                      "${paymentHistoryModel.status}",
                                      index,
                                      "${snapshot[index]['pdf']}",
                                      paymentHistoryModel.serviceId,
                                    ),
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
                      child:
                          Center(child: Text('${Localization.language.empty}')),
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
