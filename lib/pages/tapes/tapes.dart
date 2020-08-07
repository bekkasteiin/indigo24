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
  bool isLoaded = false;
  var api = Api();
  List result;
  int tapePage = 1;
  FlickMultiManager flickMultiManager;

  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;

  getTapeFromDb() async {
    tapesDatabaseData = await tapeDb.getAll();
  }

  @override
  void initState() {
    print("tapes init state");
    getTapeFromDb();
    getTapes();
    super.initState();
  }

  rebuildTape() {
    setState(() {
      flickMultiManager = FlickMultiManager();
    });

    api.getTapes('1').then((tapes) {
      if (tapes['message'] == 'Not authenticated' &&
          tapes['success'].toString() == 'false') {
        logOut(context);
        return true;
      } else {
        return rebuild(tapes);
      }
    });
  }

  var tapesDatabaseData = [];
  getTapes() {
    setState(() {
      flickMultiManager = FlickMultiManager();
    });
    api.getTapes('$tapePage').then((tapes) async {
      if (tapes['message'] == 'Not authenticated' &&
          tapes['success'].toString() == 'false') {
        logOut(context);
        return true;
      } else {
        // print(tapeDb.getAll());
        // print(tapeDb.getAll());
        return setTapes(tapes);
      }
    });
  }

  Future addTapes(tapes) async {
    setState(() {
      var r = tapes["result"].toList();
      result.addAll(r);
      isLoaded = false;
    });
  }

  Future rebuild(tapes) async {
    setState(() {
      tapePage = 2;
      result = tapes["result"].toList();
      _listFuture = Future(foo);
      result.forEach((el) async {
        if (el['myLike'] == true) {
          _saved.add(el['id']);
        }
      });
    });
  }

  Future setTapes(tapes) async {
    if (tapePage == 1)
      setState(() {
        result = tapes["result"].toList();
        _listFuture = Future(foo);
        result.forEach((el) async {
          if (el['myLike'] == true) {
            _saved.add(el['id']);
          }
        });
      });
    else
      setState(() {
        result.addAll(tapes["result"].toList());
        result.forEach((el) async {
          if (el['myLike'] == true) {
            _saved.add(el['id']);
          }
        });
      });
  }

  void _onLoading() async {
    tapePage++;
    getTapes();
    // if(mounted)
    _refreshController.loadComplete();
  }

  TapeDB tapeDb = TapeDB();
  int foo() {
    return 1;
  }

  var likeResult;
  var commentResult;

  @override
  void dispose() {
    super.dispose();
    print("dispose TAPES PAGES");
    _videoPlayerController.dispose();
    _chewieController.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    flickMultiManager.dispose();
  }

  final Set _saved = Set();

  void _onRefresh() {
    rebuildTape();
    _refreshController.refreshCompleted();
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  showAlertDialog(BuildContext context, String message) {
    print("Alert");
    Widget okButton = CupertinoDialogAction(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    CupertinoAlertDialog alert = CupertinoAlertDialog(
      // title: Text("Alert"),
      content: Text(message),
      actions: [
        okButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  moreActions({dynamic data}) {
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

              await tapeDb.updateOrInsert(tape);

              tapesDatabaseData = await tapeDb.getAll();
              setState(() {
                tapesDatabaseData = tapesDatabaseData;
              });
              print('$data' '$tapesDatabaseData');
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

              await tapeDb.updateOrInsert(tape);
              api.blockUser(data[
                  'customerId']); // TODO CHECK IT WHEN BACKEND FIXES REQUEST
              tapesDatabaseData = await tapeDb.getAll();
              setState(() {
                tapesDatabaseData = tapesDatabaseData;
              });
              print('$data' '$tapesDatabaseData');
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
        context: context, builder: (BuildContext context) => act);
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          brightness: Brightness.light,
          title: Text(
            "${localization.tape}",
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
                // .whenComplete(() {
                //   print("GET TAPES AFTER ADDING");
                //   flickMultiManager.removeAll();
                //   rebuildTape();
                // });
                if (response != null) {
                  print("RESULT $response");
                  setState(() {
                    result.insert(0, response);
                    flickMultiManager = new FlickMultiManager();
                  });
                  print("Result index 0: ${result[0]}");
                }
              },
            )
          ],
          backgroundColor: Colors.white,
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
                      itemCount: result.length,
                      itemBuilder: (BuildContext context, int index) {
                        bool needToHide = false;
                        bool needToBlock = false;
                        tapesDatabaseData.forEach((element) {
                          // print('${element.toJson()['isBlocked']} ${element.toJson()['id']} ${result[index]['id']}');
                          if ('${element.toJson()['id']}' ==
                              '${result[index]['id']}') {
                            needToHide = true;
                          }
                          if ('${element.toJson()['id']}' ==
                                  '${result[index]['id']}' &&
                              '${element.toJson()['isBlocked']}' == 'true') {
                            needToHide = false;
                            needToBlock = true;
                          }
                        });
                        // if (result[index]['media'].endsWith('mp4')) {
                        //   print(result[index]['media']);
                        //   _controller =
                        //       VideoPlayerController.network(result[index]['media'])
                        //         ..initialize().then((_) {
                        //           print('inited');
                        //           setState(() {});
                        //         });
                        // }
                        // if (result[index]['media'].endsWith('mp4'))
                        //   return Container();
                        return needToHide
                            ? Container()
                            : VisibilityDetector(
                                key: ObjectKey(flickMultiManager),
                                onVisibilityChanged: (visibility) {
                                  if (visibility.visibleFraction == 0 &&
                                      this.mounted) {
                                    print("A B C A B C A B C A B C A B C");
                                    flickMultiManager.pause();
                                  }
                                },
                                child: Container(
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        child: Container(
                                          color: milkWhiteColor,
                                          padding: const EdgeInsets.only(
                                            top: 10,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
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
                                                                      : '$avatarUrl${result[index]['avatar'].toString().replaceAll("AxB", "200x200")}',
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
                                                                        ? 'Hided content by ${result[index]['name']}'
                                                                        : needToBlock
                                                                            ? 'Blocked content by ${result[index]['name']}'
                                                                            : '${result[index]['name']}',
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
                                                                              '${result[index]['title']}',
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
                                                                  moreActions(
                                                                      data: result[
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
                                                            await api
                                                                .likeTape(
                                                                    '${result[index]['id']}')
                                                                .then((value) {
                                                              likeResult =
                                                                  value;
                                                            });
                                                            setState(() {
                                                              if (likeResult[
                                                                      'result']
                                                                  ['myLike']) {
                                                                _saved.add(
                                                                    result[index]
                                                                        ['id']);
                                                                result[index][
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
                                                                    'Вы лайнули пост ${result[index]['title']} от ${result[index]['name']}',
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
                                                                    result[index]
                                                                        ['id']);
                                                                result[index][
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
                                                              child: (result[index]['media'].toString().endsWith("MOV") ||
                                                                      result[index]
                                                                              [
                                                                              'media']
                                                                          .toString()
                                                                          .endsWith(
                                                                              "mov") ||
                                                                      result[index]
                                                                              [
                                                                              'media']
                                                                          .toString()
                                                                          .endsWith(
                                                                              "mp4") ||
                                                                      result[index]
                                                                              [
                                                                              'media']
                                                                          .toString()
                                                                          .endsWith(
                                                                              "mpeg") ||
                                                                      result[index]
                                                                              [
                                                                              'media']
                                                                          .toString()
                                                                          .endsWith(
                                                                              "avi"))
                                                                  ? new FlickMultiPlayer(
                                                                      url:
                                                                          "$uploadTapes${result[index]['media']}",
                                                                      flickMultiManager:
                                                                          flickMultiManager,
                                                                      image: result[index]['frame'] !=
                                                                              null
                                                                          ? result[index]
                                                                              [
                                                                              'frame']
                                                                          : 'assets/preloader.gif',
                                                                    )
                                                                  // new ChewieVideo(
                                                                  //     controller:
                                                                  //         VideoPlayerController
                                                                  //             .network(
                                                                  //                 "$uploadTapes${result[index]['media']}"),
                                                                  //   )
                                                                  : AspectRatio(
                                                                      aspectRatio:
                                                                          1 / 1,
                                                                      // Puts a "mask" on the child, so that it will keep its original, unzoomed size
                                                                      // even while it's being zoomed in
                                                                      child:
                                                                          ClipRect(
                                                                        child:
                                                                            PhotoView(
                                                                          imageProvider:
                                                                              CachedNetworkImageProvider(
                                                                            '$uploadTapes${result[index]['media']}',
                                                                          ),
                                                                          backgroundDecoration:
                                                                              BoxDecoration(color: Colors.transparent),
                                                                          // Contained = the smallest possible size to fit one dimension of the screen
                                                                          minScale:
                                                                              PhotoViewComputedScale.contained,
                                                                          // Covered = the smallest possible size to fit the whole screen
                                                                          maxScale:
                                                                              PhotoViewComputedScale.contained,
                                                                          enableRotation:
                                                                              false,
                                                                        ),
                                                                      ),
                                                                    ),

                                                              // Image(
                                                              //   image: NetworkImage(
                                                              //     "https://indigo24.xyz/uploads/tapes/${result[index]['media']}",
                                                              //   ),
                                                              // ),
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
                                                                    _saved.contains(result[index]
                                                                            [
                                                                            'id'])
                                                                        ? 'assets/images/tapeLiked.png'
                                                                        : 'assets/images/tapeUnliked.png',
                                                                  ),
                                                                ),
                                                              ),
                                                              onPressed:
                                                                  () async {
                                                                await api
                                                                    .likeTape(
                                                                        '${result[index]['id']}')
                                                                    .then(
                                                                        (value) {
                                                                  print(value);
                                                                  setState(() {
                                                                    likeResult =
                                                                        value;
                                                                  });
                                                                });

                                                                setState(() {
                                                                  if (likeResult[
                                                                          'result']
                                                                      [
                                                                      'myLike']) {
                                                                    _saved.add(result[
                                                                            index]
                                                                        ['id']);
                                                                    result[index]
                                                                        [
                                                                        'likesCount'] += 1;
                                                                  } else {
                                                                    _saved.remove(
                                                                        result[index]
                                                                            [
                                                                            'id']);
                                                                    result[index]
                                                                        [
                                                                        'likesCount'] -= 1;
                                                                  }
                                                                });
                                                              },
                                                            ),
                                                            Container(
                                                              width: 30,
                                                              child: Text(
                                                                '${result[index]['likesCount']}',
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
                                                                            result[index]),
                                                                  ),
                                                                ).whenComplete(
                                                                    () {});
                                                              },
                                                            ),
                                                            // IconButton(
                                                            //   icon: Container(
                                                            //     width: 35,
                                                            //     height: 35,
                                                            //     child: Image(
                                                            //       image: AssetImage(
                                                            //         'assets/images/send.png',
                                                            //       ),
                                                            //     ),
                                                            //   ),
                                                            //   onPressed: () {
                                                            //     print("${result[index]['id']}");
                                                            //   },
                                                            // ),
                                                            // Container(
                                                            //   width: 30,
                                                            //   child: Text(
                                                            //     '${result[index]['commentsCount']}',
                                                            //   ),
                                                            // ),
                                                            Expanded(
                                                              child: Text(''),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      right:
                                                                          10.0),
                                                              child: Text(
                                                                '${result[index]['created'].toString().replaceAll(".2020", "")}',
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
                                                      : Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 10.0),
                                                          child: Text(
                                                            '${result[index]['description']}',
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                fontSize: 16),
                                                            maxLines: 3,
                                                          ),
                                                        ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: Row(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10.0,
                                                              top: 10),
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

  @override
  bool get wantKeepAlive => true;
}

class ChewieVideo extends StatefulWidget {
  final VideoPlayerController controller;
  final size;
  ChewieVideo({this.controller, this.size});

  @override
  _ChewieVideoState createState() => _ChewieVideoState();
}

class _ChewieVideoState extends State<ChewieVideo> {
  VideoPlayerController controller;
  ChewieController _chewieController;

  Future<void> _future;

  Future<void> initVideoPlayer() async {
    await controller.initialize();
    setState(() {
      print(controller.value.aspectRatio);
      _chewieController = ChewieController(
        videoPlayerController: controller,
        aspectRatio: controller.value.aspectRatio,
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
        autoInitialize: true,
        autoPlay: false,
        looping: false,
        placeholder: buildPlaceholderImage(),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                errorMessage,
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      );
    });
  }

  @override
  void initState() {
    super.initState();
    setControllers();
  }

  setControllers() {
    controller = widget.controller;
    _future = initVideoPlayer();
  }

  @override
  void deactivate() {
    super.deactivate();
    print("deactive");
    if (controller != null && _chewieController != null) {
      controller.dispose();
      _chewieController.dispose();
      _future = null;
    }
  }

  @override
  void didChangeDependencies() {
    // routeObserver.subscribe(this, ModalRoute.of(context));
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    if (controller != null && _chewieController != null) {
      controller.dispose();
      _chewieController.dispose();
      _future = null;
    }
    // _chewieController.videoPlayerController.dispose();
  }

  //

  buildPlaceholderImage() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return buildPlaceholderImage();
              if (_chewieController == null) return buildPlaceholderImage();
              return Chewie(
                controller: _chewieController,
              );
            }),
      ),
    );
  }
}
