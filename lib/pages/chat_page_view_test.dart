import 'package:flutter/material.dart';
import 'package:indigo24/services/socket.dart';

class ChatPageView extends StatefulWidget {
  final String username;

  const ChatPageView({
    Key key,
    this.username,
  }) : super(key: key);

  @override
  _ChatPageViewState createState() => _ChatPageViewState();
}

class _ChatPageViewState extends State<ChatPageView> {
  TextEditingController _text = new TextEditingController();
  ScrollController _scrollController = ScrollController();
  var childList = <Widget>[];

  @override
  void initState() {
    super.initState();
    childList.add(Align(
      alignment: Alignment(1, 0),
      child: SendedMessageWidget(
        content: 'Hello',
        time: '21:36 PM',
      ),
    ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Stack(
            fit: StackFit.loose,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.start,
                // mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(
                    height: 65,
                    child: Container(
                      color: Colors.red,
                      child: Row(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                widget.username ?? "Jimi Cooke",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                              Text(
                                "online",
                                style: TextStyle(
                                    color: Colors.white60, fontSize: 12),
                              ),
                            ],
                          ),
                          Spacer(),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                            child: Container(
                              child: ClipRRect(
                                child: Container(
                                    child: SizedBox(), color: Colors.orange),
                                borderRadius: new BorderRadius.circular(50),
                              ),
                              height: 55,
                              width: 55,
                              padding: const EdgeInsets.all(0.0),
                              decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 5.0,
                                        spreadRadius: -1,
                                        offset: Offset(0.0, 5.0))
                                  ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 0,
                    color: Colors.black54,
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    // height: 500,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(
                                'https://i.pinimg.com/564x/6a/50/87/6a508713052ffb6f1686f7441800e34e.jpg'),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.linearToSrgbGamma()),
                      ),
                      child: SingleChildScrollView(
                          controller: _scrollController,
                          reverse: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: childList,
                          )),
                    ),
                  ),
                  Divider(height: 0, color: Colors.black26),
                  // SizedBox(
                  //   height: 50,
                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: TextField(
                        maxLines: 6,
                        minLines: 1,
                        controller: _text,
                        decoration: InputDecoration(
                          // contentPadding: const EdgeInsets.symmetric(horizontal: 5.0),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () {
                              print(_text.text);
                              setState(() {
                                childList.add(Align(
                                  alignment: Alignment(1, 0),
                                  child: SendedMessageWidget(
                                    content: _text.text,
                                    time: '22:40 PM',
                                  ),
                                ));
                                _text.text = '';
                              });
                            },
                          ),
                          border: InputBorder.none,
                          hintText: "enter your message",
                        ),
                      ),
                    ),
                  ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeviderMessageWidget extends StatelessWidget {
  final date;
  const DeviderMessageWidget({Key key, this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width / 2,
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.all(
              Radius.circular(12.0),
            )),
        child: Center(
            child: Text(
          date,
          style: TextStyle(fontSize: 16, color: Color(0xFF5E5E5E)),
        )),
      ),
    );
  }
}

class SendedMessageWidget extends StatelessWidget {
  final String content;
  final String time;
  const SendedMessageWidget({
    Key key,
    this.content,
    this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 120.0,
      ),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(
              right: 8.0, left: 50.0, top: 4.0, bottom: 4.0),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(0),
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15)),
            child: Container(
              color: Colors.white,
              // margin: const EdgeInsets.only(left: 10.0),
              child: Stack(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      right: 12.0, left: 23.0, top: 8.0, bottom: 15.0),
                  child: Text(
                    "${content[0].toUpperCase() + content.substring(1)}",
                    style: TextStyle(fontWeight: FontWeight.w300),
                  ),
                ),
                Positioned(
                  bottom: 1,
                  left: 10,
                  child: Text(
                    time,
                    style: TextStyle(
                        fontSize: 10, color: Colors.black.withOpacity(0.6)),
                  ),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class ReceivedMessageWidget extends StatelessWidget {
  final String content;
  final String time;
  final String image;

  const ReceivedMessageWidget({
    Key key,
    this.content,
    this.time,
    this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        SizedBox(width: 5),
        CircleAvatar(
          backgroundImage: NetworkImage(image),
        ),
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 130.0,
            ),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.only(
                    right: 75.0, left: 8.0, top: 8.0, bottom: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(15),
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  child: Container(
                    color: Color(0xFFF7F7F7),
                    child: Stack(children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 8.0, left: 8.0, top: 8.0, bottom: 15.0),
                        child: Text(
                          "${content[0].toUpperCase() + content.substring(1)}",
                          style: TextStyle(fontWeight: FontWeight.w300),
                        ),
                      ),
                      Positioned(
                        bottom: 1,
                        right: 10,
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                      )
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
