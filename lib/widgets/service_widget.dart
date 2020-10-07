import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/style/colors.dart';

class ServiceWidget extends StatelessWidget {
  final String logo;
  final String title;
  final Function onPressed;

  const ServiceWidget({
    Key key,
    this.logo,
    @required this.title,
    @required this.onPressed,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 10),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            spreadRadius: -2,
            offset: Offset(
              0.0,
              0.0,
            ),
          )
        ],
      ),
      child: ButtonTheme(
        height: 40,
        child: RaisedButton(
          onPressed: () {
            onPressed();
          },
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 35,
                  height: 40,
                  margin: EdgeInsets.only(right: 20, top: 10, bottom: 10),
                  child: logo != null
                      ? CachedNetworkImage(
                          imageUrl: logo,
                        )
                      : SizedBox(
                          height: 0,
                          width: 0,
                        ),
                ),
                Container(width: 10),
                Expanded(
                  child: Text(
                    title,
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
