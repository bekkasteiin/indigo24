import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indigo24/chat/ui/new_chat/chat_models/chat_model.dart';
import 'package:indigo24/chat/ui/new_chat/chat_models/hive_names.dart';
import 'package:indigo24/chat/ui/new_chat/chat_models/messages_model.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/pages/auth/intro.dart';
import 'package:indigo24/pages/settings/settings_main.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/helper.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/alerts.dart';
import 'package:indigo24/widgets/photo.dart';
import 'package:indigo24/widgets/progress_bar.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/localization.dart' as localization;
import 'profile_settings.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

bool needToAskCity = true;

class _UserProfilePageState extends State<UserProfilePage>
    with AutomaticKeepAliveClientMixin {
  Api _api;
  @override
  void dispose() {
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  void initState() {
    super.initState();
    _api = Api();
    _api.getProfile().then((result) {
      if (result['message'] == 'Not authenticated' &&
          result['success'].toString() == 'false') {
        logOut(context);
      }
      if (result['success'] == true) {
        if (mounted) {
          setState(() {
            user.avatar = result['avatar'];
            user.email = result['email'];
            user.identified = result['identified'];
            user.name = result['name'];
            user.phone = '+' + result['phone'];
            if (result['country'] != null) {
              user.country = result['country'];
            }
            if (result['city'] != null) {
              if (result['city'].contains(';')) {
                List cities = result['city'].split(';');
                if (needToAskCity) _showSelectCity(cities);
              } else {
                user.city = result['city'];
              }
            }
          });
        }
      }
    });

    _initPackageInfo();
  }

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );
  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = info;
      });
    }
  }

  _showSelectCity(cities) {
    var api = Api();
    needToAskCity = false;
    Size size = MediaQuery.of(context).size;
    Dialog errorDialog = Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        width: size.width * 0.5,
        height: size.width * 0.8,
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(10),
              child: Text('${localization.selectOption}'),
            ),
            Container(height: 1, width: size.width, color: blackColor),
            Flexible(
              child: ListView.separated(
                padding: EdgeInsets.all(0),
                shrinkWrap: false,
                itemCount: cities.length,
                itemBuilder: (BuildContext context, int index) {
                  return FlatButton(
                    child: Text('${cities[index]}'),
                    onPressed: () {
                      api.settingsSave(city: cities[index]).then((result) {
                        if (result['success']) {
                          setState(() {
                            user.city = cities[index];
                          });
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomDialog(
                                description: "${result["message"]}",
                                yesCallBack: () {
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          );
                        }
                      });
                    },
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    Container(
                  height: 1,
                  width: size.width,
                  color: blackColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return errorDialog;
      },
    );
  }

  File _image;

  final picker = ImagePicker();

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
        uploadAvatar(_image.path).then((r) async {
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
        });
      }
    }
  }

  Response response;
  ProgressBar sendingMsgProgressBar;
  BaseOptions options = new BaseOptions(
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

  Widget _buildProfileImage() {
    return InkWell(
      onTap: () {
        final act = CupertinoActionSheet(
            title: Text('${localization.selectOption}'),
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text('${localization.watch}'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenWrapper(
                        imageProvider: CachedNetworkImageProvider(
                            "${user.avatarUrl}${user.avatar}"),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.contained * 3,
                        backgroundDecoration:
                            BoxDecoration(color: Colors.transparent),
                      ),
                    ),
                  );
                },
              ),
              CupertinoActionSheetAction(
                child: Text('${localization.camera}'),
                onPressed: () {
                  getImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              CupertinoActionSheetAction(
                child: Text('${localization.gallery}'),
                onPressed: () {
                  getImage(ImageSource.gallery);
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
          context: context,
          builder: (BuildContext context) => act,
        );
      },
      child: Center(
        child: Stack(
          children: [
            Container(
              width: 100.0,
              height: 100.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(80.0),
                color: whiteColor,
              ),
            ),
            Container(
              width: 100.0,
              height: 100.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                    '$avatarUrl${user.avatar.toString().replaceAll("AxB", "200x200")}',
                  ),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(80.0),
                border: Border.all(
                  color: whiteColor,
                  width: 5.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullName() {
    TextStyle _nameTextStyle = TextStyle(
      fontFamily: 'Roboto',
      color: whiteColor,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
    );

    return GestureDetector(
      onTap: () {},
      child: Text(
        user.name,
        style: _nameTextStyle,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSection(Size screenSize, String header, String text) {
    return Column(
      children: [
        SizedBox(height: 10),
        Container(
          width: screenSize.width / 1.3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(header),
              SizedBox(height: 5),
              Text(
                text,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  color: blackPurpleColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 5)
            ],
          ),
        ),
        Container(
          width: screenSize.width / 1.3,
          height: 0.5,
          color: Colors.black54,
          margin: EdgeInsets.only(top: 4.0),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(height: 160),
                      _buildSection(
                        screenSize,
                        localization.phoneNumber,
                        user.phone,
                      ),
                      _buildSection(
                        screenSize,
                        localization.email,
                        user.email,
                      ),
                      user.country != ''
                          ? _buildSection(
                              screenSize,
                              localization.country,
                              user.country,
                            )
                          : Center(),
                      user.city != ''
                          ? _buildSection(
                              screenSize,
                              localization.city,
                              user.city,
                            )
                          : Center(),
                      SizedBox(height: 30),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      SizedBox(height: 10),
                      Text(
                        '${localization.appVersion} ${_packageInfo.version}:${_packageInfo.buildNumber}',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 15),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.42),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10.0,
                                  spreadRadius: -2,
                                  offset: Offset(0.0, 0.0))
                            ],
                          ),
                          child: ButtonTheme(
                            minWidth: MediaQuery.of(context).size.width * 0.42,
                            height: 50,
                            child: RaisedButton(
                              onPressed: () async {
                                if (await canLaunch(
                                    'https://indigo24.com/contacts.html')) {
                                  await launch(
                                    'https://indigo24.com/contacts.html',
                                    forceSafariVC: false,
                                    forceWebView: false,
                                    headers: <String, String>{
                                      'my_header_key': 'my_header_value'
                                    },
                                  );
                                } else {
                                  throw 'Could not launch https://indigo24.com/contacts.html';
                                }
                              },
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(
                                  "${localization.support}",
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              color: whiteColor,
                              textColor: whiteColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  10.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.42),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10.0,
                                spreadRadius: -2,
                                offset: Offset(0.0, 0.0),
                              )
                            ],
                          ),
                          child: ButtonTheme(
                            minWidth: MediaQuery.of(context).size.width * 0.42,
                            height: 50,
                            child: RaisedButton(
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      CustomDialog(
                                    description: "${localization.wantToExit}?",
                                    yesCallBack: () async {
                                      var api = Api();
                                      var preferences =
                                          await SharedPreferences.getInstance();
                                      Hive.box<MessageModel>(HiveBoxes.messages)
                                          .clear();
                                      Hive.box<ChatModel>(HiveBoxes.chats)
                                          .clear();

                                      preferences.setString('phone', 'null');
                                      ChatRoom.shared.channel = null;
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (context) => IntroPage(),
                                        ),
                                        (r) => false,
                                      );
                                      await api.logOutHttp().then((result) {
                                        print(result);
                                        if (result['message'] ==
                                                'Not authenticated' &&
                                            result['success'].toString() ==
                                                'false') {
                                          logOut(context);
                                        } else {
                                          if (result['success'] == true) {
                                          } else {}
                                        }
                                      });
                                    },
                                    noCallBack: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                );
                              },
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(
                                  '${localization.exit}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              color: primaryColor,
                              textColor: whiteColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  10.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(height: 20)
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 120,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/cover.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              children: <Widget>[
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SettingsMainPage(),
                              ),
                            ).whenComplete(
                              () => setState(() {}),
                            );
                          },
                          child: Ink(
                            child: Image.asset(
                              "assets/images/settings.png",
                              width: 35,
                            ),
                          )),
                    ),
                    SizedBox(width: 15),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(width: 10),
                          _buildProfileImage(),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(top: 15),
                                  child: _buildFullName(),
                                ),
                                SizedBox(height: 5),
                                InkWell(
                                  onTap: () {},
                                  child: Text(
                                    "${user.identified ? localization.identified : localization.notIdentified}",
                                    style: TextStyle(
                                      color: whiteColor,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: GestureDetector(
                              child: Image.asset(
                                'assets/images/pencil.png',
                                width: 20,
                                height: 20,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfileSettingsPage(),
                                  ),
                                ).whenComplete(() {
                                  setState(() {});
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
            isUploading
                ? Container(
                    width: screenSize.width,
                    height: screenSize.height,
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
                              fontSize: 20.0),
                        ),
                        footer: Text(
                          "Загрузка",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 17.0),
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
