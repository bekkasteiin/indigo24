import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:indigo24/services/localization/localization.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_appbar_widget.dart';

class SettingsCachePage extends StatefulWidget {
  @override
  _SettingsCachePageState createState() => _SettingsCachePageState();
}

class _SettingsCachePageState extends State<SettingsCachePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IndigoAppBarWidget(
        title: Text(
          Localization.language.sound,
          style: TextStyle(
            color: blackPurpleColor,
            fontWeight: FontWeight.w400,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                color: whiteColor,
                child: Column(
                  children: <Widget>[
                    FlatButton(
                      onPressed: () async {
                        await DefaultCacheManager().emptyCache();
                      },
                      child: Text("CLEAR"),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
