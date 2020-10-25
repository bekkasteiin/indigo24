// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:web_socket_channel/io.dart';

// ChatStream chatStream = ChatStream();
// ChatsStream chatsStream = ChatsStream();
// Socket socket = Socket();

// main(List<String> args) {
//   socket.stream.listen((data) {
//     chatsStream._controller.add(data);
//     chatStream._controller.add(data);
//     print('main $data');
//   });
//   socket.channel.sink.add('Hello');
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: ChatsPage());
//   }
// }

// class ChatsPage extends StatefulWidget {
//   @override
//   _ChatsPageState createState() => _ChatsPageState();
// }

// class _ChatsPageState extends State<ChatsPage> {
//   StreamSubscription subscription;

//   @override
//   void initState() {
//     subscription = chatsStream.stream.listen((event) {
//       print('Chats event $event');
//     });
//     super.initState();
//   }

//   @override
//   void dispose() {
//     subscription.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     print(chatsStream._controller.hasListener);
//     print(chatStream._controller.hasListener);
//     return Scaffold(
//       body: Center(
//         child: Row(
//           children: [
//             FlatButton(
//               child: Text('Chats'),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ChatPage(),
//                   ),
//                 );
//               },
//             ),
//             FlatButton(
//               child: Text('add'),
//               onPressed: () {
//                 socket.channel.sink.add('Hi from Chats');
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class ChatPage extends StatefulWidget {
//   @override
//   _ChatPageState createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   StreamSubscription subscription;
//   @override
//   void initState() {
//     subscription = chatStream.stream.listen((e) {
//       print('e from $e');
//     });

//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     subscription.cancel();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: FlatButton(
//           child: Text('Chat'),
//           onPressed: () {
//             socket.channel.sink.add('Hello from Chat');
//           },
//         ),
//       ),
//     );
//   }
// }

// class Socket {
//   static Socket shared = Socket();
//   IOWebSocketChannel channel =
//       IOWebSocketChannel.connect('ws://echo.websocket.org');
//   get stream => channel.stream;
// }

// abstract class SocketController {
//   StreamController _controller;
//   Stream<String> get stream => _controller.stream;
//   void close() {
//     _controller.close();
//   }
// }

// class ChatStream implements SocketController {
//   @override
//   StreamController _controller = StreamController<String>.broadcast();

//   @override
//   Stream<String> get stream => _controller.stream;

//   @override
//   void close() {
//     _controller.close();
//   }
// }

// class ChatsStream implements SocketController {
//   @override
//   StreamController _controller = StreamController<String>.broadcast();

//   @override
//   Stream<String> get stream => _controller.stream;

//   @override
//   void close() {
//     _controller.close();
//   }
// }
