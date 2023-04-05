import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'home.dart'; // home.dart 파일 import

class Login extends StatelessWidget {
  final _storage = const FlutterSecureStorage();

  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String email = "";
    String pwd = "";

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextField(
            decoration: const InputDecoration(hintText: "아이디"),
            onChanged: (text) => {email = text},
          ),
          TextField(
              decoration: const InputDecoration(hintText: "비밀번호"),
              onChanged: (text) => {pwd = text}),
          OutlinedButton(
              onPressed: () async {
                Map data = {"email": email, "password": pwd};
                var req = json.encode(data);
                http.Response res = await http.post(
                  Uri.parse(dotenv.env['LOGIN_URL']!),
                  headers: {"Content-Type": "application/json"},
                  body: req,
                );
                if (res.statusCode == 200) {
                  Map decode = json.decode(res.body);
                  await _storage.write(key: "token", value: decode['token']);
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => Home()));
                }
              },
              child: const Text("로그인")),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("계정이 없으신가요?"),
              TextButton(onPressed: () => {}, child: Text("회원가입"))
            ],
          ),
        ]),
      ),
    );
  }
}
