import 'package:flutter/material.dart';
import 'package:indigo24/pages/wallet/payments/payments_history/payments_history.dart';
import 'package:indigo24/widgets/alerts/indigo_logout.dart';
import 'package:indigo24/services/api/http/api.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_appbar_widget.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_search_widget.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_service_widget.dart';

import 'package:indigo24/services/constants.dart';
import '../payments_region.dart';
import '../payments_service/payments_service.dart';
import '../payments_services/payments_services.dart';
import 'package:indigo24/services/localization/localization.dart';

import 'payments_category_model.dart';

class PaymentsCategoryPage extends StatefulWidget {
  @override
  _PaymentsCategoryPageState createState() => _PaymentsCategoryPageState();
}

class _PaymentsCategoryPageState extends State<PaymentsCategoryPage> {
  Api _api;
  List<PaymentCategory> _categories = [];
  List _services;
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
          categories['categories'].forEach((category) {
            _categories.add(PaymentCategory.fromJson(category));
          });
          _logoUrl = categories["logoURL"];
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
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            IconButton(
              icon: Container(
                padding: EdgeInsets.all(5),
                child: Image(
                  image: AssetImage(
                    '${assetsPath}history.png',
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
        ),
        body: _categories.isNotEmpty
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
                                child: IndigoSearchWidget(
                                  searchController: _searchController,
                                  onChangeCallback: (value) {
                                    searchOnChanged();
                                  },
                                  callback: () {
                                    if (_searchController.text.isNotEmpty)
                                      search(_searchController.text);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        needToShowServices
                            ? Flexible(
                                child: ListView.builder(
                                  padding: EdgeInsets.only(bottom: 20),
                                  shrinkWrap: true,
                                  itemCount:
                                      _services != null ? _services.length : 0,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: _servicesList(
                                        context,
                                        _logoUrl + _services[index]['logo'],
                                        _services[index]['title'],
                                        _services[index]['id'],
                                        _services[index]['is_convertable'],
                                        _services[index]['location_type'],
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Flexible(
                                child: ListView.builder(
                                  padding: EdgeInsets.only(bottom: 20),
                                  shrinkWrap: true,
                                  itemCount: _categories != null
                                      ? _categories.length
                                      : 0,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    PaymentCategory category =
                                        _categories[index];
                                    String title = category.title;
                                    String categoryLogo =
                                        _logoUrl + category.logo;
                                    dynamic categoryId = category.id;
                                    dynamic locationType =
                                        category.locationType;

                                    return Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: ServiceWidget(
                                        title: title,
                                        logo: categoryLogo,
                                        onPressed: () {
                                          if (locationType != null) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PaymentsRegion(
                                                  categoryId: categoryId,
                                                  locationType: locationType,
                                                ),
                                              ),
                                            );
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PaymentsServices(
                                                  categoryId,
                                                  title,
                                                ),
                                              ),
                                            );
                                          }
                                        },
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
          _services = result;
        });
      });
      setState(() {
        isReadyToSend = true;
      });
    }
  }

  Widget _servicesList(BuildContext context, String logo, String name,
      int index, int isConvertable, locationType) {
    return ServiceWidget(
      title: name,
      logo: logo,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentsServicePage(
              index,
              logo,
              name,
              isConvertable: isConvertable,
              providerId: null,
            ),
          ),
        );
      },
    );
  }
}
