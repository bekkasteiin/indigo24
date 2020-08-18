import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/style/colors.dart';

import 'payments_history.dart';
import 'payments_service.dart';
import 'payments_services.dart';
import 'package:indigo24/services/localization.dart' as localization;

class PaymentsCategoryPage extends StatefulWidget {
  @override
  _PaymentsCategoryPageState createState() => _PaymentsCategoryPageState();
}

class _PaymentsCategoryPageState extends State<PaymentsCategoryPage> {
  Api _api;
  Map<String, dynamic> _categories;
  List services;
  String _logoUrl;
  TextEditingController _searchController;

  @override
  void initState() {
    super.initState();

    _logoUrl = '';
    _searchController = TextEditingController();
    _api = Api();

    _api.getCategories().then((categories) {
      if (categories['message'] == 'Not authenticated' &&
          categories['success'].toString() == 'false') {
        logOut(context);
      } else {
        setState(() {
          _categories = categories;
          _logoUrl = _categories["logoURL"];
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _categories != null
          ? Stack(
              children: <Widget>[
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: 10,
                          left: 20,
                          right: 20,
                          bottom: 0,
                        ),
                        child: Row(
                          children: <Widget>[
                            Flexible(
                              child: TextField(
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: blackPurpleColor,
                                  ),
                                  hintText: "${localization.search}",
                                  fillColor: blackPurpleColor,
                                ),
                                onChanged: (value) {
                                  searchOnChanged();
                                },
                                controller: _searchController,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.search),
                              onPressed: () {
                                search(_searchController.text);
                              },
                            )
                          ],
                        ),
                      ),
                      needToShowServices
                          ? Flexible(
                              child: ListView.builder(
                                padding: EdgeInsets.only(bottom: 20),
                                shrinkWrap: true,
                                itemCount:
                                    services != null ? services.length : 0,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: _servicesList(
                                      context,
                                      _logoUrl + services[index]['logo'],
                                      services[index]['title'],
                                      services[index]['id'],
                                      services[index]['is_convertable'],
                                    ),
                                  );
                                },
                              ),
                            )
                          : Flexible(
                              child: ListView.builder(
                                padding: EdgeInsets.only(bottom: 20),
                                shrinkWrap: true,
                                itemCount: _categories["categories"] != null
                                    ? _categories["categories"].length
                                    : 0,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: _paymentsList(
                                      context,
                                      _categories["logoURL"] +
                                          _categories["categories"][index]
                                              ['logo'],
                                      _categories["categories"][index]['title'],
                                      _categories["categories"][index]['ID'],
                                    ),
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                ),
                isReadyToSend
                    ? Center()
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  bool isReadyToSend = true;
  bool needToShowServices = false;
  searchOnChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        needToShowServices = false;
      });
    }
  }

  search(String query) {
    setState(() {
      needToShowServices = true;
    });
    if (isReadyToSend) {
      setState(() {
        isReadyToSend = false;
      });
      _api.searchServices(query).then((result) {
        setState(() {
          services = result;
        });
      });
      setState(() {
        isReadyToSend = true;
      });
    }
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
        "${localization.payments}",
        style: TextStyle(
          color: blackPurpleColor,
          fontSize: 22,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
      actions: <Widget>[
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(5),
            child: Image(
              image: AssetImage(
                'assets/images/history.png',
              ),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentHistoryPage(),
              ),
            );
          },
        )
      ],
      backgroundColor: Colors.white,
    );
  }

  Container _servicesList(BuildContext context, String logo, String name,
      int index, int isConvertable) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 10),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            spreadRadius: -2,
            offset: Offset(0.0, 0.0))
      ]),
      child: ButtonTheme(
        height: 40,
        child: RaisedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentsServicePage(index, logo, name,
                    isConvertable: isConvertable),
              ),
            );
          },
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 35,
                  height: 40,
                  margin: EdgeInsets.only(right: 20, top: 10, bottom: 10),
                  child: Image.network(
                    '$logo',
                    width: 30.0,
                  ),
                ),
                Container(width: 10),
                Expanded(
                  child: Text(
                    '$name',
                    style: TextStyle(fontSize: 14, color: blackPurpleColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          color: whiteColor,
          textColor: blackPurpleColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              10.0,
            ),
          ),
        ),
      ),
    );
  }

  Container _paymentsList(
      BuildContext context, String logo, String name, int index) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 10),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            spreadRadius: -2,
            offset: Offset(0.0, 0.0))
      ]),
      child: ButtonTheme(
        height: 40,
        child: RaisedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentsGroupPage(
                  index,
                  name,
                ),
              ),
            );
          },
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 35,
                  height: 40,
                  margin: EdgeInsets.only(right: 20, top: 10, bottom: 10),
                  child: Image.network(
                    '$logo',
                    width: 30.0,
                  ),
                ),
                Container(width: 10),
                Expanded(
                  child: Text(
                    '$name',
                    style: TextStyle(fontSize: 14, color: blackPurpleColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          color: whiteColor,
          textColor: blackPurpleColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              10.0,
            ),
          ),
        ),
      ),
    );
  }
}
