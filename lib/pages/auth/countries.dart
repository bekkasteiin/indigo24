import 'package:flutter/material.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/services/localization.dart' as localization;

class Countries extends StatelessWidget {
  final countries;
  Countries(this.countries);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          "${localization.country}",
          style: TextStyle(
            color: blackPurpleColor,
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.white,
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
                  child: Text(
                    '${countries[index].title}',
                    style: TextStyle(
                      color: blackPurpleColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                    ),
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
                color: Colors.black,
              );
            },
          ),
        ),
      ),
    );
  }
}
