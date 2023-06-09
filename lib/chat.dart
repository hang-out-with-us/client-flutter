import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hang_out_with_us/httpInterceptor.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final int roomId;

  const ChatPage({Key? key, required this.roomId}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState(roomId: roomId);
}

class _ChatPageState extends State<ChatPage> {
  final int roomId;
  final Dio dio;

  _ChatPageState({required this.roomId})
      : dio = Dio()..interceptors.add(HttpInterceptor());

  final _storage = const FlutterSecureStorage();
  StompClient? stompClient;
  List<types.Message> _messages = [];
  late types.User user;
  String email = "";
  var _database;

  void _getMessages() async {
    Response res = await dio.get(
      dotenv.env['GET_MESSAGES_URL']! + roomId.toString(),
    );
    if (res.statusCode == 200) {
      print(res.data);
      List messages = res.data;
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
    _insertMessage(message);
  }

  _getUser() async {
    email = await _storage.read(key: "email") as String;
    user = types.User(id: email);
  }

  _connect() async {
    String? token = await _storage.read(key: "token");
    String? refreshToken = await _storage.read(key: "refreshToken");

    Map<String, dynamic> tokenDecoded = JwtDecoder.decode(token!);
    Map<String, dynamic> refreshTokenDecoded = JwtDecoder.decode(refreshToken!);

    if (tokenDecoded["exp"] < DateTime.now().millisecondsSinceEpoch / 1000) {
      if (refreshTokenDecoded["exp"] <
          DateTime.now().millisecondsSinceEpoch / 1000) {
        Navigator.pushNamed(context, '/login');
      } else {
        String xRefreshToken =
            await _storage.read(key: "refreshToken") as String;
        var res = await dio.get(dotenv.env["REFRESH_TOKEN_URL"]!,
            options: Options(headers: {"X-Refresh-Token": xRefreshToken}));
        var data = res.data;
        token = data["token"];
        refreshToken = data["refreshToken"];
      }
    }

    stompClient = StompClient(
        config: StompConfig.SockJS(
      url: dotenv.env['STOMP_CONNECT_URL']!,
      onConnect: _onConnect,
      onWebSocketError: (dynamic error) => print(error.toString()),
      stompConnectHeaders: {
        "Authorization": "Bearer " + token!,
        "refreshToken": refreshToken!
      },
      webSocketConnectHeaders: {
        "Authorization": "Bearer " + token!,
        "refreshToken": refreshToken!
      },
    ));
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

//save chat in database using sqflite

  _openDatabase() async {
    var database = await openDatabase(
      path.join(await getDatabasesPath(), 'chat.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE chat(id INTEGER PRIMARY KEY, content TEXT, chatRoomId INTEGER, sender TEXT, createdDate TEXT)",
        );
      },
      version: 1,
    );
    setState(() {
      _database = database;
    });
    _readMessage();
  }

  _insertMessage(types.TextMessage message) async {
    final Map<String, dynamic> messageDto = {
      'content': message.text,
      'chatRoomId': roomId,
      'sender': message.author.id,
      'createdDate': message.createdAt,
    };
    await _database.insert(
      'chat',
      messageDto,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  _readMessage() async {
    final List<Map<String, dynamic>> messages = await _database
        .query('chat', where: "chatRoomId = ?", whereArgs: [roomId]);
    for (var message in messages) {
      types.TextMessage parsedMessage = types.TextMessage(
          author: types.User(id: message['sender'] as String),
          text: message['content'] as String,
          id: message['id'].toString(),
          createdAt: int.parse(message['createdDate']));
      _messages.insert(0, parsedMessage);
    }
  }

  @override
  void initState() {
    _openDatabase();
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
