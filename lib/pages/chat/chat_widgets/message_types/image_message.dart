import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/widgets/photo/full_photo.dart';
import 'package:indigo24/style/colors.dart';

class ImageMessageWidget extends StatefulWidget {
  final String text;
  final String media;

  const ImageMessageWidget({
    Key key,
    this.text,
    @required this.media,
  }) : super(key: key);
  @override
  _ImageMessageWidgetState createState() => _ImageMessageWidgetState();
}

class _ImageMessageWidgetState extends State<ImageMessageWidget> {
  Widget placeholder(context) {
    return Container(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.width * 0.7,
        color: greyColor.withOpacity(0.5),
      ),
      width: MediaQuery.of(context).size.width * 0.7,
      height: MediaQuery.of(context).size.width * 0.7,
      decoration: BoxDecoration(
        color: transparentColor,
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FlatButton(
            splashColor: transparentColor,
            hoverColor: transparentColor,
            highlightColor: transparentColor,
            child: Material(
              color: transparentColor,
              child: CachedNetworkImage(
                placeholder: (context, url) => placeholder(context),
                errorWidget: (context, url, error) => Material(
                  child: Image.network(
                    '${avatarUrl}noAvatar.png',
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.width * 0.7,
                    fit: BoxFit.contain,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                ),
                imageUrl: '$imageUrl' + '${widget.media}',
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.width * 0.7,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              clipBehavior: Clip.hardEdge,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullPhoto(url: imageUrl + widget.media),
                ),
              );
            },
            padding: EdgeInsets.all(0),
          ),
          widget.text != 'null' ? Text('${widget.text}') : Center(),
        ],
      ),
    );
  }
}
