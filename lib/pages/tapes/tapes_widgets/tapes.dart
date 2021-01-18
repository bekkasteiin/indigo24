import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:indigo24/pages/chat/chat_pages/chat_info.dart';
import 'package:indigo24/services/db/tapes/tape_model.dart';
import 'package:indigo24/widgets/alerts/indigo_logout.dart';
import 'package:indigo24/pages/tapes/add_tape.dart';
import 'package:indigo24/services/api/http/api.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/alerts/indigo_alert.dart';
import 'package:indigo24/widgets/alerts/indigo_show_dialog.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_appbar_widget.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_modal_action_widget.dart';
import 'package:indigo24/widgets/video/flick_multi_manager.dart';
import 'package:indigo24/services/localization/localization.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:video_player/video_player.dart';
import 'package:indigo24/services/db/tapes/tape_repo.dart';
import 'tape_content.dart';
import 'tape_description.dart';
import 'tape_devider.dart';
import 'tape_social.dart';

class TapesPage extends StatefulWidget {
  @override
  _TapesPageState createState() => _TapesPageState();
}

class _TapesPageState extends State<TapesPage>
    with AutomaticKeepAliveClientMixin {
  Future<int> _listFuture;
  Api _api = Api();
  List _result;
  int _tapePage = 1;
  FlickMultiManager _flickMultiManager;

  TapeDB _tapeDb = TapeDB();
  VideoPlayerController _videoPlayerController;
  var _tapesDatabaseData = [];

  _getTapeFromDb() async {
    _tapesDatabaseData = await _tapeDb.getAll();
  }

  @override
  void initState() {
    _getTapeFromDb();
    _getTapes();
    super.initState();
  }

  _rebuildTape() {
    setState(() {
      _flickMultiManager = FlickMultiManager();
    });

    _api.getTapes('1').then((tapes) {
      if (tapes['message'] == 'Not authenticated' &&
          tapes['success'].toString() == 'false') {
        logOut(context);
        return true;
      } else {
        return _rebuild(tapes);
      }
    });
  }

  _getTapes() {
    setState(() {
      _flickMultiManager = FlickMultiManager();
    });
    _api.getTapes('$_tapePage').then((tapes) async {
      if (tapes['message'] == 'Not authenticated' &&
          tapes['success'].toString() == 'false') {
        logOut(context);
        return true;
      } else {
        return _setTapes(tapes);
      }
    });
  }

  Future _rebuild(tapes) async {
    setState(() {
      _tapePage = 2;
      _result = tapes["result"].toList();
      _listFuture = Future(foo);
      _result.forEach((el) async {
        el['maxLines'] = 3;
        if (el['myLike'] == true) {}
      });
    });
  }

  Future _setTapes(tapes) async {
    if (_tapePage == 1)
      setState(() {
        _result = tapes["result"].toList();
        _listFuture = Future(foo);
        _result.forEach((el) async {
          el['maxLines'] = 3;
          if (el['myLike'] == true) {}
        });
      });
    else
      setState(() {
        _result.addAll(tapes["result"].toList());
        _result.forEach((el) async {
          el['maxLines'] = 3;
          if (el['myLike'] == true) {}
        });
      });
  }

  void _onLoading() async {
    _tapePage++;
    _getTapes();
    // if(mounted)
    _refreshController.loadComplete();
  }

  int foo() {
    return 1;
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _flickMultiManager.dispose();
  }

  void _onRefresh() {
    _rebuildTape();
    _refreshController.refreshCompleted();
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  showAlertDialog(BuildContext context, String message) {
    showIndigoDialog(
      context: context,
      builder: CustomDialog(
        description: "$message",
        yesCallBack: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  _moreActions({dynamic data}) {
    showIndigoBottomDialog(
      context: context,
      children: [
        IndigoModalActionWidget(
          onPressed: () {
            Navigator.pop(context);
            showAlertDialog(context, "Your complaint is being processed");
          },
          title: Localization.language.report,
          isDefault: false,
        ),
        IndigoModalActionWidget(
          onPressed: () async {
            Navigator.pop(context);
            MyTape tape = MyTape(
              id: data['id'],
            );
            await _tapeDb.updateOrInsert(tape);
            _tapesDatabaseData = await _tapeDb.getAll();
            setState(() {
              _tapesDatabaseData = _tapesDatabaseData;
            });
            showAlertDialog(
                context, "${data['title']} ${Localization.language.hide}");
          },
          title: Localization.language.hide,
        ),
        IndigoModalActionWidget(
          onPressed: () async {
            Navigator.pop(context);
            MyTape tape = MyTape(
              id: data['id'],
              isBlocked: true,
            );

            await _tapeDb.updateOrInsert(tape);
            _api.blockUser(data['customerId']);
            _tapesDatabaseData = await _tapeDb.getAll();
            setState(() {
              _tapesDatabaseData = _tapesDatabaseData;
            });
            showAlertDialog(
                context, "${data['title']} ${Localization.language.block}");
          },
          title: Localization.language.block,
          isDefault: false,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: IndigoAppBarWidget(
          leading: SizedBox(
            height: 0,
            width: 0,
          ),
          title: Text(
            Localization.language.tape,
            style: TextStyle(
              color: blackPurpleColor,
              fontSize: 22,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            IconButton(
              icon: Container(
                height: 20,
                width: 20,
                child: Image(
                  image: AssetImage(
                    '${assetsPath}newPost.png',
                  ),
                ),
              ),
              onPressed: () async {
                final response = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTapePage(),
                  ),
                );
                if (response != null) {
                  setState(() {
                    _result.insert(0, response);
                    _flickMultiManager = new FlickMultiManager();
                  });
                }
              },
            )
          ],
        ),
        body: Container(
          color: whiteColor,
          child: SafeArea(
            child: FutureBuilder(
              future: _listFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData == true)
                  return SmartRefresher(
                    enablePullDown: true,
                    enablePullUp: true,
                    footer: CustomFooter(
                      builder: (BuildContext context, LoadStatus mode) {
                        Widget body;
                        return Container(
                          height: 55.0,
                          child: Center(child: body),
                        );
                      },
                    ),
                    controller: _refreshController,
                    onRefresh: _onRefresh,
                    onLoading: _onLoading,
                    child: ListView.separated(
                      separatorBuilder: (context, int) => Container(
                        height: 0,
                      ),
                      reverse: false,
                      itemCount: _result.length,
                      itemBuilder: (BuildContext context, int index) {
                        bool needToHide = false;
                        bool needToBlock = false;
                        _tapesDatabaseData.forEach((element) {
                          if ('${element.toJson()['id']}' ==
                              '${_result[index]['id']}') {
                            needToHide = true;
                          }
                          if ('${element.toJson()['id']}' ==
                                  '${_result[index]['id']}' &&
                              '${element.toJson()['isBlocked']}' == 'true') {
                            needToHide = false;
                            needToBlock = true;
                          }
                        });
                        return needToHide
                            ? Container()
                            : needToBlock
                                ? Container(
                                    padding: EdgeInsets.only(
                                      left: 10.0,
                                      top: 10,
                                      bottom: 10,
                                    ),
                                    child: Text(
                                      'Blocked content by ${_result[index]['name']}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  )
                                : VisibilityDetector(
                                    key: ObjectKey(_flickMultiManager),
                                    onVisibilityChanged: (visibility) {
                                      if (visibility.visibleFraction == 0 &&
                                          this.mounted) {
                                        _flickMultiManager.pause();
                                      }
                                    },
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          child: Container(
                                            color: milkWhiteColor,
                                            padding: EdgeInsets.only(
                                              top: 10,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 10.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Flexible(
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: <Widget>[
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            ChatProfileInfo(
                                                                      chatType:
                                                                          0,
                                                                      chatName:
                                                                          _result[index]
                                                                              [
                                                                              'name'],
                                                                      chatAvatar:
                                                                          _result[index]
                                                                              [
                                                                              'avatar'],
                                                                      userId: _result[
                                                                              index]
                                                                          [
                                                                          'customerID'],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                  25.0,
                                                                ),
                                                                child: Image
                                                                    .network(
                                                                  '$avatarUrl${_result[index]['avatar'].toString().replaceAll("AxB", "200x200")}',
                                                                  width: 35,
                                                                  height: 35,
                                                                ),
                                                              ),
                                                            ),
                                                            Flexible(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Container(
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                            left:
                                                                                10.0),
                                                                    child: Text(
                                                                      '${_result[index]['name']}',
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        color:
                                                                            blackPurpleColor,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                            left:
                                                                                10.0),
                                                                    child: Text(
                                                                      '${_result[index]['title']}',
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: Icon(
                                                            Icons.more_vert),
                                                        onPressed: () {
                                                          _moreActions(
                                                              data: _result[
                                                                  index]);
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                TapeContent(
                                                    result: _result[index],
                                                    flickMultiManager:
                                                        _flickMultiManager),
                                                TapeSocial(
                                                  result: _result[index],
                                                  api: _api,
                                                ),
                                                TapeDescription(
                                                    result: _result[index]),
                                                TapeDevider(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                      },
                    ),
                  );
                else
                  return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
