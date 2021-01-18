import 'package:flutter/material.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/helpers/contacts.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_appbar_widget.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/localization/localization.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_search_widget.dart';

class TransferContacts extends StatefulWidget {
  @override
  TransferContactsState createState() => TransferContactsState();
}

class TransferContactsState extends State<TransferContacts> {
  TextEditingController _searchController = TextEditingController();

  List actualList = List<dynamic>();

  search(String query) {
    if (query.isNotEmpty) {
      setState(() {
        actualList.clear();
        actualList.addAll(IndigoContacts.search(query));
      });
      return;
    } else {
      setState(() {
        actualList.clear();
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
              '${Localization.language.contacts}',
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
                    top: 10.0,
                    left: 10.0,
                    right: 10,
                    bottom: 0,
                  ),
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
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: blackPurpleColor,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          '${actualList[i].phone}',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: blackPurpleColor,
                                          ),
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
