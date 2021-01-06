import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/style/colors.dart';

class ForwardMessageWidget extends StatefulWidget {
  final text;
  final Widget child;

  const ForwardMessageWidget({Key key, this.text, this.child})
      : super(key: key);
  @override
  _ForwardMessageWidgetState createState() => _ForwardMessageWidgetState();
}

class _ForwardMessageWidgetState extends State<ForwardMessageWidget> {
  String time;
  @override
  void initState() {
    time = DateTime.fromMillisecondsSinceEpoch(
      int.parse(widget.text.time.toString()) * 1000,
    ).toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width * 0.2,
        maxWidth: MediaQuery.of(context).size.width * 0.8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 30,
                height: 30,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25.0),
                  child: CachedNetworkImage(
                    errorWidget: (context, url, error) => Image.network(
                      '${avatarUrl}noAvatar.png',
                    ),
                    imageUrl: avatarUrl +
                        widget.text.avatar.replaceAll('AxB', '200x200'),
                  ),
                ),
              ),
              SizedBox(width: 5),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.text.username}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: blackPurpleColor,
                    ),
                  ),
                  Text(
                    '${time.substring(0, time.length - 7)}',
                    style: TextStyle(
                      color: greyColor2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
