import 'language_interface.dart';

class Language {
  final String title;
  final String code;
  final LanguageInterface languageInterface;

  Language({
    this.title,
    this.code,
    this.languageInterface,
  });
}
