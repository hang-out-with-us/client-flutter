import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final roomId;

  const ChatPage({Key? key, required this.roomId}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState(roomId: roomId);
}

class _ChatPageState extends State<ChatPage> {
  final roomId;

  _ChatPageState({required this.roomId});

  final _storage = const FlutterSecureStorage();
  StompClient? stompClient;
  List<types.Message> _messages = [];
  late types.User user;
  String email = "";

  void _getMessages() async {
    String? token = await _storage.read(key: "token");
    Response res = await get(
      Uri.parse("http://localhost:8080/chat/" + roomId.toString()),
      headers: {"Authorization": "Bearer " + token!},
    );
    if (res.statusCode == 200) {
      print(res.body);
      List messages = jsonDecode(res.body);
      for (var message in messages) {
        _parseMessage(message);
      }
    }
  }

  void _onConnect(StompFrame frame) {
    print("connected");
    stompClient!.subscribe(
        destination: '/topic/chat/' + roomId.toString(),
        callback: (frame) {
          print(frame.body);
          Map data = jsonDecode(frame.body!);
          if (data['sender'] != email) {
            stompClient!.send(
              destination: '/app/read',
              body: jsonEncode({
                'id': data['id'],
              }),
            );
          }
          _parseMessage(data);
        });
  }

  _parseMessage(Map data) {
    types.TextMessage message = types.TextMessage(
        author: types.User(id: data['sender'] as String),
        text: data['content'] as String,
        id: const Uuid().v4(),
        createdAt: DateTime.parse(data['createdDate']).millisecondsSinceEpoch);
    setState(() {
      _messages.insert(0, message);
    });
  }

  _getUser() async {
    email = await _storage.read(key: "email") as String;
    user = types.User(id: email);
  }

  _connect() async {
    String? token = await _storage.read(key: "token");
    stompClient = StompClient(
        config: StompConfig.SockJS(
            url: 'http://localhost:8080/ws',
            onConnect: _onConnect,
            onWebSocketError: (dynamic error) => print(error.toString()),
            stompConnectHeaders: {"Authorization": "Bearer " + token!},
            webSocketConnectHeaders: {"Authorization": "Bearer " + token!}));
    stompClient!.activate();
  }

  _send(types.PartialText message) async {
    final messageDto = {
      'content': message.text,
      'chatRoomId': roomId,
      'sender': email,
    };
    stompClient!.send(
      destination: '/app/message',
      body: jsonEncode(messageDto),
    );
  }

  @override
  void initState() {
    _getMessages();
    _connect();
    _getUser();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    stompClient?.deactivate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test"),
      ),
      body: Chat(
          messages: _messages,
          onSendPressed: _send,
          user: types.User(id: email)),
    );
  }
}
