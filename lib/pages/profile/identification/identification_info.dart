import 'package:flutter/material.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_appbar_widget.dart';
import 'package:indigo24/services/localization/localization.dart';
import 'package:indigo24/widgets/video/video_player_widget.dart';

class InentificationInfoPage extends StatelessWidget {
  final TextStyle primaryTS = TextStyle(color: primaryColor);
  final TextStyle secondaryTS = TextStyle(
    color: blackPurpleColor,
    fontSize: 16,
  );
  final SizedBox defaultSpace = SizedBox(height: 20);
  final String path = assetsPath + 'identification/';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IndigoAppBarWidget(
        title: Localization.language.instruction,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Localization.language.identificationNote,
                style: primaryTS,
              ),
              stepHeader(
                text: Localization.language.identificationStepOne,
                step: 1,
                asset: 'buttonUIK',
              ),
              stepHeader(
                text: Localization.language.identificationStepTwo,
                step: 2,
                asset: 'formaZapolneniya',
              ),
              stepHeader(
                text: Localization.language.identificationStepThree,
                step: 3,
                asset: 'vvodIIN',
              ),
              stepHeader(
                text: Localization.language.identificationStepFour,
                step: 4,
                asset: 'vyborPhoto',
                exampleAsset: 'primerSelfie',
              ),
              stepHeader(
                text: Localization.language.identificationStepFive,
                step: 5,
                asset: 'vyborVideo',
                exampleAsset: 'primerVideo',
                image: false,
              ),
              stepHeader(
                text: Localization.language.identificationStepSix,
                step: 6,
                asset: 'udosSperedi',
                exampleAsset: 'primerUdos1',
              ),
              stepHeader(
                text: Localization.language.identificationStepSeven,
                step: 7,
                asset: 'udosSzadi',
                exampleAsset: 'primerUdos2',
              ),
              stepHeader(
                text: Localization.language.identificationStepEight,
                step: 8,
                asset: 'uspeshno',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column stepHeader({
    @required String text,
    @required int step,
    @required asset,
    bool image = true,
    String exampleAsset,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        defaultSpace,
        Text(
          Localization.language.step.toUpperCase() + '$step:',
          style: secondaryTS,
        ),
        Text(
          text,
          style: primaryTS,
        ),
        defaultSpace,
        Center(
          child: Image.asset(path + asset + '.png'),
        ),
        if (exampleAsset != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              defaultSpace,
              Text(
                Localization.language.example + ':',
                style: primaryTS,
              ),
              defaultSpace,
              image
                  ? Center(
                      child: Image.asset(path + exampleAsset + '.png'),
                    )
                  : Center(
                      child: VideoPlayerWidget(
                        'https://indigo24.com/video/primerVideo.mov',
                        "network",
                      ),
                    ),
              defaultSpace,
            ],
          )
      ],
    );
  }
}
