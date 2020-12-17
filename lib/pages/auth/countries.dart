import 'package:flutter/material.dart';
import 'package:indigo24/db/country_model.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/widgets/indigo_ui_kit/indigo_appbar_widget.dart';

class Countries extends StatelessWidget {
  final List<Country> countries;

  Countries(this.countries);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IndigoAppBarWidget(
        title: Text(
          "${localization.country}",
          style: TextStyle(
            color: blackPurpleColor,
            fontWeight: FontWeight.w400,
            fontSize: 22,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: ListView.separated(
            itemCount: countries.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                child: Container(
                  height: 20,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  padding: EdgeInsets.only(left: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '${countries[index].code}'.toUpperCase(),
                        style: TextStyle(
                          color: blackPurpleColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '+${countries[index].phonePrefix}',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: blackPurpleColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop(countries[index]);
                },
              );
            },
            separatorBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(left: 20),
                height: 0.2,
                color: blackColor,
              );
            },
          ),
        ),
      ),
    );
  }
}
