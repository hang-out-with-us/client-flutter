import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';

import 'chat.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  FlutterSecureStorage _storage = const FlutterSecureStorage();
  List rooms = [];

  _getChatRooms() async {
    String? token = await _storage.read(key: "token");
    Response res = await get(
      Uri.parse("http://localhost:8080/chat/rooms"),
      headers: {"Authorization": "Bearer " + token!},
    );
    if (res.statusCode == 200) {
      print(res.body);
      setState(() {
        rooms = jsonDecode(res.body);
      });
    }
  }

  @override
  void initState() {
    _getChatRooms();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(children: [
          for (var room in rooms)
            ListTile(
                title: TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(roomId: room["id"]),
                    ));
              },
              child: Text(room["id"].toString()),
            ))
        ]),
      ),
    );
  }
}
