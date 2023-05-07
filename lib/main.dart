import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'home.dart';
import 'login.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  var _storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    if (_storage.read(key: "token") != null) {
      return const MaterialApp(home: Home());
    } else {
      return const MaterialApp(home: Login());
    }
  }
}

class PostList extends StatelessWidget {
  const PostList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
