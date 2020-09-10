import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/style/colors.dart';

import 'payments_history.dart';
import 'payments_service.dart';
import 'payments_services.dart';
import 'package:indigo24/services/localization.dart' as localization;

class PaymentsRegion extends StatefulWidget {
  final int categoryId;
  final String locationType;

  const PaymentsRegion({Key key, this.categoryId, this.locationType})
      : super(key: key);
  @override
  _PaymentsRegionState createState() => _PaymentsRegionState();
}

class _PaymentsRegionState extends State<PaymentsRegion> {
  Api _api;
  Map<String, dynamic> _categories;

  @override
  void initState() {
    super.initState();

    _api = Api();
    print('location type is ${widget.locationType}');
    _api.getCategory(widget.categoryId, widget.locationType).then((categories) {
      if (categories['message'] == 'Not authenticated' &&
          categories['success'].toString() == 'false') {
        logOut(context);
      } else {
        print(categories);
        setState(() {
          _categories = categories;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _categories != null
            ? SafeArea(
                child: Column(
                  children: [
                    Flexible(
                      child: ListView.builder(
                        padding: EdgeInsets.only(bottom: 20),
                        shrinkWrap: true,
                        itemCount: _categories["items"] != null
                            ? _categories["items"].length
                            : 0,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: _paymentsList(
                              context,
                              _categories["items"][index]['location_name'],
                              _categories['items'][index]['categoryID'],
                              _categories["items"][index]['location_id'],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
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
        "${localization.payments}",
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

  Container _paymentsList(
      BuildContext context, String name, int index, locationId) {
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
                builder: (context) => PaymentsServices(
                  index,
                  name,
                  locationId: locationId,
                  locationType: widget.locationType,
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
