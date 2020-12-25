import 'package:indigo24/services/localization/localization.dart';

class MessageTypeHelper {
  identifyType(type) {
    switch ('$type') {
      case '0':
        return '${Localization.language.textMessage}';
        break;
      case '1':
        return '${Localization.language.photo}';
        break;
      case '2':
        return '${Localization.language.document}';
        break;
      case '3':
        return '${Localization.language.voiceMessage}';
        break;
      case '4':
        return '${Localization.language.video}';
        break;
      case '7':
        return '${Localization.language.systemMessage}';
        break;
      // case '8':
      // return 'Дивайдер сообщение';
      // break;
      case '9':
        return '${Localization.language.location}';
        break;
      case '10':
        return '${Localization.language.reply}';
        break;
      case '11':
        return '${Localization.language.money}';
        break;
      case '12':
        return '${Localization.language.link}';
        break;
      case '13':
        return '${Localization.language.forwardedMessage}';
        break;
      default:
        return '${Localization.language.message}';
    }
  }
}
