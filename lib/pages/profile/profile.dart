import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indigo24/db/chats_db.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/pages/auth/intro.dart';
import 'package:indigo24/pages/settings/settings_main.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/helper.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/style/colors.dart';
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
      print('profile result is $result');
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
                print(result['city']);
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

  showCustomDialog(BuildContext context, String message) async {
    Widget okButton = CupertinoDialogAction(
      child: Text("OK"),
      onPressed: () async {
        Navigator.pop(context);
      },
    );
    CupertinoAlertDialog alert = CupertinoAlertDialog(
      content: Text(message),
      actions: [
        okButton,
      ],
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _showSelectCity(cities) {
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
            Container(
              height: 1,
              width: size.width,
              color: blackColor,
            ),
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
                          showCustomDialog(context, '${result['message']}');
                        }
                      });

                      Navigator.pop(context);
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
  var api = Api();

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
      File test = File(pickedFile.path);
      compressedImage.length().then((value) => print(value));
      print("Picked file ${test.lengthSync()}");
      setState(() {
        _image = compressedImage;
        // _image = File(pickedFile.path);
      });
      if (_image != null) {
        uploadAvatar(_image.path).then((r) async {
          if (r['message'] == 'Not authenticated' &&
              r['success'].toString() == 'false') {
            logOut(context);
            return r;
          } else {
            if (r["success"]) {
              print("avatar url ${r["fileName"]}");

              await SharedPreferencesHelper.setString(
                  'avatar', '${r["fileName"]}');
              setState(() {
                user.avatar = r["fileName"];
              });
            } else {
              showAlertDialog(context, "${r["message"]}");
              print("error");
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

      print("Uploading avatar with data ${formData.fields}");

      // _sendingMsgProgressBar.show(context, "");

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
          print("$percent");
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
      // _sendingMsgProgressBar.hide();

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

  Widget _buildCoverImage(Size screenSize) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/cover.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return InkWell(
      onTap: () {
        final act = CupertinoActionSheet(
            title: Text('${localization.selectOption}'),
            // message: Text('Which option?'),
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text('${localization.watch}'),
                onPressed: () {
                  print("посмотреть ${user.avatarUrl}${user.avatar}");
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
      // PlatformActionSheet().displaySheet(
      //     context: context,
      //     message: Text("${localization.selectOption}"),
      //     actions: [
      //       ActionSheetAction(
      //         text: "Сфотографировать",
      //         onPressed: () {
      //           getImage(ImageSource.camera);
      //           Navigator.pop(context);
      //         },
      //         hasArrow: true,
      //       ),
      //       ActionSheetAction(
      //         text: "Выбрать из галереи",
      //         onPressed: () {
      //           getImage(ImageSource.gallery);
      //           Navigator.pop(context);
      //         },
      //       ),
      //       ActionSheetAction(
      //         text: "Назад",
      //         onPressed: () => Navigator.pop(context),
      //         isCancel: true,
      //         defaultAction: true,
      //       )
      //     ]),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            user.name,
            style: _nameTextStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  TextEditingController emailController =
      TextEditingController(text: '${user.email}');

  Widget _buildEmailSection(Size screenSize) {
    return Container(
      width: screenSize.width / 1.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("${localization.email}"),
          SizedBox(height: 5),
          Text(
            '${user.email}',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 18, color: blackPurpleColor),
          ),
          SizedBox(height: 5)
        ],
      ),
    );
  }

  Widget _buildCitySection(Size screenSize) {
    return Container(
      width: screenSize.width / 1.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("${localization.city}"),
          SizedBox(height: 5),
          Text(
            '${user.city}',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 18, color: blackPurpleColor),
          ),
          SizedBox(height: 5)
        ],
      ),
    );
  }

  Widget _buildCountrySection(Size screenSize) {
    return Container(
      width: screenSize.width / 1.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("${localization.country}"),
          SizedBox(height: 5),
          Text(
            '${user.country}',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 18, color: blackPurpleColor),
          ),
          SizedBox(height: 5)
        ],
      ),
    );
  }

  Widget _buildPhoneSection(Size screenSize) {
    return Container(
      width: screenSize.width / 1.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("${localization.phoneNumber}"),
          SizedBox(height: 5),
          Text(
            '${user.phone}',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 18, color: blackPurpleColor),
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildSeparator(Size screenSize) {
    return Container(
      width: screenSize.width / 1.3,
      height: 0.5,
      color: Colors.black54,
      margin: EdgeInsets.only(top: 4.0),
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
                      Column(
                        children: <Widget>[
                          SizedBox(height: 160),
                          _buildPhoneSection(screenSize),
                          _buildSeparator(screenSize),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          SizedBox(height: 10),
                          _buildEmailSection(screenSize),
                          _buildSeparator(screenSize),
                        ],
                      ),
                      user.country != ''
                          ? Column(
                              children: <Widget>[
                                SizedBox(height: 10),
                                _buildCountrySection(screenSize),
                                _buildSeparator(screenSize),
                              ],
                            )
                          : Center(),
                      user.city != ''
                          ? Column(
                              children: <Widget>[
                                SizedBox(height: 10),
                                _buildCitySection(screenSize),
                                _buildSeparator(screenSize),
                              ],
                            )
                          : Center(),
                      SizedBox(height: 10),
                      FlatButton(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('${localization.edit}',
                                style: TextStyle(fontSize: 16)),
                            SizedBox(
                              width: 10,
                            ),
                            Image.asset(
                              'assets/images/pencil.png',
                              width: 20,
                              height: 20,
                            ),
                          ],
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileSettingsPage(),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                  Column(
                    children: <Widget>[
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
                                    color: Colors.grey[700],
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
                                print('exit is pressed');
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      CustomDialog(
                                    title: null,
                                    description: "${localization.wantToExit}?",
                                    buttonText: "Okay",
                                    image: CachedNetworkImage(
                                      imageUrl: '$avatarUrl${user.avatar}',
                                    ),
                                  ),
                                );
                                // SharedPreferences preferences =
                                //       await SharedPreferences.getInstance();
                                //   preferences.setString('phone', 'null');
                                //   Navigator.of(context).pushAndRemoveUntil(
                                //       MaterialPageRoute(
                                //           builder: (context) => IntroPage()),
                                //       (r) => false);
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
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        '${localization.appVersion} ${_packageInfo.version}:${_packageInfo.buildNumber}',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      Container(height: 0)
                    ],
                  ),
                ],
              ),
            ),
            _buildCoverImage(screenSize),
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
                            ChatRoom.shared.setSettingsStream();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SettingsMainPage(),
                              ),
                            ).whenComplete(
                              () => setState(() {
                                ChatRoom.shared.closeSettingsStream();
                              }),
                            );
                          },
                          child: Ink(
                            child: Image.asset(
                              "assets/images/settings.png",
                              width: 35,
                            ),
                            // child: Text("${localization.exit}",
                            //     style: TextStyle(
                            //         color: Colors.white, fontSize: 18)),
                          )),
                    ),
                    SizedBox(width: 15),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(width: 10),
                    _buildProfileImage(),
                    SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: _buildFullName(),
                          ),
                          SizedBox(height: 15),
                          Text(
                            "${user.identified ? localization.identified : localization.notIdentified}",
                            style: TextStyle(
                              color: whiteColor,
                            ),
                          )
                        ],
                      ),
                    ),
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
                        progressColor: primaryColor,
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

var api = Api();

class CustomDialog extends StatelessWidget {
  final String title, description, buttonText;
  final CachedNetworkImage image;

  CustomDialog({
    @required this.title,
    @required this.description,
    @required this.buttonText,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        //...bottom card part,
        Container(
          margin: EdgeInsets.only(top: Consts.avatarRadius),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.padding),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  // top: Consts.avatarRadius + Consts.padding,
                  top: Consts.padding + 24,
                  bottom: Consts.padding,
                  left: Consts.padding,
                  right: Consts.padding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // To make the card compact
                  children: <Widget>[
                    title != null
                        ? Text(
                            title,
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : Container(),
                    // SizedBox(height: 16.0),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18.0, color: blackPurpleColor),
                    ),
                    SizedBox(height: 24.0),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: blackPurpleColor,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(Consts.padding),
                      bottomRight: Radius.circular(Consts.padding)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      child: FlatButton(
                        onPressed: () async {
                          var preferences =
                              await SharedPreferences.getInstance();

                          // await api.updateFCM('logoutToken');
                          preferences.setString('phone', 'null');
                          ChatRoom.shared.channel = null;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => IntroPage(),
                            ),
                            (r) => false,
                          );
                          ChatsDB _chatsDB = ChatsDB();
                          _chatsDB.deleteAll();
                          await api.logOutHttp().then((result) {
                            print(result);
                            if (result['message'] == 'Not authenticated' &&
                                result['success'].toString() == 'false') {
                              logOut(context);
                            } else {
                              if (result['success'] == true) {
                              } else {
                                print(
                                    'else because we cannot log out with no reason $result');
                              }
                            }
                          });
                        },
                        child: Container(
                            height: 50,
                            child: Center(
                                child: Text("${localization.yes}",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500)))),
                      ),
                    ),
                    Container(width: 1, height: 50, color: Colors.white),
                    Expanded(
                      child: FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // To close the dialog
                        },
                        child: Container(
                            height: 50,
                            child: Center(
                                child: Text("${localization.no}",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500)))),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        //...top circlular image part,
        // Positioned(
        //   left: Consts.padding,
        //   right: Consts.padding,
        //   child: CircleAvatar(
        //     backgroundColor: Colors.transparent,
        //     radius: Consts.avatarRadius,
        //     child: ClipOval(child: image),
        //   ),
        // ),
      ],
    );
  }
}

class Consts {
  Consts._();

  static const double padding = 16.0;
  static const double avatarRadius = 66.0;
}