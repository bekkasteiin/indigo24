import 'package:indigo24/services/localization.dart' as localization;

newIdentifyDay(int day) {
  switch (day) {
    case 1:
      return '${localization.monday}';
      break;
    case 2:
      return '${localization.tuesday}';
      break;
    case 3:
      return '${localization.wednesday}';
      break;
    case 4:
      return '${localization.thursday}';
      break;
    case 5:
      return '${localization.friday}';
      break;
    case 6:
      return '${localization.saturday}';
      break;
    case 7:
      return '${localization.sunday}';
      break;
    default:
      return 'dayOfWeek';
  }
}
