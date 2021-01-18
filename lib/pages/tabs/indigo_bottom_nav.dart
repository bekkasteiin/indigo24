import 'package:flutter/material.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/services/localization/localization.dart';
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
        decoration: BoxDecoration(
          color: whiteColor,
        ),
        child: TabBar(
          indicatorPadding: EdgeInsets.all(1),
          labelPadding: EdgeInsets.all(0),
          indicatorWeight: 0.0000000000001,
          controller: _tabController,
          unselectedLabelColor: blackPurpleColor,
          labelColor: primaryColor,
          tabs: [
            IndigoBottomTab(
              path: "${assetsPath}chat.png",
              text: Localization.language.chat,
            ),
            IndigoBottomTab(
              path: "${assetsPath}profile.png",
              text: Localization.language.profile,
            ),
            IndigoBottomTab(
              path: "${assetsPath}tape.png",
              text: Localization.language.tape,
            ),
            IndigoBottomTab(
              path: "${assetsPath}wallet.png",
              text: Localization.language.wallet,
            ),
          ],
        ),
      ),
    );
  }
}
