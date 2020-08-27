//  String domen = 'com';
String domen = 'xyz';

String avatarUrl = domen == 'com'
    ? 'https://media.indigo24.com/avatars/'
    : 'https://indigo24.xyz/uploads/avatars/';
String groupAvatarUrl = 'https://media.chat.indigo24.$domen/media/group/';
String uploadTapes = 'https://indigo24.$domen/uploads/tapes/';

String socket = 'wss://chat.indigo24.$domen:9502';

String baseUrl = 'https://api.indigo24.$domen/';

String mediaChat = 'https://media.chat.indigo24.$domen/upload';

String logos = 'https://api.indigo24.$domen/logos/';

const String ownerRole = '100';
const String adminRole = '50';
const String memberRole = '2';

String withdrawCommission = "";
String withdrawMinCommission = "";
String withdrawMin = "";
String withdrawMax = "";

String refillCommission = "";
String refillMinCommission = "";
String refillMin = "";
String refillMax = "";
