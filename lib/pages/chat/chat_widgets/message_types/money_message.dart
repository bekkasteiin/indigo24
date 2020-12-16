import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/style/colors.dart';

class MoneyMessageWidget extends StatefulWidget {
  final String amount;
  final moneyData;
  final int category;
  const MoneyMessageWidget(
      {Key key, @required this.amount, @required this.category, this.moneyData})
      : super(key: key);
  @override
  _MoneyMessageWidgetState createState() => _MoneyMessageWidgetState();
}

class _MoneyMessageWidgetState extends State<MoneyMessageWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 30.0,
                height: 30.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: greyColor,
                ),
                child: widget.moneyData == null
                    ? ClipOval(
                        child: CachedNetworkImage(
                            imageUrl: '$avatarUrl' + 'noAvatar.png'),
                      )
                    : ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: '$avatarUrl${widget.moneyData['avatar']}'
                              .replaceAll('AxB', '200x200'),
                        ),
                      ),
              ),
              SizedBox(width: 5),
              Flexible(
                child: Text(
                  widget.moneyData == null ? "" : "${widget.moneyData['name']}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 5),
          Flexible(
            child: Text(
              '${widget.amount} KZT',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          )
        ],
      ),
    );
  }
}
