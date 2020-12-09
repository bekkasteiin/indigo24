import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/helper.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/alerts.dart';
import 'package:indigo24/widgets/indigo_appbar_widget.dart';
import 'package:indigo24/widgets/progress_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../main.dart';

class ProfileSettingsPage extends StatefulWidget {
  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  TextEditingController _nameController;
  TextEditingController _cityController;
  Api _api;
  var picker;
  @override
  void initState() {
    _cityController = TextEditingController(text: user.city);
    _nameController = TextEditingController(text: user.name);
    _api = Api();
    picker = ImagePicker();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Response response;
  ProgressBar sendingMsgProgressBar;
  BaseOptions options = BaseOptions(
    baseUrl: "$baseUrl",
    connectTimeout: 5000,
    receiveTimeout: 3000,
  );

  Dio dio;
  var percent = "0 %";
  double uploadPercent = 0.0;
  bool isUploading = false;

  uploadAvatar(_path) async {
    sendingMsgProgressBar = ProgressBar();
    dio = new Dio(options);

    try {
      FormData formData = FormData.fromMap({
        "customerID": "${user.id}",
        "unique": "${user.unique}",
        "file": await MultipartFile.fromFile(_path),
      });

      response = await dio.post(
        "api/v2.1/avatar/upload",
        data: formData,
        onSendProgress: (int sent, int total) {
          String p = (sent / total * 100).toStringAsFixed(2);

          setState(() {
            isUploading = true;
            uploadPercent = sent / total;
            percent = "$p %";
          });
        },
        onReceiveProgress: (count, total) {
          setState(() {
            isUploading = false;
            uploadPercent = 0.0;
            percent = "0 %";
          });
        },
      );
      print("Getting response from avatar upload ${response.data}");
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response);
        print(e.response.statusCode);
      } else {
        print(e.request);
        print(e.message);
      }
    }
  }

  File _image;

  Future getImage(ImageSource imageSource) async {
    final pickedFile = await picker.getImage(
      source: imageSource,
    );

    final dir = await getTemporaryDirectory();

    final targetPath = dir.absolute.path + "/temp.jpg";

    if (pickedFile != null) {
      File compressedImage = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        targetPath,
      );

      setState(() {
        _image = compressedImage;
      });

      if (_image != null) {
        uploadAvatar(_image.path).then(
          (r) async {
            if (r['message'] == 'Not authenticated' &&
                r['success'].toString() == 'false') {
              logOut(context);
              return r;
            } else {
              if (r["success"]) {
                await SharedPreferencesHelper.setString(
                    'avatar', '${r["fileName"]}');
                setState(() {
                  user.avatar = r["fileName"];
                });
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomDialog(
                      description: "${r["message"]}",
                      yesCallBack: () {
                        Navigator.of(context).pop();
                      },
                    );
                  },
                );
              }
              return r;
            }
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: IndigoAppBarWidget(
          title: FittedBox(
            child: Text(
              "${localization.edit} ${localization.profile.toLowerCase()}",
              style: TextStyle(
                color: blackPurpleColor,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.done,
                color: primaryColor2,
              ),
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  _api
                      .settingsSave(
                    name: _nameController.text,
                    city: _cityController.text,
                  )
                      .then(
                    (result) {
                      if (result['success'].toString() == 'true') {
                        user.name = _nameController.text;
                        user.city = _cityController.text;

                        SharedPreferencesHelper.setString(
                          'name',
                          _nameController.text,
                        );
                        SharedPreferencesHelper.setString(
                          'city',
                          _cityController.text,
                        );

                        showDialog(
                          context: context,
                          builder: (BuildContext context) => CustomDialog(
                            description: result['message'],
                            yesCallBack: () {
                              Navigator.pop(context);
                            },
                          ),
                        );
                      }
                    },
                  );
                }
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: size.width * 0.35,
                              height: size.width * 0.35,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(80.0),
                                color: primaryColor,
                              ),
                            ),
                            Container(
                              width: size.width * 0.35,
                              height: size.width * 0.35,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                    '$avatarUrl${user.avatar.toString().replaceAll("AxB", "200x200")}',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(80.0),
                                border: Border.all(
                                  color: primaryColor,
                                  width: 5.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 20),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              children: [
                                FlatButton(
                                  onPressed: () {
                                    getImage(ImageSource.camera);
                                  },
                                  child: Row(
                                    children: [
                                      Image.asset(
                                          "assets/images/fromCamera.png",
                                          width: 30),
                                      SizedBox(width: 10),
                                      Text(
                                          '${localization.photo} ${localization.camera.toLowerCase()}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                FlatButton(
                                  onPressed: () {
                                    getImage(ImageSource.gallery);
                                  },
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        "assets/images/fromGallery.png",
                                        width: 30,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                          '${localization.photo} ${localization.gallery.toLowerCase()}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  _buildEditor(
                    size,
                    '${localization.name}',
                    '${user.name}',
                    _nameController,
                    readyOnly: false,
                  ),
                  _buildEditor(
                    size,
                    '${localization.city}',
                    '${user.city}',
                    _cityController,
                    readyOnly: false,
                  ),
                ],
              ),
              isUploading
                  ? Container(
                      width: size.width,
                      height: size.height,
                      color: darkGreyColor3.withOpacity(0.6),
                      child: Center(
                        child: CircularPercentIndicator(
                          radius: 120.0,
                          lineWidth: 13.0,
                          animation: false,
                          percent: uploadPercent,
                          progressColor: whiteColor,
                          backgroundColor: whiteColor,
                          center: Text(
                            percent,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20.0,
                            ),
                          ),
                          footer: Text(
                            "Загрузка",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 17.0,
                            ),
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditor(
    Size screenSize,
    String text,
    String initialValue,
    TextEditingController controller, {
    bool readyOnly = false,
  }) {
    return Center(
      child: Container(
        width: screenSize.width / 1.1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(55),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    spreadRadius: -5,
                    offset: Offset(0.0, 6.0),
                  )
                ],
              ),
              child: TextFormField(
                readOnly: readyOnly,
                controller: controller,
                style: TextStyle(
                  fontSize: 18,
                  color: blackPurpleColor,
                  fontWeight: FontWeight.w500,
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(100),
                ],
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(20.0),
                    ),
                  ),
                  contentPadding: EdgeInsets.only(
                    left: 15,
                    bottom: 10,
                    top: 10,
                    right: 15,
                  ),
                  labelText: text,
                  labelStyle: TextStyle(fontSize: 18, color: blackPurpleColor),
                  hintStyle: TextStyle(
                    color: darkPrimaryColor,
                  ),
                  fillColor: whiteColor,
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
