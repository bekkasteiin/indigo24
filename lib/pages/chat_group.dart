import 'package:flutter/material.dart';
import 'package:indigo24/pages/chat.dart';


class ChatCreateGroupView extends StatefulWidget {
  @override
  _ChatCreateGroupViewState createState() => _ChatCreateGroupViewState();
}

class _ChatCreateGroupViewState extends State<ChatCreateGroupView> {
  TextEditingController editingController = TextEditingController();

  final Set _saved = Set();

  final duplicateItems = List<String>.generate(10, (i) => "Item $i");
  var items = List<String>();

  void filterSearchResults(String query) {
    List<String> dummySearchList = List<String>();
    dummySearchList.addAll(duplicateItems);
    if (query.isNotEmpty) {
      List<String> dummyListData = List<String>();
      dummySearchList.forEach((item) {
        if (item.contains(query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(duplicateItems);
      });
    }
  }

  int index = 0;
  bool _isChecked = true;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        title: Text(
          "Группа",
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          new IconButton(
            icon: Icon(Icons.forward),
            color: Colors.black,
            onPressed: () {
              print(_saved);
              Navigator.push(
                context,
                new MaterialPageRoute(
                  builder: (context) => new ChatPage('123','123'),
                ),
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  filterSearchResults(value);
                },
                controller: editingController,
                decoration: InputDecoration(
                  hintText: "Поиск",
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.black,
                  height: 0,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Container(
                    height: 70.0,
                    child: CheckboxListTile(
                      secondary: ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: Image.network(
                          'https://www.w3schools.com/howto/img_avatar2.png',
                          height: 40.0,
                        ),
                      ),
                      title: Text(
                        items[index],
                        style: TextStyle(fontSize: 16.0),
                      ),

                      value: _saved.contains(index),
                      onChanged: (val) {
                        setState(() {
                          if(val == true){
                            _saved.add(index);
                          } else{
                            _saved.remove(index);
                          }
                        });
                      },
                      subtitle: Text(
                        'Online',
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
