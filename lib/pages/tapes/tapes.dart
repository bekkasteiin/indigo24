import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:indigo24/chat/ui/new_chat/chat_pages/chat_info.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/pages/tapes/add_tape.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/alerts.dart';
import 'package:indigo24/widgets/indigo_appbar_widget.dart';
import 'package:indigo24/widgets/video/flick_multi_manager.dart';
import 'package:indigo24/widgets/video/flick_multi_player.dart';
import 'package:photo_view/photo_view.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:video_player/video_player.dart';
import 'package:indigo24/db/tapes_helper.dart';

import 'tape.dart';

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
  ChewieController _chewieController;
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
    _chewieController.dispose();
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          description: "$message",
          yesCallBack: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }

  _moreActions({dynamic data}) {
    final act = CupertinoActionSheet(
        title: Text('${localization.selectOption}'),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text('${localization.report}'),
            onPressed: () {
              Navigator.pop(context);
              showAlertDialog(context, "Your complaint is being processed");
            },
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            child: Text('${localization.hide}'),
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
              showAlertDialog(context, "${data['title']} ${localization.hide}");
            },
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            child: Text('${localization.block}'),
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
                  context, "${data['title']} ${localization.block}");
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text('${localization.back}'),
          onPressed: () {
            Navigator.pop(context);
          },
        ));
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => act,
    );
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: IndigoAppBarWidget(
          leading: SizedBox(
            height: 0,
            width: 0,
          ),
          title: Text(
            localization.tape,
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
                    'assets/images/newPost.png',
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
          color: Colors.white,
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
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              18),
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
                  ? '${localization.less}'
                  : '${localization.more}',
              style: TextStyle(
                fontSize: 16,
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

class TapeContent extends StatelessWidget {
  const TapeContent({
    Key key,
    @required Map<String, dynamic> result,
    @required FlickMultiManager flickMultiManager,
  })  : _result = result,
        _flickMultiManager = flickMultiManager,
        super(key: key);

  final Map<String, dynamic> _result;
  final FlickMultiManager _flickMultiManager;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width,
      child: Center(
        child: (_result['media'].toString().endsWith("MOV") ||
                _result['media'].toString().endsWith("mov") ||
                _result['media'].toString().endsWith("mp4") ||
                _result['media'].toString().endsWith("mpeg") ||
                _result['media'].toString().endsWith("avi"))
            ? TapeVideo(result: _result, flickMultiManager: _flickMultiManager)
            : TapePhoto(result: _result),
      ),
    );
  }
}

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

class TapePhoto extends StatelessWidget {
  const TapePhoto({
    Key key,
    @required Map<String, dynamic> result,
  })  : _result = result,
        super(key: key);

  final Map<String, dynamic> _result;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1 / 1,
      child: ClipRect(
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(
            '$uploadTapes${_result['media']}',
          ),
          backgroundDecoration: BoxDecoration(color: Colors.transparent),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.contained,
          enableRotation: false,
        ),
      ),
    );
  }
}

class TapeVideo extends StatelessWidget {
  const TapeVideo({
    Key key,
    @required Map<String, dynamic> result,
    @required FlickMultiManager flickMultiManager,
  })  : _result = result,
        _flickMultiManager = flickMultiManager,
        super(key: key);

  final Map<String, dynamic> _result;
  final FlickMultiManager _flickMultiManager;

  @override
  Widget build(BuildContext context) {
    return new FlickMultiPlayer(
      url: "$uploadTapes${_result['media']}",
      flickMultiManager: _flickMultiManager,
      image: _result['frame'] != null
          ? _result['frame']
          : '${avatarUrl}noAvatar.png',
    );
  }
}
