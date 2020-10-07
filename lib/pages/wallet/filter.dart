import 'package:flutter/material.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/indigo_appbar_widget.dart';

class HistoryFiletPage extends StatefulWidget {
  @override
  _HistoryFiletPageState createState() => _HistoryFiletPageState();
}

class _HistoryFiletPageState extends State<HistoryFiletPage> {
  int _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IndigoAppBarWidget(
        title: Text(
          "${localization.filter}",
          style: TextStyle(
            color: blackPurpleColor,
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(16),
            child: Text('${localization.showOperations}'),
          ),
          Flexible(
            child: ListView.separated(
              itemCount: localization.filters.length,
              itemBuilder: (BuildContext context, int index) {
                if (index == localization.filters.length - 1)
                  return Center(
                    child: _acceptButton(),
                  );
                return Container(
                  color: whiteColor,
                  child: ListTile(
                    title: Text(localization.filters[index]['text']),
                    selected: _selectedIndex == index,
                    trailing: Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: blackPurpleColor),
                        borderRadius: BorderRadius.circular(20),
                        color: whiteColor,
                      ),
                      child: _selectedIndex == index
                          ? Container(
                              margin: EdgeInsets.all(4),
                              height: 5,
                              width: 5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: primaryColor,
                              ),
                            )
                          : Center(),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) => Container(
                height: 1,
                color: blackPurpleColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _acceptButton() {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 20),
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
          onPressed: () async {
            String code = localization.filters[_selectedIndex]['code'];
            DateTime date = DateTime.now();
            var nowSplit = date.toString().split(' ');
            String nowFirst = nowSplit.first;

            DateTime prevValue;
            // print(date.)
            switch (code) {
              case 'week':
                prevValue = date.subtract(Duration(days: 7));
                print(prevValue);
                break;
              case 'month':
                prevValue = DateTime(date.year, date.month - 1, date.day);
                break;
              case 'threeMonth':
                prevValue = DateTime(date.year, date.month - 3, date.day);
                break;
              case 'halfYear':
                prevValue = DateTime(date.year, date.month - 6, date.day);
                break;
              default:
            }
            var split = prevValue.toString().split(' ');
            String fisrt = split.first;
            List result = [
              fisrt,
              nowFirst,
            ];
            Navigator.pop(context, result);
          },
          child: Container(
            height: 50,
            width: 200,
            child: Center(
              child: Text(
                '${localization.accept}',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
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
