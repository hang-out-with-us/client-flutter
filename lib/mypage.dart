import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'login.dart';

class MyPage extends StatelessWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _storage = const FlutterSecureStorage();

    logout() async {
      await _storage.delete(key: "token");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Login()));
    }

    return Scaffold(
      body: Center(
        child: OutlinedButton(onPressed: logout, child: Text("로그아웃")),
      ),
    );
  }
}
