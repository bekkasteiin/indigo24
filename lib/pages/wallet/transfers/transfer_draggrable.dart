import 'package:flutter/material.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_appbar_widget.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/widgets/indigo_ui_kit/indigo_search_widget.dart';
import 'package:indigo24/pages/tabs/tabs.dart';

class TransferContactsDialogPage extends StatefulWidget {
  @override
  TransferContactsDialogPageState createState() =>
      TransferContactsDialogPageState();
}

class TransferContactsDialogPageState
    extends State<TransferContactsDialogPage> {
  TextEditingController _searchController = TextEditingController();

  List actualList = List<dynamic>();

  search(String query) {
    if (query.isNotEmpty) {
      List<dynamic> matches = List<dynamic>();
      myContacts.forEach((item) {
        if (item.name != null && item.phone != null) {
          if (item.name
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              item.phone
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase())) {
            matches.add(item);
          }
        }
      });
      setState(() {
        actualList = [];
        actualList.addAll(matches);
      });
      return;
    } else {
      setState(() {
        actualList = [];
        actualList.addAll(myContacts);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    actualList.addAll(myContacts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: whiteColor,
      child: SafeArea(
        child: Scaffold(
          appBar: IndigoAppBarWidget(
            title: Text(
              '${localization.contacts}',
              style: TextStyle(
                color: blackPurpleColor,
                fontWeight: FontWeight.w400,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      top: 10.0, left: 10.0, right: 10, bottom: 0),
                  child: IndigoSearchWidget(
                    callback: null,
                    searchController: _searchController,
                    onChangeCallback: (value) {
                      search(value);
                    },
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    itemCount: actualList != null ? actualList.length : 0,
                    shrinkWrap: true,
                    itemBuilder: (context, i) {
                      if (actualList[i].phone == null ||
                          actualList[i].id == user.id)
                        return SizedBox(
                          height: 0,
                          width: 0,
                        );
                      return Center(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context, actualList[i]);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 20,
                            ),
                            child: Row(
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(25.0),
                                  child: Image.network(
                                    '${actualList[i].avatar}' == ''
                                        ? '${avatarUrl}noAvatar.png'
                                        : '$avatarUrl${actualList[i].avatar.replaceAll('AxB', '200x200')}',
                                    width: 35,
                                    height: 35,
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Container(
                                        child: Text(
                                          '${actualList[i].name}',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          '${actualList[i].phone}',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
