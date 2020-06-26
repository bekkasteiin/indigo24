
import 'package:flutter/material.dart';

// const Image backgroundPreview = Image.asset("assets/images/preview_background.png");
const ImageProvider previewBackgoundProvider = AssetImage("assets/images/preview_background.png");

const ImageProvider introBackgroundProvider = AssetImage("assets/images/background_login.png");


final Image backgroundForChat = Image(
  image: AssetImage('assets/images/background_chat.png'),
  fit: BoxFit.fill,
);

const ImageProvider chatBackgroundProvider = ExactAssetImage("assets/images/background_chat.png");