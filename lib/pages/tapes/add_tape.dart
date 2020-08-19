import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/services/api.dart';
import 'package:video_player/video_player.dart';
import 'package:indigo24/services/localization.dart' as localization;

import 'aspect_ratio_video.dart';

class AddTapePage extends StatefulWidget {
  AddTapePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AddTapePageState createState() => _AddTapePageState();
}

class _AddTapePageState extends State<AddTapePage> {
  File _imageFile;
  File _videoFile;
  File _currentFile;
  dynamic _pickImageError;
  bool _isVideo = false;
  VideoPlayerController _controller;
  String _retrieveDataError;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  Api _api = Api();
  ImagePicker _picker = ImagePicker();
  bool _isNotPicked = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void deactivate() {
    if (_controller != null) {
      _controller.setVolume(0.0);
      _controller.pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _disposeVideoController();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          appBar: AppBar(
            centerTitle: true,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(10),
                child: Image(
                  image: AssetImage(
                    'assets/images/back.png',
                  ),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            brightness: Brightness.light,
            title: Text('${localization.newTape}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center),
            actions: <Widget>[
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(5),
                  child: Image(
                    image: AssetImage(
                      'assets/images/add.png',
                    ),
                  ),
                ),
                onPressed: () async {
                  // print(singleFile);

                  // if (singleFile != null) {
                  //   // var json = singleFile.toJson();
                  //   // print(json['path']);
                  //   setState(() {
                  //     // _currentFile = File(json['path']);
                  //     _currentFile = File(singleFile);
                  //     singleFile = null;
                  //     isNotPicked = false;
                  //   });
                  // }
                  print("Pressed with $_currentFile");
                  if (_descriptionController.text == '' ||
                      _titleController.text == '') {
                    showAlertDialog(context, "${localization.fillAllFields}");
                  } else if (_currentFile == null) {
                    showAlertDialog(context, "${localization.selectFile}");
                  } else {
                    print("Current file $_currentFile");
                    _pauseVideo();
                    await addTape(context);
                  }
                },
              ),
            ],
            backgroundColor: Colors.white,
          ),
          body:
              // Center(
              //   child: Container(
              //     child: Center(
              //       child: Text("test"),
              //     ),
              //   ),
              // ),
              Center(
            child: ListView(
              children: [
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(10),
                      child: TextField(
                          controller: _titleController,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(40),
                          ],
                          decoration: InputDecoration(
                              labelText: '${localization.title}')),
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: TextField(
                          minLines: 1,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(80),
                          ],
                          keyboardType: TextInputType.text,
                          maxLines: 4,
                          controller: _descriptionController,
                          decoration: InputDecoration(
                              labelText: '${localization.description}')),
                    ),
                  ],
                ),

                _isNotPicked
                    ? Container()
                    : _isVideo ? _previewVideo() : _previewImage(),

                // Image(
                //   image: AssetDataImage(
                //     singleFile,
                //     targetWidth: Utils.width2px(context, ratio: 3),
                //     targetHeight: Utils.width2px(context, ratio: 3),
                //   ),
                //   fit: BoxFit.cover,
                //   width: double.infinity,
                //   height: double.infinity,
                // ),
              ],
            ),
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: () {
                    _isVideo = false;
                    action();
                    // _settingModalBottomSheet(context);
                    // MY COMMENT
                    // _onImageButtonPressed(ImageSource.camera);
                  },
                  heroTag: 'image',
                  tooltip: 'Pick Image from camera',
                  child: Image.asset("assets/images/camera.png", width: 30),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: () {
                    _isVideo = true;
                    action();
                    // _onImageButtonPressed(ImageSource.camera);
                  },
                  heroTag: 'video',
                  tooltip: 'Pick Video from camera',
                  child: Image.asset("assets/images/video.png", width: 30),
                ),
              ),
            ],
          )
          // Column(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: <Widget>[
          // FloatingActionButton(
          //   onPressed: () {
          //     isVideo = false;
          //     _onImageButtonPressed(ImageSource.gallery);
          //   },
          //   heroTag: 'image0',
          //   tooltip: 'Pick Image from gallery',
          //   child: const Icon(Icons.photo_library),
          // ),
          //     Padding(
          //       padding: const EdgeInsets.only(top: 16.0),
          //       child: FloatingActionButton(
          //         onPressed: () {
          //           isVideo = false;
          //           _onImageButtonPressed(ImageSource.camera);
          //         },
          //         heroTag: 'image1',
          //         tooltip: 'Take a Photo',
          //         child: const Icon(Icons.camera_alt),
          //       ),
          //     ),
          //     Padding(
          //       padding: const EdgeInsets.only(top: 16.0),
          //       child: FloatingActionButton(
          //         backgroundColor: Colors.red,
          //         onPressed: () {
          //           isVideo = true;
          //           _onImageButtonPressed(ImageSource.gallery);
          //         },
          //         heroTag: 'video0',
          //         tooltip: 'Pick Video from gallery',
          //         child: const Icon(Icons.video_library),
          //       ),
          //     ),
          //     Padding(
          //       padding: const EdgeInsets.only(top: 16.0),
          //       child: FloatingActionButton(
          //         backgroundColor: Colors.red,
          //         onPressed: () {
          // isVideo = true;
          // _onImageButtonPressed(ImageSource.camera);
          //         },
          //         heroTag: 'video1',
          //         tooltip: 'Take a Video',
          //         child: const Icon(Icons.videocam),
          //       ),
          //     ),
          //   ],
          // ),
          ),
    );
  }

  Future<void> _playVideo(File file) async {
    if (file != null && mounted) {
      await _disposeVideoController();
      _controller = VideoPlayerController.file(file);
      await _controller.setVolume(1.0);
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.play();
      setState(() {});
    }
  }

  Future<void> _pauseVideo() async {
    await _controller.setVolume(0.0);
    await _controller.initialize();
    await _controller.setLooping(false);
    await _controller.pause();
    setState(() {
      _controller = null;
    });
  }

  action() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    final act = CupertinoActionSheet(
        title: Text('${localization.selectOption}'),
        // message: Text('Which option?'),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text('${localization.camera}'),
            onPressed: () {
              _onImageButtonPressed(ImageSource.camera);
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text('${localization.gallery}'),
            onPressed: () {
              _onImageButtonPressed(ImageSource.gallery);
              Navigator.pop(context);
            },
          )
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

  void _onImageButtonPressed(ImageSource source) async {
    if (_controller != null) {
      await _controller.setVolume(0.0);
    }
    if (_isVideo) {
      final pickedFile = await _picker.getVideo(source: source);
      print(File(pickedFile.path).lengthSync());

      if (File(pickedFile.path).lengthSync() > 104857600) {
        showAlertDialog(context, "Файл превышает 100 Мб");
        return;
      }

      // final File file = await ImagePicker.pickVideo(source: source);
      // _videoFile = file;
      // _currentFile = file;
      if (pickedFile != null) {
        setState(() {
          _videoFile = File(pickedFile.path);
          _currentFile = File(pickedFile.path);
          _isNotPicked = false;
        });

        print("video file from $_videoFile");
        await _playVideo(_videoFile);
      }
    } else {
      try {
        // _imageFile = await ImagePicker.pickImage(source: source);
        // final pickedFile = await picker.getImage(source: source);
        final pickedFile = await _picker.getImage(source: source);
        if (pickedFile != null) {
          setState(() {
            _imageFile = File(pickedFile.path);
            _currentFile = File(pickedFile.path);
            _isNotPicked = false;
          });
          print("image file from $_imageFile");
          setState(() {});
        }
      } catch (e) {
        _pickImageError = e;
      }
    }
  }

  showAlertDialog(BuildContext context, String message) {
    Widget okButton = CupertinoDialogAction(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: Text("${localization.error}"),
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

  Future<void> _disposeVideoController() async {
    if (_controller != null) {
      _controller = null;
    }
  }

  Widget _previewVideo() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AspectRatioVideo(_controller),
    );
  }

  Widget _previewImage() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_currentFile != null) {
      return Container(
        height: MediaQuery.of(context).size.width,
        width: MediaQuery.of(context).size.width,
        child: Image(
          image: FileImage(_currentFile),
        ),
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return Container(
        child: Text("${localization.error}"),
      );
    }
  }

  Future<void> retrieveLostData() async {
    final LostData response = await _picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      if (response.type == RetrieveType.video) {
        _isVideo = true;
        await _playVideo(File(response.file.path));
      } else {
        _isVideo = false;
        setState(() {
          _imageFile = File(response.file.path);
        });
      }
    } else {
      _retrieveDataError = response.exception.code;
    }
  }

  Future addTape(context) async {
    print("MY current file ${_currentFile.path}");
    _disposeVideoController();
    _api
        .addTape(_currentFile.path, _titleController.text,
            _descriptionController.text, context)
        .then((r) {
      if (r['message'] == 'Not authenticated' &&
          r['success'].toString() == 'false') {
        logOut(context);
        return r;
      } else {
        if (r["success"]) {
          _titleController.text = "";
          _descriptionController.text = "";
          _isNotPicked = true;
          // Navigator.pop(context, r['result']);
          Navigator.of(context).pop(r['result']);
        } else {
          print("false false false ");
          showAlertDialog(context, r["message"] ?? "");
        }
        return r;
      }
    });
  }

  // void settingModalBottomSheet(context) {
  //   showModalBottomSheet(
  //       context: context,
  //       builder: (BuildContext bc) {
  //         return SingleImagePickerPage();
  //       });
  // }

  Text _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }
}
