import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/widgets/alerts/indigo_logout.dart';
import 'package:indigo24/services/api/http/api.dart';
import 'package:indigo24/pages/wallet/transfers/transfer_model.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/alerts/indigo_show_dialog.dart';
import 'package:indigo24/widgets/alerts/voucher.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_appbar_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:indigo24/services/localization/localization.dart';
import '../filter.dart';
import 'package:indigo24/services/constants.dart';
import 'transfer.dart';

class TransferHistoryPage extends StatefulWidget {
  @override
  _TransferHistoryPageState createState() => _TransferHistoryPageState();
}

List _transferHistories;

class _TransferHistoryPageState extends State<TransferHistoryPage> {
  Api _api;
  String _avatarUrl;
  String _text;
  bool _emptyResponse;
  RefreshController _refreshController;
  int _page;
  var splittedDates;
  TextEditingController _filterController;

  @override
  void initState() {
    super.initState();

    _page = 1;
    _emptyResponse = false;
    _api = Api();
    _avatarUrl = "";
    _filterController = TextEditingController();
    _refreshController = RefreshController(initialRefresh: false);

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
    _filterController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: IndigoAppBarWidget(
        title: Text(
          Localization.language.transfersHistory,
          style: TextStyle(
            color: blackPurpleColor,
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            color: whiteColor,
            child: Row(
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
                  // TextFormField(
                  //   controller: _filterController,
                  //   decoration: InputDecoration(
                  //     hintText: 'YYYY-MM-DD / YYYY-MM-DD',
                  //   ),
                  //   textAlign: TextAlign.center,
                  //   readOnly: true
                  // ),
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

                    splittedDates = selectedDate;
                    _page = 1;
                    _api
                        .getFilteredTransactions(
                            _page, selectedDate[0], selectedDate[1])
                        .then((transactions) {
                      if (transactions['message'] == 'Not authenticated' &&
                          transactions['success'].toString() == 'false') {
                        logOut(context);
                        return transactions;
                      } else {
                        if (transactions['success'].toString() == 'true') {
                          setState(() {
                            if (_page == 1) {
                              _transferHistories =
                                  transactions['transactions'].toList();
                              if (transactions['transactions'].isEmpty) {
                                _emptyResponse = true;
                              }
                              _page++;
                            }
                          });
                        } else {
                          setState(() {
                            _transferHistories = null;

                            _text = transactions['message'];
                          });
                        }
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          !_emptyResponse
              ? _transferHistories != null
                  ? Flexible(
                      child: _transferHistoryBody(_transferHistories, context))
                  : Center(
                      child: _text != null
                          ? Text(
                              '$_text',
                            )
                          : CircularProgressIndicator(),
                    )
              : SafeArea(
                  child: Container(
                    child:
                        Center(child: Text('${Localization.language.empty}')),
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
        child: CachedNetworkImage(
          imageUrl: logo.replaceAll('AxB', '200x200'),
          width: 40,
          height: 40,
        ),
      ),
    );
  }

  Widget _transferAmount(String type, String amount, phone, String comment) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  type == 'in' ? '+$amount KZT' : "-$amount KZT",
                  style: TextStyle(
                    fontSize: 14,
                    color: blackPurpleColor,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: type == 'in'
                      ? Image.asset('${assetsPath}in.png')
                      : Image.asset('${assetsPath}out.png'),
                ),
                if (comment != null)
                  SizedBox(
                    height: 5,
                  ),
                if (comment != null)
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: blackColor,
                          blurRadius: 10.0,
                          spreadRadius: -10,
                          offset: Offset(
                            0.0,
                            0.0,
                          ),
                        )
                      ],
                      borderRadius: BorderRadius.circular(15),
                      color: whiteColor,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    child: Text(
                      comment,
                      style: TextStyle(fontSize: 12, color: blackPurpleColor),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.justify,
                      maxLines: 3,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _transferInfo(
    String name,
    String date,
    String phone,
  ) {
    date = date.substring(0, date.length - 3);
    return Column(
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
          "+$phone",
          style: TextStyle(
            fontSize: 12,
            color: blackPurpleColor,
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(width: 20),
                _transferLogo(logo),
                _transferInfo(title, date, phone),
                SizedBox(width: 5),
                _transferAmount(type, amount, phone, comment),
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
    if (_filterController.text.isNotEmpty) {
      _loadFilteredData();
    } else {
      _loadData();
    }
    _refreshController.loadComplete();
  }

  Future _loadData() async {
    _api.getTransactions(_page).then((histories) {
      if (histories['success'].toString() == 'true') {
        List temp = histories['transactions'].toList();

        if (temp.isNotEmpty) {
          setState(() {
            _transferHistories.addAll(temp);
          });
          _page++;
        }
      }
    });
  }

  Future _loadFilteredData() async {
    _api
        .getFilteredTransactions(_page, splittedDates[0], splittedDates[1])
        .then((histories) {
      if (histories['success'].toString() == 'true') {
        List temp = histories['transactions'].toList();
        if (temp.isNotEmpty) {
          setState(() {
            _transferHistories.addAll(temp);
          });
          _page++;
        }
      }
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
                  TransferModel transferModel =
                      TransferModel.fromJson(snapshot[index]);
                  return InkWell(
                    onTap: () {
                      showIndigoDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: Voucher(
                          transferModel: transferModel,
                          buttonCallBack: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TransferPage(
                                  phone: transferModel.phone,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    child:
                        // Text(transferModel.name)
                        Container(
                      padding: const EdgeInsets.only(top: 10),
                      child: _historyBuilder(
                        context,
                        "${_avatarUrl + transferModel.avatar}",
                        transferModel.amount.toString(),
                        transferModel.name,
                        transferModel.phone,
                        transferModel.type,
                        transferModel.data,
                        transferModel.comment,
                        index,
                      ),
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
}
