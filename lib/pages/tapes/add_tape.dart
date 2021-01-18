import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/widgets/alerts/indigo_logout.dart';
import 'package:indigo24/services/api/http/api.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/alerts/indigo_alert.dart';
import 'package:indigo24/widgets/alerts/indigo_show_dialog.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_appbar_widget.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_modal_action_widget.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_text_field_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:indigo24/services/localization/localization.dart';

import 'aspect_ratio_video.dart';

class AddTapePage extends StatefulWidget {
  AddTapePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AddTapePageState createState() => _AddTapePageState();
}

class _AddTapePageState extends State<AddTapePage> {
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        appBar: IndigoAppBarWidget(
          title: Text(
            "${Localization.language.newTape}",
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
                padding: EdgeInsets.all(5),
                child: Image(
                  image: AssetImage(
                    '${assetsPath}add.png',
                  ),
                ),
              ),
              onPressed: () async {
                // if (singleFile != null) {
                //   // var json = singleFile.toJson();
                //   setState(() {
                //     // _currentFile = File(json['path']);
                //     _currentFile = File(singleFile);
                //     singleFile = null;
                //     isNotPicked = false;
                //   });
                // }
                if (_descriptionController.text == '' ||
                    _titleController.text == '') {
                  showIndigoDialog(
                    context: context,
                    builder: CustomDialog(
                      description: Localization.language.fillAllFields,
                      yesCallBack: () {
                        Navigator.pop(context);
                      },
                    ),
                  );
                } else if (_currentFile == null) {
                  showIndigoDialog(
                    context: context,
                    builder: CustomDialog(
                      description: Localization.language.selectFile,
                      yesCallBack: () {
                        Navigator.pop(context);
                      },
                    ),
                  );
                } else {
                  if (_controller != null) _pauseVideo();
                  await addTape(context);
                }
              },
            ),
          ],
        ),
        body: Center(
          child: ListView(
            children: [
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    child: IndigoTextField(
                      textEditingController: _titleController,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(40),
                      ],
                      hintText: Localization.language.title,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: IndigoTextField(
                      textEditingController: _descriptionController,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(200),
                      ],
                      hintText: Localization.language.description,
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                ],
              ),

              _isNotPicked
                  ? Container()
                  : _isVideo
                      ? _previewVideo()
                      : _previewImage(),

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
                backgroundColor: whiteColor,
                onPressed: () {
                  _isVideo = false;
                  _action();
                },
                heroTag: 'image',
                child: Image.asset("${assetsPath}camera.png", width: 30),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: FloatingActionButton(
                backgroundColor: whiteColor,
                onPressed: () {
                  _isVideo = true;
                  _action();
                },
                heroTag: 'video',
                child: Image.asset("${assetsPath}video.png", width: 30),
              ),
            ),
          ],
        ),
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

  _action() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    showIndigoBottomDialog(
      context: context,
      children: [
        IndigoModalActionWidget(
          onPressed: () {
            _onImageButtonPressed(ImageSource.camera);
            Navigator.pop(context);
          },
          title: Localization.language.camera,
        ),
        IndigoModalActionWidget(
          onPressed: () {
            _onImageButtonPressed(ImageSource.gallery);
            Navigator.pop(context);
          },
          title: Localization.language.gallery,
        ),
      ],
    );
  }

  void _onImageButtonPressed(ImageSource source) async {
    if (_controller != null) {
      await _controller.setVolume(0.0);
    }
    if (_isVideo) {
      final pickedFile = await _picker.getVideo(source: source);

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

        await _playVideo(_videoFile);
      }
    } else {
      try {
        // _imageFile = await ImagePicker.pickImage(source: source);
        // final pickedFile = await picker.getImage(source: source);
        final pickedFile = await _picker.getImage(source: source);
        if (pickedFile != null) {
          setState(() {
            _currentFile = File(pickedFile.path);
            _isNotPicked = false;
          });
          setState(() {});
        }
      } catch (e) {
        _pickImageError = e;
      }
    }
  }

  showAlertDialog(BuildContext context, String message) {
    showIndigoDialog(
      context: context,
      builder: CustomDialog(
        description: "$message",
        yesCallBack: () {
          Navigator.of(context).pop();
        },
      ),
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
        child: Text("${Localization.language.error}"),
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
        setState(() {});
      }
    } else {
      _retrieveDataError = response.exception.code;
    }
  }

  Future addTape(context) async {
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
