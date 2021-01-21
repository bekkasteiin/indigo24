import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indigo24/pages/chat/chat_models/chat_model.dart';
import 'package:indigo24/pages/chat/chat_models/hive_names.dart';
import 'package:indigo24/pages/chat/chat_models/messages_model.dart';
import 'package:indigo24/widgets/alerts/indigo_logout.dart';
import 'package:indigo24/pages/auth/intro.dart';
import 'package:indigo24/pages/profile/settings/settings_main.dart';
import 'package:indigo24/services/api/http/api.dart';
import 'package:indigo24/services/shared_preference/helper.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/api/socket/socket.dart';
import 'package:indigo24/services/localization/localization.dart';
import 'package:indigo24/services/shared_preference/shared_strings.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/alerts/indigo_alert.dart';
import 'package:indigo24/widgets/alerts/indigo_show_dialog.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_modal_action_widget.dart';
import 'package:indigo24/widgets/photo/photo.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:indigo24/services/user.dart' as user;

import 'identification/identification_list.dart';
import 'profile_settings.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

bool needToAskCity = true;

class _UserProfilePageState extends State<UserProfilePage>
    with AutomaticKeepAliveClientMixin {
  Api _api;

  dynamic response;
  File _image;

  final picker = ImagePicker();

  double uploadPercent = 0.0;
  bool isUploading = false;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

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
              child: Text('${Localization.language.selectOption}'),
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
                          showIndigoDialog(
                            context: context,
                            builder: CustomDialog(
                              description: "${result["message"]}",
                              yesCallBack: () {
                                Navigator.of(context).pop();
                              },
                            ),
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
    showIndigoDialog(
      context: context,
      builder: errorDialog,
    );
  }

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
        ).then((r) async {
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
        });
      }
    }
  }

  Widget _buildProfileImage() {
    return InkWell(
      onTap: () {
        showIndigoBottomDialog(
          context: context,
          children: [
            IndigoModalActionWidget(
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
                          BoxDecoration(color: transparentColor),
                    ),
                  ),
                );
              },
              title: Localization.language.watch,
            ),
            IndigoModalActionWidget(
              onPressed: () {
                getImage(ImageSource.camera);
                Navigator.pop(context);
              },
              title: Localization.language.camera,
            ),
            IndigoModalActionWidget(
              onPressed: () {
                getImage(ImageSource.gallery);
                Navigator.pop(context);
              },
              title: Localization.language.gallery,
            ),
          ],
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
          width: screenSize.width / 1.2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(header.toUpperCase()),
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
          width: screenSize.width / 1.2,
          height: 0.5,
          color: brightGreyColor5,
          margin: EdgeInsets.only(top: 4.0),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                        Localization.language.phoneNumber,
                        user.phone,
                      ),
                      _buildSection(
                        screenSize,
                        Localization.language.email,
                        user.email,
                      ),
                      if (user.country != '')
                        _buildSection(
                          screenSize,
                          Localization.language.country,
                          user.country,
                        ),
                      if (user.city != '')
                        _buildSection(
                          screenSize,
                          Localization.language.city,
                          user.city,
                        ),
                      SizedBox(height: 30),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      SizedBox(height: 10),
                      Text(
                        '${Localization.language.appVersion} ${_packageInfo.version}:${_packageInfo.buildNumber}',
                        style: TextStyle(
                          color: greyColor,
                        ),
                      ),
                      // if (user.identified != 1)
                      //   Column(
                      //     children: [
                      //       SizedBox(height: 15),
                      //       ConstrainedBox(
                      //         constraints: BoxConstraints(
                      //             maxWidth:
                      //                 MediaQuery.of(context).size.width * 0.42),
                      //         child: Container(
                      //           decoration: BoxDecoration(
                      //             boxShadow: [
                      //               BoxShadow(
                      //                 color: blackColor,
                      //                 blurRadius: 10.0,
                      //                 spreadRadius: -10,
                      //                 offset: Offset(0.0, 0.0),
                      //               )
                      //             ],
                      //           ),
                      //           child: ButtonTheme(
                      //             minWidth:
                      //                 MediaQuery.of(context).size.width * 0.42,
                      //             height: 50,
                      //             child: RaisedButton(
                      //               onPressed: () {
                      //                 Navigator.push(
                      //                   context,
                      //                   MaterialPageRoute(
                      //                     builder: (context) =>
                      //                         InentificationListPage(),
                      //                   ),
                      //                 );
                      //               },
                      //               child: FittedBox(
                      //                 fit: BoxFit.fitWidth,
                      //                 child: Text(
                      //                   "${Localization.language.identification}",
                      //                   style: TextStyle(
                      //                     color: primaryColor,
                      //                     fontWeight: FontWeight.bold,
                      //                   ),
                      //                 ),
                      //               ),
                      //               color: whiteColor,
                      //               textColor: whiteColor,
                      //               shape: RoundedRectangleBorder(
                      //                 borderRadius: BorderRadius.circular(
                      //                   10.0,
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
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
                                color: blackColor,
                                blurRadius: 10.0,
                                spreadRadius: -10,
                                offset: Offset(0.0, 0.0),
                              )
                            ],
                          ),
                          child: ButtonTheme(
                            minWidth: MediaQuery.of(context).size.width * 0.42,
                            height: 50,
                            child: RaisedButton(
                              onPressed: () async {
                                if (await canLaunch(
                                  'https://indigo24.com/contacts.html',
                                )) {
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
                                  "${Localization.language.support}",
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
                          maxWidth: MediaQuery.of(context).size.width * 0.42,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: blackColor,
                                blurRadius: 10.0,
                                spreadRadius: -10,
                                offset: Offset(0.0, 0.0),
                              ),
                            ],
                          ),
                          child: ButtonTheme(
                            minWidth: MediaQuery.of(context).size.width * 0.42,
                            height: 50,
                            child: RaisedButton(
                              onPressed: () async {
                                showIndigoDialog(
                                  context: context,
                                  builder: CustomDialog(
                                    description:
                                        "${Localization.language.wantToExit}?",
                                    yesCallBack: () async {
                                      var api = Api();
                                      var preferences =
                                          await SharedPreferences.getInstance();
                                      Hive.box<MessageModel>(HiveBoxes.messages)
                                          .clear();
                                      Hive.box<ChatModel>(HiveBoxes.chats)
                                          .clear();

                                      preferences.setString(
                                          SharedStrings.phone, 'null');
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
                                  '${Localization.language.exit}',
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
                  image: AssetImage('${assetsPath}cover.png'),
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
                      color: transparentColor,
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
                              "${assetsPath}settings.png",
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
                                Text(
                                  "${user.identified == 1 ? Localization.language.identified : user.identified == 0 ? Localization.language.notIdentified : user.identified == 1 ? Localization.language.simpleIdentified : Localization.language.notIdentified}",
                                  style: TextStyle(
                                    color: whiteColor,
                                  ),
                                ),
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
                                '${assetsPath}pencil.png',
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}
