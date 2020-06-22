import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker_flutter/src/image/asset_data_image.dart';
import 'package:image_picker_flutter/src/image_picker.dart';
import 'package:image_picker_flutter/src/model/asset_data.dart';
import 'package:image_picker_flutter/src/page/ui/dialog_loading.dart';
import 'package:image_picker_flutter/src/page/ui/image_picker_app_bar.dart';
import 'package:image_picker_flutter/src/utils.dart';

import 'drop_header_popup.dart';


var singleFile;

class SingleImagePickerPage extends StatefulWidget {
  final ImagePickerType type;
  final Widget back;
  final Decoration decoration;
  final Language language;
  final ImageProvider placeholder;
  final Color appBarColor;
  final Widget emptyView;

  const SingleImagePickerPage({
    Key key,
    this.type = ImagePickerType.imageAndVideo,
    this.back,
    this.decoration,
    this.language,
    this.placeholder,
    this.appBarColor = Colors.blue,
    this.emptyView,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SingleImagePickerPageState();
  }
}

class SingleImagePickerPageState extends State<SingleImagePickerPage> {
  final List<AssetData> data = [];
  bool isFirst = true;

  @override
  void dispose() {
    Utils.cancelAll();
    super.dispose();
  }

  void getData(String folder) {
    Utils.getImages(folder)
      ..then((data) {
        this.data.clear();
        this.data.addAll(data);
        this.isFirst = false;
      })
      ..whenComplete(() {
        if (mounted) {
          setState(() {});
          Utils.log("whenComplete");
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ImagePickerAppBar(
        context: context,
        center: DropHeader(
          type: widget.type,
          onSelect: (item) {
            getData(item);
          },
        ),
        language: widget.language,
        back: widget.back ??
            Icon(
              Utils.back,
              color: Colors.white,
            ),
        onBackCallback: () {
          Navigator.of(context).pop();
        },
        decoration: widget.decoration,
        appBarColor: widget.appBarColor,
      ),
      body: body(),
    );
  }

  Widget body() {
    if (isFirst) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (data.isEmpty) {
      return Center(child: widget.emptyView ?? Text(widget.language.empty));
    } else {
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) => _createItem(data[index]),
        itemCount: data.length,
        padding: EdgeInsets.fromLTRB(
          8,
          8,
          8,
          8 + MediaQuery.of(context).padding.bottom,
        ),
      );
    }
  }

  Widget _createItem(AssetData data) {
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: <Widget>[
        FadeInImage(
          placeholder: widget.placeholder ?? Utils.placeholder,
          image: AssetDataImage(
            data,
            targetWidth: Utils.width2px(context, ratio: 3),
            targetHeight: Utils.width2px(context, ratio: 3),
          ),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        RawMaterialButton(
          constraints: BoxConstraints.expand(),
          onPressed: () {
            LoadingDialog.showLoadingDialog(context);
            Utils.convertSingleData(data).whenComplete(() {
              singleFile = data;
              Navigator.of(context)..pop()..pop(data);
            });
          },
          shape: CircleBorder(),
        ),
        iconVideo(data),
      ],
    );
  }

  Widget iconVideo(AssetData data) {
    if (data.isImage) {
      return SizedBox.shrink();
    }
    return Icon(
      Utils.video,
      color: widget.appBarColor ?? Colors.blue,
    );
  }
}


// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker_flutter/image_picker_flutter.dart';
// import 'package:permission_handler/permission_handler.dart';

// class PickerPage extends StatefulWidget {
//   @override
//   _PickerPageState createState() => _PickerPageState();
// }

// class _PickerPageState extends State<PickerPage> {
  // List<AssetData> _data = [];

//   @override
//   void initState() {
//     // ImagePicker.singlePicker(
//     //   context, 
//     //   decoration: BoxDecoration(
//     //     color: Colors.red
//     //   ),
//     //   singleCallback: (data) {
//     //     print(data.path);
//     //     setState(() {
//     //       _data
//     //         ..removeWhere((a) => a == data)
//     //         ..add(data);
//     //     });
//     //   }
//     // );
//     PaintingBinding.instance.imageCache
//       ..maximumSize = 1000
//       ..maximumSizeBytes = 500 << 20;
//     super.initState();
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         child: SingleImagePickerPage(
//           type: ImagePickerType.onlyImage,
//           language: Language(),
//           // placeholder: AssetImage("assets/images/camera.png"),
//           // decoration: decoration,
//           appBarColor: Colors.blue,
//           back: IconButton(
//             icon: Icon(Icons.arrow_back_ios, color:Colors.white), 
//             onPressed: (){
//             }
//           ),
//           // emptyView: Text("empty"),
//         ),
//       )
//       // GridView.builder(
//       //   padding: EdgeInsets.all(8),
//       //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//       //     crossAxisCount: 3,
//       //     mainAxisSpacing: 8,
//       //     crossAxisSpacing: 8,
//       //   ),
//       //   itemBuilder: (context, index) {
//       //     return Stack(
//       //       alignment: AlignmentDirectional.center,
//       //       children: <Widget>[
              // Image(
              //   image: AssetDataImage(
              //     _data[index],
              //     targetWidth: Utils.width2px(context, ratio: 3),
              //     targetHeight: Utils.width2px(context, ratio: 3),
              //   ),
              //   fit: BoxFit.cover,
              //   width: double.infinity,
              //   height: double.infinity,
              // ),
//       //         iconVideo(_data[index]),
//       //       ],
//       //     );
//       //   },
//       //   itemCount: _data.length,
//       // ),
//       // bottomNavigationBar: Container(
//       //   color: Colors.grey,
//       //   height: MediaQuery.of(context).size.width / 4 +
//       //       MediaQuery.of(context).padding.bottom,
//       //   padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
//       //   alignment: AlignmentDirectional.center,
//       //   child: GridView.count(
//       //     crossAxisCount: 2,
//       //     childAspectRatio: 4,
//       //     shrinkWrap: true,
//       //     physics: NeverScrollableScrollPhysics(),
//       //     children: <Widget>[
//       //       RawMaterialButton(
//       //         onPressed: () {
//       //           ImagePicker.mulPicker(
//       //             context,
//       //             data: _data,
//       //             mulCallback: (data) {
//       //               print(data.map((a){
//       //                 return a.path;
//       //               }));
//       //               setState(() {
//       //                 _data = data;
//       //               });
//       //             },
//       //           );
//       //         },
//       //         fillColor: Colors.blue,
//       //         child: Text("MulImagePikcer"),
//       //       ),
//       //       RawMaterialButton(
//       //         onPressed: () {
//       //           ImagePicker.singlePicker(context, singleCallback: (data) {
//       //             print(data.path);
//       //             setState(() {
//       //               _data
//       //                 ..removeWhere((a) => a == data)
//       //                 ..add(data);
//       //             });
//       //           });
//       //         },
//       //         fillColor: Colors.blue,
//       //         child: Text("SingleImagePikcer"),
//       //       ),
//       //       RawMaterialButton(
//       //         onPressed: () {
//       //           ImagePicker.takePicture((a) {
//       //             print(a.path);
//       //             setState(() {
//       //               _data.add(a);
//       //             });
//       //           });
//       //         },
//       //         fillColor: Colors.blue,
//       //         child: Text("takePicture"),
//       //       ),
//       //       RawMaterialButton(
//       //         onPressed: () {
//       //           ImagePicker.takeVideo((a) {
//       //             print(a.path);
//       //             setState(() {
//       //               _data.add(a);
//       //             });
//       //           });
//       //         },
//       //         fillColor: Colors.blue,
//       //         child: Text("takeVideo"),
//       //       ),
//       //     ],
//       //   ),
//       // ),
//     );
//   }

//   Widget iconVideo(AssetData data) {
//     if (data.isImage) {
//       return Container(
//         width: 0,
//         height: 0,
//       );
//     }
//     return Icon(
//       Utils.video,
//       color: Colors.blue,
//     );
//   }
// }