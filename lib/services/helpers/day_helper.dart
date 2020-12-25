import 'package:indigo24/services/localization/localization.dart';

String newIdentifyDay(int day) {
  switch (day) {
    case 1:
      return '${Localization.language.monday}';
      break;
    case 2:
      return '${Localization.language.tuesday}';
      break;
    case 3:
      return '${Localization.language.wednesday}';
      break;
    case 4:
      return '${Localization.language.thursday}';
      break;
    case 5:
      return '${Localization.language.friday}';
      break;
    case 6:
      return '${Localization.language.saturday}';
      break;
    case 7:
      return '${Localization.language.sunday}';
      break;
    default:
      return 'dayOfWeek';
  }
}
