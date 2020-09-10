import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/alerts.dart';
import 'payments_service.dart';
import 'package:indigo24/services/constants.dart';

class PaymentsServices extends StatefulWidget {
  final int categoryID;
  final String title;
  final int locationId;
  final String locationType;
  PaymentsServices(this.categoryID, this.title,
      {this.locationId, this.locationType});

  @override
  _PaymentsServicesState createState() => _PaymentsServicesState();
}

class _PaymentsServicesState extends State<PaymentsServices> {
  Api _api;

  Map<String, dynamic> _services;

  @override
  void initState() {
    super.initState();
    _api = Api();
    if (widget.locationId != null && widget.locationType != null) {
      print('getting with location');
      _api
          .getServices(widget.categoryID,
              locationId: widget.locationId, locationType: widget.locationType)
          .then((services) {
        if (services['message'] == 'Not authenticated' &&
            services['success'].toString() == 'false') {
          logOut(context);
        } else if (services['success'].toString() == 'false') {
          indigoCupertinoDialogAction(context, services['message'], isDestructiveAction: false, leftButtonCallBack: () { Navigator.pop(context);});
        } else {
          setState(() {
            _services = services;
            print('services is $_services');
          });
        }
      });
    } else {
      print('getting without location');
      _api.getServices(widget.categoryID).then((services) {
        if (services['message'] == 'Not authenticated' &&
            services['success'].toString() == 'false') {
          logOut(context);
        } else {
          setState(() {
            _services = services;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _services != null
          ? SafeArea(
              child: Scrollbar(
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: 20),
                  shrinkWrap: true,
                  itemCount: _services["services"] != null
                      ? _services["services"].length
                      : 0,
                  itemBuilder: (BuildContext context, int index) {
                    print(_services['services'][index]);
                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: _paymentsList(
                        context,
                        "$logos${_services["services"][index]['logo']}",
                        "${_services["services"][index]['title']}",
                        _services["services"][index]['id'],
                        _services["services"][index]['is_convertable'],
                        _services["services"][index]['provider_id'],
                      ),
                    );
                  },
                ),
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
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

  Container _paymentsList(BuildContext context, String _serviceLogo,
      String _serviceTitle, int index, isConvertable, int providerId) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 10),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            spreadRadius: -2,
            offset: Offset(0.0, 0.0),
          )
        ],
      ),
      child: ButtonTheme(
        height: 40,
        child: RaisedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentsServicePage(
                  index,
                  _serviceLogo,
                  _serviceTitle,
                  isConvertable: isConvertable,
                  providerId: providerId,
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
                    '$_serviceLogo',
                    width: 30.0,
                  ),
                ),
                Container(width: 10),
                Expanded(
                  child: Text(
                    '$_serviceTitle',
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
