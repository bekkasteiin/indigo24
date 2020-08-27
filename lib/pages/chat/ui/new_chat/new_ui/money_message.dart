import 'package:flutter/material.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/style/colors.dart';

class MoneyMessageWidget extends StatefulWidget {
  final String amount;
  final String username;
  final String userAvatar;
  final int category;
  const MoneyMessageWidget({
    Key key,
    @required this.amount,
    @required this.username,
    @required this.category,
    @required this.userAvatar,
  }) : super(key: key);
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
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage('$avatarUrl${widget.userAvatar}'),
                  ),
                ),
              ),
              SizedBox(width: 5),
              Flexible(
                child: Text(
                  "${widget.username}",
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
              (widget.category == 0 ? '-' : '+') + '${widget.amount} KZT',
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
