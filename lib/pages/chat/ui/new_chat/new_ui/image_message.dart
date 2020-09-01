import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/widgets/full_photo.dart';

class ImageMessageWidget extends StatefulWidget {
  final String text;
  final String url;
  final String media;

  const ImageMessageWidget({
    Key key,
    this.text,
    @required this.url,
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
        color: Colors.grey.withOpacity(0.5),
      ),
      width: MediaQuery.of(context).size.width * 0.7,
      height: MediaQuery.of(context).size.width * 0.7,
      decoration: BoxDecoration(
        color: Colors.transparent,
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
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Material(
              color: Colors.transparent,
              child: CachedNetworkImage(
                placeholder: (context, url) => placeholder(context),
                errorWidget: (context, url, error) => Material(
                  child: Image.asset(
                    'assets/preloader.gif',
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.width * 0.7,
                    fit: BoxFit.contain,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                ),
                imageUrl: widget.url + widget.media,
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
                  builder: (context) => FullPhoto(url: widget.url),
                ),
              );
            },
            padding: EdgeInsets.all(0),
          ),
          widget.text != null ? Text('${widget.text}') : Center(),
        ],
      ),
    );
  }
}
