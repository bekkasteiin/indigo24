import 'package:flutter/material.dart';
import 'package:indigo24/services/api/http/api.dart';

import '../tape.dart';

class TapeSocial extends StatefulWidget {
  const TapeSocial({
    Key key,
    @required Map<String, dynamic> result,
    @required Api api,
  })  : _result = result,
        _api = api,
        super(key: key);

  final Map<String, dynamic> _result;
  final Api _api;

  @override
  _TapeSocialState createState() => _TapeSocialState();
}

class _TapeSocialState extends State<TapeSocial> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: Container(
            width: 35,
            height: 35,
            child: Image(
              image: AssetImage(
                widget._result['myLike']
                    ? 'assets/images/tapeLiked.png'
                    : 'assets/images/tapeUnliked.png',
              ),
            ),
          ),
          onPressed: () async {
            await widget._api.likeTape('${widget._result['id']}').then((value) {
              setState(() {
                widget._result['myLike'] = value['result']['myLike'];
                widget._result['likesCount'] = value['result']['likesCount'];
              });
            });
          },
        ),
        Container(
          width: 30,
          child: Text(
            '${widget._result['likesCount']}',
          ),
        ),
        IconButton(
          icon: Container(
            width: 35,
            height: 35,
            child: Image(
              image: AssetImage(
                'assets/images/tapeComment.png',
              ),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TapePage(widget._result),
              ),
            ).whenComplete(() {});
          },
        ),
        '${widget._result['commentsCount']}' == '0'
            ? SizedBox(height: 0, width: 0)
            : Container(
                width: 30,
                child: Text(
                  '${widget._result['commentsCount']}',
                ),
              ),
        Expanded(
          child: Text(''),
        ),
        Padding(
          padding: EdgeInsets.only(right: 10.0),
          child: Text(
            '${widget._result['created'].toString().replaceAll(".2020", "")}',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
