import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'home.dart';
import 'login.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  bool isTokenExist = await _tokenCheck();
  runApp(MyApp(isTokenExist: isTokenExist));
}

_tokenCheck() async {
  var _storage = const FlutterSecureStorage();
  if (await _storage.read(key: "token") != null) {
    return true;
  } else {
    return false;
  }
}

class MyApp extends StatelessWidget {
  final bool isTokenExist;

  const MyApp({super.key, required this.isTokenExist});

  @override
  Widget build(BuildContext context) {
    if (isTokenExist) {
      return const MaterialApp(
        home: Home(),
      );
    } else {
      return const MaterialApp(
        home: Login(),
      );
    }
  }
}
