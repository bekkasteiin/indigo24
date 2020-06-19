import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/widgets/picker.dart';
import 'package:video_player/video_player.dart';
import 'package:indigo24/services/localization.dart' as localization;

var singleFile;

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
  bool isVideo = false;
  VideoPlayerController _controller;
  String _retrieveDataError;
  TextEditingController titleController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  var api = Api();
  final picker = ImagePicker();
  PickedFile _myFile;

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
  

  void _onImageButtonPressed(ImageSource source) async {
    if (_controller != null) {
      await _controller.setVolume(0.0);
    }
    if (isVideo) {
      final pickedFile = await picker.getVideo(source: source);
      
      // final File file = await ImagePicker.pickVideo(source: source);
      // _videoFile = file;
      // _currentFile = file;
      if (pickedFile != null) {
        setState(() {
          _videoFile = File(pickedFile.path);
          _currentFile = File(pickedFile.path);
        });

        print("video file from $_videoFile");
        await _playVideo(_videoFile);
      }
      
    } else {
      try {
        // _imageFile = await ImagePicker.pickImage(source: source);
        // final pickedFile = await picker.getImage(source: source);
        final pickedFile = await picker.getImage(source: source);
        if (pickedFile != null) {
          setState(() {
            _imageFile = File(pickedFile.path);
            _currentFile = File(pickedFile.path);
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
      title: Text("Ошибка"),
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
    super.dispose();
  }

  Future<void> _disposeVideoController() async {
    if (_controller != null) {
      await _controller.dispose();
      _controller = null;
    }
  }

  Widget _previewVideo() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_controller == null) {
      return ListView(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(10),
            child: TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Название')),
          ),
          Container(
            margin: EdgeInsets.all(10),
            child: TextField(
                minLines: 1,
                maxLines: 4,
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Описание')),
          ),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListView(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(10),
            child: TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Название')),
          ),
          Container(
            margin: EdgeInsets.all(10),
            child: TextField(
                minLines: 1,
                maxLines: 4,
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Описание')),
          ),
          AspectRatioVideo(_controller),
        ],
      ),
    );
  }

  Widget _previewImage() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFile != null) {
      return ListView(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(10),
            child: TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Название')),
          ),
          Container(
            margin: EdgeInsets.all(10),
            child: TextField(
                minLines: 1,
                maxLines: 4,
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Описание')),
          ),
          Container(
            height: MediaQuery.of(context).size.width,
            width: MediaQuery.of(context).size.width,
            child: Image(
              image: FileImage(_imageFile),
            ),
          ),
        ],
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return ListView(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(10),
            child: TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Название')),
          ),
          Container(
            margin: EdgeInsets.all(10),
            child: TextField(
                minLines: 1,
                maxLines: 4,
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Описание')),
          ),
        ],
      );
    }
  }

  Future<void> retrieveLostData() async {
    final LostData response = await picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      if (response.type == RetrieveType.video) {
        isVideo = true;
        await _playVideo(File(response.file.path));
      } else {
        isVideo = false;
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
    api.addTape(_currentFile.path, titleController.text, descriptionController.text).then((r) {
      if (r['message'] == 'Not authenticated' && r['success'].toString() == 'false') {
        logOut(context);
        return r;
      } else {
        if (r["success"]) {
          titleController.text = "";
          descriptionController.text = "";
          Navigator.pop(context);
        } else {
          print("false false false ");
          showAlertDialog(context, r["message"]?? "");
        }
      return r;
      }
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
              if(descriptionController.text == '' || titleController.text == ''){
                showAlertDialog(context, "Заполните все поля");
              } else if(_currentFile == null){
                showAlertDialog(context, "Выберите файл");
              } else {
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
        child: Platform.isAndroid
            ? FutureBuilder<void>(
                future: retrieveLostData(),
                builder:
                    (BuildContext context, AsyncSnapshot<void> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return const Text(
                        'Вы не выбрали фото',
                        textAlign: TextAlign.center,
                      );
                    case ConnectionState.done:
                      return isVideo ? _previewVideo() : _previewImage();
                    default:
                      if (snapshot.hasError) {
                        return Text(
                          'Pick image/video error: ${snapshot.error}}',
                          textAlign: TextAlign.center,
                        );
                      } else {
                        return const Text(
                          'Вы не выбрали фото',
                          textAlign: TextAlign.center,
                        );
                      }
                  }
                },
              )
            : (isVideo ? _previewVideo() : _previewImage()),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                isVideo = false;
                _settingModalBottomSheet(context);
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
                  isVideo = true;
                _onImageButtonPressed(ImageSource.camera);
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
    );
  }

  void _settingModalBottomSheet(context){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc){
          return PickerPage();
      }
    );
}

  Text _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }
}

class AspectRatioVideo extends StatefulWidget {
  AspectRatioVideo(this.controller);

  final VideoPlayerController controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController get controller => widget.controller;
  bool initialized = false;

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller.value.initialized) {
      initialized = controller.value.initialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    controller.removeListener(_onVideoControllerUpdate);
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller.value?.aspectRatio,
          child: VideoPlayer(controller),
        ),
      );
    } else {
      return Container();
    }
  }
}
