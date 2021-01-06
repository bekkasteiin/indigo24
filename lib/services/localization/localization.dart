import 'package:indigo24/services/localization/default_lang.dart';
import 'package:indigo24/services/localization/ru.dart';
import 'package:indigo24/services/localization/kz.dart';
import 'package:indigo24/services/localization/en.dart';
import 'package:indigo24/services/localization/uzb.dart';
import 'package:indigo24/services/localization/uz.dart';

import '../helper.dart';

class Localization {
  static DefaultLanguage language = RU();
  Localization();
  static List filters = [
    {'text': 'За неделю', 'code': 'week'},
    {'text': 'За месяц', 'code': 'month'},
    {'text': 'За три месяца', 'code': 'threeMonth'},
    {'text': 'За пол года', 'code': 'halfYear'},
    {'text': 'За период', 'code': 'period'},
  ];
  static var languages = [
    {"title": "English", "code": "en"},
    {"title": "Русский", "code": "ru"},
    {"title": "Қазақша", "code": "kz"},
    {'title': 'Ўзбекча', 'code': 'uz'},
    {'title': 'O\'zbekcha', 'code': 'uzb'}
  ];

  static setLanguage(code) {
    SharedPreferencesHelper.setString('languageCode', '$code');
    switch (code) {
      case 'en':
        language = EN();
        break;
      case 'ru':
        language = RU();
        break;
      case 'kz':
        language = KZ();
        break;
      case 'uz':
        language = UZ();
        break;
      case 'uzb':
        language = UZB();
        break;
      default:
    }
  }
}
