import 'package:flutter/material.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'indigo_bottom_tab.dart';

class IndigoBottomNav extends StatelessWidget {
  const IndigoBottomNav({
    Key key,
    @required TabController tabController,
  })  : _tabController = tabController,
        super(key: key);

  final TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 55,
        child: TabBar(
          indicatorPadding: EdgeInsets.all(1),
          labelPadding: EdgeInsets.all(0),
          indicatorWeight: 0.0000000000001,
          controller: _tabController,
          unselectedLabelColor: blackPurpleColor,
          labelColor: primaryColor,
          tabs: [
            IndigoBottomTab(
              path: "assets/images/chat.png",
              text: localization.chat,
            ),
            IndigoBottomTab(
              path: "assets/images/profile.png",
              text: localization.profile,
            ),
            IndigoBottomTab(
              path: "assets/images/tape.png",
              text: localization.tape,
            ),
            IndigoBottomTab(
              path: "assets/images/wallet.png",
              text: localization.wallet,
            ),
          ],
        ),
      ),
    );
  }
}