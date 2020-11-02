import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
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

  var _likeResult;

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
        if (el['myLike'] == true) {
          _saved.add(el['id']);
        }
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
          if (el['myLike'] == true) {
            _saved.add(el['id']);
          }
        });
      });
    else
      setState(() {
        _result.addAll(tapes["result"].toList());
        _result.forEach((el) async {
          el['maxLines'] = 3;
          if (el['myLike'] == true) {
            _saved.add(el['id']);
          }
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

  final Set _saved = Set();

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
        // message: Text('Which option?'),
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
                    header: WaterDropHeader(),
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
                            : VisibilityDetector(
                                key: ObjectKey(_flickMultiManager),
                                onVisibilityChanged: (visibility) {
                                  if (visibility.visibleFraction == 0 &&
                                      this.mounted) {
                                    _flickMultiManager.pause();
                                  }
                                },
                                child: Container(
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
                                                padding:
                                                    EdgeInsets.only(left: 10.0),
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
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        25.0),
                                                            child:
                                                                Image.network(
                                                              needToHide
                                                                  ? '${avatarUrl}noAvatar.png'
                                                                  : needToBlock
                                                                      ? '${avatarUrl}noAvatar.png'
                                                                      : '$avatarUrl${_result[index]['avatar'].toString().replaceAll("AxB", "200x200")}',
                                                              width: 35,
                                                              height: 35,
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
                                                                    needToHide
                                                                        ? 'Hided content by ${_result[index]['name']}'
                                                                        : needToBlock
                                                                            ? 'Blocked content by ${_result[index]['name']}'
                                                                            : '${_result[index]['name']}',
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18),
                                                                  ),
                                                                ),
                                                                needToHide
                                                                    ? Center()
                                                                    : needToBlock
                                                                        ? Center()
                                                                        : Container(
                                                                            padding:
                                                                                EdgeInsets.only(left: 10.0),
                                                                            child:
                                                                                Text(
                                                                              '${_result[index]['title']}',
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    needToHide
                                                        ? Center()
                                                        : needToBlock
                                                            ? Center()
                                                            : IconButton(
                                                                icon: Icon(Icons
                                                                    .more_vert),
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
                                              needToHide
                                                  ? Center()
                                                  : needToBlock
                                                      ? Center()
                                                      : GestureDetector(
                                                          onDoubleTap:
                                                              () async {
                                                            await _api
                                                                .likeTape(
                                                                    '${_result[index]['id']}')
                                                                .then((value) {
                                                              _likeResult =
                                                                  value;
                                                            });
                                                            setState(() {
                                                              if (_likeResult[
                                                                      'result']
                                                                  ['myLike']) {
                                                                _saved.add(
                                                                    _result[index]
                                                                        ['id']);
                                                                _result[index][
                                                                    'likesCount'] += 1;
                                                                final snackBar =
                                                                    SnackBar(
                                                                  elevation:
                                                                      200,
                                                                  duration:
                                                                      Duration(
                                                                          seconds:
                                                                              2),
                                                                  content: Text(
                                                                    'Вы лайнули пост ${_result[index]['title']} от ${_result[index]['name']}',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                  ),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .blue,
                                                                );
                                                                Scaffold.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                        snackBar);
                                                              } else {
                                                                _saved.remove(
                                                                    _result[index]
                                                                        ['id']);
                                                                _result[index][
                                                                    'likesCount'] -= 1;
                                                              }
                                                            });
                                                          },
                                                          child: Container(
                                                            height:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            child: Center(
                                                              child: (_result[index]['media'].toString().endsWith("MOV") ||
                                                                      _result[index]
                                                                              [
                                                                              'media']
                                                                          .toString()
                                                                          .endsWith(
                                                                              "mov") ||
                                                                      _result[index]
                                                                              [
                                                                              'media']
                                                                          .toString()
                                                                          .endsWith(
                                                                              "mp4") ||
                                                                      _result[index]
                                                                              [
                                                                              'media']
                                                                          .toString()
                                                                          .endsWith(
                                                                              "mpeg") ||
                                                                      _result[index]
                                                                              [
                                                                              'media']
                                                                          .toString()
                                                                          .endsWith(
                                                                              "avi"))
                                                                  ? new FlickMultiPlayer(
                                                                      url:
                                                                          "$uploadTapes${_result[index]['media']}",
                                                                      flickMultiManager:
                                                                          _flickMultiManager,
                                                                      image: _result[index]['frame'] !=
                                                                              null
                                                                          ? _result[index]
                                                                              [
                                                                              'frame']
                                                                          : '${avatarUrl}noAvatar.png',
                                                                    )
                                                                  : AspectRatio(
                                                                      aspectRatio:
                                                                          1 / 1,
                                                                      child:
                                                                          ClipRect(
                                                                        child:
                                                                            PhotoView(
                                                                          imageProvider:
                                                                              CachedNetworkImageProvider(
                                                                            '$uploadTapes${_result[index]['media']}',
                                                                          ),
                                                                          backgroundDecoration:
                                                                              BoxDecoration(color: Colors.transparent),
                                                                          minScale:
                                                                              PhotoViewComputedScale.contained,
                                                                          maxScale:
                                                                              PhotoViewComputedScale.contained,
                                                                          enableRotation:
                                                                              false,
                                                                        ),
                                                                      ),
                                                                    ),
                                                            ),
                                                          ),
                                                        ),
                                              needToHide
                                                  ? Center()
                                                  : needToBlock
                                                      ? Center()
                                                      : Row(
                                                          children: <Widget>[
                                                            IconButton(
                                                              icon: Container(
                                                                width: 35,
                                                                height: 35,
                                                                child: Image(
                                                                  image:
                                                                      AssetImage(
                                                                    _saved.contains(_result[index]
                                                                            [
                                                                            'id'])
                                                                        ? 'assets/images/tapeLiked.png'
                                                                        : 'assets/images/tapeUnliked.png',
                                                                  ),
                                                                ),
                                                              ),
                                                              onPressed:
                                                                  () async {
                                                                await _api
                                                                    .likeTape(
                                                                        '${_result[index]['id']}')
                                                                    .then(
                                                                        (value) {
                                                                  setState(() {
                                                                    _likeResult =
                                                                        value;
                                                                  });
                                                                });

                                                                setState(() {
                                                                  if (_likeResult[
                                                                          'result']
                                                                      [
                                                                      'myLike']) {
                                                                    _saved.add(_result[
                                                                            index]
                                                                        ['id']);
                                                                    _result[index]
                                                                        [
                                                                        'likesCount'] += 1;
                                                                  } else {
                                                                    _saved.remove(
                                                                        _result[index]
                                                                            [
                                                                            'id']);
                                                                    _result[index]
                                                                        [
                                                                        'likesCount'] -= 1;
                                                                  }
                                                                });
                                                              },
                                                            ),
                                                            Container(
                                                              width: 30,
                                                              child: Text(
                                                                '${_result[index]['likesCount']}',
                                                              ),
                                                            ),
                                                            IconButton(
                                                              icon: Container(
                                                                width: 35,
                                                                height: 35,
                                                                child: Image(
                                                                  image:
                                                                      AssetImage(
                                                                    'assets/images/tapeComment.png',
                                                                  ),
                                                                ),
                                                              ),
                                                              onPressed: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        TapePage(
                                                                            _result[index]),
                                                                  ),
                                                                ).whenComplete(
                                                                    () {});
                                                              },
                                                            ),
                                                            '${_result[index]['commentsCount']}' ==
                                                                    '0'
                                                                ? SizedBox(
                                                                    height: 0,
                                                                    width: 0)
                                                                : Container(
                                                                    width: 30,
                                                                    child: Text(
                                                                      '${_result[index]['commentsCount']}',
                                                                    ),
                                                                  ),
                                                            Expanded(
                                                              child: Text(''),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          10.0),
                                                              child: Text(
                                                                '${_result[index]['created'].toString().replaceAll(".2020", "")}',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                              needToHide
                                                  ? Center()
                                                  : needToBlock
                                                      ? Center()
                                                      : Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left:
                                                                          10.0,
                                                                      right:
                                                                          10),
                                                              child: Container(
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                child: Text(
                                                                  '${_result[index]['description']}',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                  ),
                                                                  maxLines: _result[
                                                                          index]
                                                                      [
                                                                      'maxLines'],
                                                                ),
                                                              ),
                                                            ),
                                                            moreLessAction(
                                                                index)
                                                          ],
                                                        ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: Row(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 10.0, top: 10),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25.0),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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

  Widget moreLessAction(int index) {
    return LayoutBuilder(builder: (context, size) {
      final span = TextSpan(
        text: _result[index]['description'],
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
              _result[index]['maxLines'] == null
                  ? '${localization.less}'
                  : '${localization.more}',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            onTap: () {
              setState(() {
                if (_result[index]['maxLines'] == null) {
                  _result[index]['maxLines'] = 3;
                } else {
                  _result[index]['maxLines'] = null;
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

  @override
  bool get wantKeepAlive => true;
}
