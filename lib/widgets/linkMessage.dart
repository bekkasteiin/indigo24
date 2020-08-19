import 'package:flutter/material.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkMessage extends StatefulWidget {
  final url;
  LinkMessage(this.url);

  @override
  _LinkMessageState createState() => _LinkMessageState();
}

class _LinkMessageState extends State<LinkMessage> {
  var data;
  var json;

  @override
  void initState() {
    super.initState();
    data = extract(widget.url);
    // dataAsMap = data.toMap();
    data.then((val) {
      setState(() {
        json = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      // height: MediaQuery.of(context).size.width*0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: () async {
                  if (await canLaunch('${widget.url}')) {
                    await launch(
                      '${widget.url}',
                      forceSafariVC: false,
                      forceWebView: false,
                      headers: <String, String>{
                        'my_header_key': 'my_header_value'
                      },
                    );
                  } else {
                    throw 'Could not launch ${widget.url}';
                  }
                },
                child: Ink(
                  child: Container(
                    child: Text("${widget.url}",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                        )),
                  ),
                )),
          ),
          json != null
              ? Text(json.title != null ? json.title : "",
                  style: TextStyle(fontWeight: FontWeight.bold))
              : Container(),
          json != null
              ? Text(
                  json.description != null ? json.description : "",
                  style: TextStyle(fontWeight: FontWeight.normal),
                  maxLines: 4,
                )
              : Container(),
        ],
      ),
    );
  }
}
