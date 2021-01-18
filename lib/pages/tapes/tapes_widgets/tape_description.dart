import 'package:flutter/material.dart';
import 'package:indigo24/services/localization/localization.dart';
import 'package:indigo24/style/colors.dart';

class TapeDescription extends StatefulWidget {
  const TapeDescription({
    Key key,
    @required Map<String, dynamic> result,
  })  : _result = result,
        super(key: key);

  final Map<String, dynamic> _result;

  @override
  _TapeDescriptionState createState() => _TapeDescriptionState();
}

class _TapeDescriptionState extends State<TapeDescription> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10.0, right: 10),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Text(
              '${widget._result['description']}',
              style: TextStyle(
                fontSize: 16,
                color: blackPurpleColor,
              ),
              maxLines: widget._result['maxLines'],
            ),
          ),
        ),
        moreLessAction(widget._result)
      ],
    );
  }

  Widget moreLessAction(Map<String, dynamic> _result) {
    return LayoutBuilder(builder: (context, size) {
      final span = TextSpan(
        text: _result['description'],
        style: TextStyle(
          fontSize: 16,
        ),
      );
      final tp = TextPainter(
          text: span, maxLines: 3, textDirection: TextDirection.ltr);
      tp.layout(maxWidth: size.maxWidth);
      if (tp.didExceedMaxLines) {
        return Padding(
          padding: EdgeInsets.only(left: 10.0, right: 10),
          child: GestureDetector(
            child: Text(
              _result['maxLines'] == null
                  ? '${Localization.language.less}'
                  : '${Localization.language.more}',
              style: TextStyle(
                fontSize: 16,
                color: blackPurpleColor,
              ),
            ),
            onTap: () {
              setState(() {
                if (_result['maxLines'] == null) {
                  _result['maxLines'] = 3;
                } else {
                  _result['maxLines'] = null;
                }
              });
            },
          ),
        );
      } else {
        return SizedBox(height: 0, width: 0);
      }
    });
  }
}
