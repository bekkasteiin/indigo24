// import 'dart:io';

// class FileManager {
//   Future<bool> storeFile(dynamic response) async {
//     try {
//       File file = File(response['fileName']);
//       var raf = file.openSync(mode: FileMode.write);
//       raf.writeFromSync(response['data']);
//       await raf.close();
//       return true;
//     } catch (e) {
//       print('uupss: $e');
//       return false;
//     }
//   }
// }
