import 'package:flutter/material.dart';

class TapeDevider extends StatelessWidget {
  const TapeDevider({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(bottom: 10.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 10.0, top: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
