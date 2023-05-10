import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'chat.dart';
import 'httpInterceptor.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  FlutterSecureStorage _storage = const FlutterSecureStorage();
  List rooms = [];
  final dio;

  _ChatListState() : dio = Dio()..interceptors.add(HttpInterceptor());

  _getChatRooms() async {
    Response res = await dio.get(
      dotenv.env["CHAT_ROOM_LIST"]!,
    );
    if (res.statusCode == 200) {
      print(res.data);
      setState(() {
        rooms = res.data;
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
