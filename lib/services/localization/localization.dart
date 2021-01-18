import 'package:indigo24/services/localization/language_interface.dart';
import 'package:indigo24/services/localization/languages_impl/ru.dart';
import 'package:indigo24/services/localization/languages_impl/kz.dart';
import 'package:indigo24/services/localization/languages_impl/en.dart';
import 'package:indigo24/services/localization/languages_impl/uzb.dart';
import 'package:indigo24/services/localization/languages_impl/uz.dart';
import 'package:indigo24/services/shared_preference/shared_strings.dart';

import '../shared_preference/helper.dart';
import 'language_model.dart';

class Localization {
  static LanguageInterface language = RU();

  static List filters = [
    {'text': 'За неделю', 'code': 'week'},
    {'text': 'За месяц', 'code': 'month'},
    {'text': 'За три месяца', 'code': 'threeMonth'},
    {'text': 'За пол года', 'code': 'halfYear'},
    {'text': 'За период', 'code': 'period'},
  ];

  static List<Language> languages = [
    Language(title: "English", code: "en", languageInterface: EN()),
    Language(title: "Русский", code: "ru", languageInterface: RU()),
    Language(title: "Қазақша", code: "kz", languageInterface: KZ()),
    Language(title: "Ўзбекча", code: "uz", languageInterface: UZ()),
    Language(title: "O'zbekcha", code: "uzb", languageInterface: UZB()),
  ];
  static setLanguage(code) {
    SharedPreferencesHelper.setString(SharedStrings.languageCode, '$code');
    for (int i = 0; i < Localization.languages.length; i++) {
      if (code == Localization.languages[i].code)
        language = Localization.languages[i].languageInterface;
    }
  }
}
