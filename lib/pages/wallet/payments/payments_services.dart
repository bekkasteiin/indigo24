import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'payments_service.dart';
import 'package:indigo24/services/constants.dart';

class PaymentsGroupPage extends StatefulWidget {
  final int categoryID;
  final String title;
  PaymentsGroupPage(this.categoryID, this.title);

  @override
  _PaymentsGroupPageState createState() => _PaymentsGroupPageState();
}

class _PaymentsGroupPageState extends State<PaymentsGroupPage> {
  var test = logos;
  Api api = Api();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: api.getServices(widget.categoryID).then((services) {
          if (services['message'] == 'Not authenticated' && services['success'].toString() == 'false') {
            logOut(context);
            return services;
          } else {
            return services;
          }
        }),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: buildAppBar(),
            body: snapshot.hasData == true
                ? SafeArea(
                  child: Scrollbar(
                    child: ListView.builder(
                        padding: EdgeInsets.only(bottom: 20),
                        shrinkWrap: true,
                        itemCount: snapshot.data["services"] != null ? snapshot.data["services"].length : 0,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: _paymentsList(
                              context,
                              "$logos${snapshot.data["services"][index]['logo']}",
                              "${snapshot.data["services"][index]['title']}",
                              snapshot.data["services"][index]['id'],
                            ),
                          );
                        },
                      ),
                  ),
                )
                : Center(child: CircularProgressIndicator()),
          );
        });
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

  Container _paymentsList(BuildContext context, String _serviceLogo,
      String _serviceTitle, int index) {
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
              builder: (context) =>
                  PaymentsServicePage(index, _serviceLogo, _serviceTitle),
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
                    style: TextStyle(fontSize: 14, color: Color(0xFF001D52)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          color: Color(0xFFFFFFFF),
          textColor: Color(0xFF001D52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              10.0,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
}
