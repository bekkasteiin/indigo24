import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indigo24/services/api/http/api.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/shared_preference/helper.dart';
import 'package:indigo24/services/shared_preference/shared_strings.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/localization/localization.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/alerts/indigo_alert.dart';
import 'package:indigo24/widgets/alerts/indigo_show_dialog.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_appbar_widget.dart';
import 'package:indigo24/widgets/progress_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'package:indigo24/widgets/alerts/indigo_logout.dart';

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

  double uploadPercent = 0.0;
  bool isUploading = false;

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
        _api.uploadAvatar(
          _image.path,
          onSendProgress: (int sent, int total) {
            setState(() {
              isUploading = true;
              uploadPercent = sent / total;
            });
          },
          onReceiveProgress: (count, total) {
            setState(() {
              isUploading = false;
              uploadPercent = 0.0;
            });
          },
        ).then(
          (r) async {
            if (r['message'] == 'Not authenticated' &&
                r['success'].toString() == 'false') {
              logOut(context);
              return r;
            } else {
              if (r["success"]) {
                await SharedPreferencesHelper.setString(
                    SharedStrings.avatar, '${r["fileName"]}');
                setState(() {
                  user.avatar = r["fileName"];
                });
              } else {
                showIndigoDialog(
                  context: context,
                  builder: CustomDialog(
                    description: "${r["message"]}",
                    yesCallBack: () {
                      Navigator.of(context).pop();
                    },
                  ),
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
        backgroundColor: whiteColor,
        appBar: IndigoAppBarWidget(
          title: FittedBox(
            child: Text(
              "${Localization.language.edit} ${Localization.language.profile.toLowerCase()}",
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
                          SharedStrings.name,
                          _nameController.text,
                        );
                        SharedPreferencesHelper.setString(
                          SharedStrings.city,
                          _cityController.text,
                        );

                        showIndigoDialog(
                          context: context,
                          builder: CustomDialog(
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
                                color: darkPrimaryColor,
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
                                  color: darkPrimaryColor,
                                  width: 5.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 20),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            FlatButton(
                              onPressed: () {
                                getImage(ImageSource.camera);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    "${assetsPath}fromCamera.png",
                                    width: 50,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    '${Localization.language.photo} ${Localization.language.camera.toLowerCase()}',
                                    style: TextStyle(
                                      color: blackPurpleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FlatButton(
                              onPressed: () {
                                getImage(ImageSource.gallery);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    "${assetsPath}fromGallery.png",
                                    width: 50,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    '${Localization.language.photo} ${Localization.language.gallery.toLowerCase()}',
                                    style: TextStyle(
                                      color: blackPurpleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  _buildEditor(
                    size,
                    '${Localization.language.name}',
                    '${user.name}',
                    _nameController,
                    readyOnly: false,
                  ),
                  _buildEditor(
                    size,
                    '${Localization.language.city}',
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
                            (uploadPercent * 100).toStringAsFixed(2),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: whiteColor,
                              fontSize: 20.0,
                            ),
                          ),
                          footer: Text(
                            "Загрузка",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: whiteColor,
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
                boxShadow: [],
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
                  contentPadding: EdgeInsets.only(
                    bottom: 10,
                    top: 10,
                    right: 15,
                  ),
                  labelText: text,
                  labelStyle: TextStyle(fontSize: 18, color: greyColor),
                  hintStyle: TextStyle(
                    color: darkPrimaryColor,
                  ),
                  fillColor: whiteColor,
                ),
              ),
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
