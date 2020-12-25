import 'package:flutter/material.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/services/api/http/api.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_appbar_widget.dart';
import 'package:indigo24/widgets/service_widget.dart';
import 'payments_services.dart';
import 'package:indigo24/services/localization/localization.dart';

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
    _api.getCategory(widget.categoryId, widget.locationType).then((categories) {
      if (categories['message'] == 'Not authenticated' &&
          categories['success'].toString() == 'false') {
        logOut(context);
      } else {
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
        appBar: IndigoAppBarWidget(
          title: Text(
            Localization.language.payments,
            style: TextStyle(
              color: blackPurpleColor,
              fontSize: 22,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        body: _categories != null
            ? SafeArea(
                child: Column(
                  children: [
                    Flexible(
                      child: ListView.builder(
                        padding: EdgeInsets.only(bottom: 20),
                        shrinkWrap: true,
                        itemCount: _categories['items'] != null
                            ? _categories['items'].length
                            : 0,
                        itemBuilder: (BuildContext context, int index) {
                          dynamic category = _categories['items'][index];
                          String categoryTitle = category['location_name'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: ServiceWidget(
                              title: categoryTitle,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentsServices(
                                      category['categoryID'],
                                      categoryTitle,
                                      locationId: category['location_id'],
                                      locationType: widget.locationType,
                                    ),
                                  ),
                                );
                              },
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
}
