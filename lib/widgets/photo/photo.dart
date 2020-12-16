import 'package:flutter/material.dart';
import 'package:indigo24/style/colors.dart';
import 'package:photo_view/photo_view.dart';
import 'package:indigo24/services/localization.dart' as localization;

import '../indigo_ui_kit/indigo_appbar_widget.dart';

class FullScreenWrapper extends StatelessWidget {
  const FullScreenWrapper({
    this.imageProvider,
    this.loadingBuilder,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialScale,
    this.basePosition = Alignment.center,
    this.filterQuality = FilterQuality.none,
  });

  final ImageProvider imageProvider;
  final LoadingBuilder loadingBuilder;
  final Decoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final dynamic initialScale;
  final Alignment basePosition;
  final FilterQuality filterQuality;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Scaffold(
        appBar: IndigoAppBarWidget(
          title: Text('${localization.photo}',
              style: TextStyle(
                color: blackPurpleColor,
                fontWeight: FontWeight.w400,
                fontSize: 22,
              ),
              textAlign: TextAlign.center),
        ),
        body: SafeArea(
          bottom: false,
          child: ClipRect(
            child: Container(
              color: Colors.white,
              constraints: BoxConstraints.expand(
                height: MediaQuery.of(context).size.height,
              ),
              child: PhotoView(
                imageProvider: imageProvider,
                loadingBuilder: loadingBuilder,
                backgroundDecoration: backgroundDecoration,
                minScale: minScale,
                maxScale: maxScale,
                initialScale: initialScale,
                basePosition: basePosition,
                filterQuality: filterQuality,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
