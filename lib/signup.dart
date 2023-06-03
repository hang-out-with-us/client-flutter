import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'home.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String email = "";
  String password = "";
  String name = "";
  int age = 20;

  //20에서 40까지
  List<int> list = List.generate(21, (index) => index + 20);

  bool isEmail(String email) {
    // 정규식 패턴
    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    // 정규식 객체 생성
    RegExp regex = new RegExp(pattern);
    // 검사 결과 반환
    return regex.hasMatch(email);
  }

  _signup() async {
    if (email == "" || password == "" || name == "") {
      Fluttertoast.showToast(
        msg: "모든 항목을 입력해주세요",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }
    if (!isEmail(email)) {
      Fluttertoast.showToast(
        msg: "이메일 형식이 올바르지 않습니다",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }
    if (password.length < 8) {
      Fluttertoast.showToast(
        msg: "비밀번호는 8자 이상이어야 합니다",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }
    Response res = await http.post(Uri.parse(dotenv.env['SIGNUP_URL']!),
        headers: {"Content-Type": "application/json"},
        body: json.encode(
            {'name': name, 'email': email, 'password': password, 'age': age}));
    if (res.statusCode == 200) {
      Navigator.pop(context);
    }
    if (res.statusCode == 500) {
      Fluttertoast.showToast(
        msg: "이미 존재하는 이메일입니다",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
              decoration: InputDecoration(hintText: "홍길동"),
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              }),
          TextField(
              decoration: InputDecoration(hintText: "example@email.com"),
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              }),
          TextField(
              decoration: InputDecoration(hintText: "password"),
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              }),
          DropdownButton(
              value: age,
              items: list.map<DropdownMenuItem>((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  age = value;
                });
              }),
          OutlinedButton(onPressed: _signup, child: Text("회원가입"))
        ],
      ),
    ));
  }
}

class SignupOauth2 extends StatefulWidget {
  const SignupOauth2({Key? key}) : super(key: key);

  @override
  State<SignupOauth2> createState() => _SignupOauth2State();
}

class _SignupOauth2State extends State<SignupOauth2> {
  String nickname = "";
  int age = 20;
  List<int> list = List.generate(21, (index) => index + 20);
  final _storage = FlutterSecureStorage();

  _signup() async {
    String token = await _storage.read(key: 'token') as String;
    String refreshToken = await _storage.read(key: 'refreshToken') as String;
    if (nickname == "") {
      Fluttertoast.showToast(
        msg: "닉네임을 입력해주세요",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }
    Response res = await http.put(Uri.parse(dotenv.env['MEMBER_UPDATE_URL']!),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer " + token,
          "RefreshToken": refreshToken
        },
        body: json.encode({'name': nickname, 'age': age}));
    if (res.statusCode == 200) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Home()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            decoration: InputDecoration(hintText: "닉네임"),
            onChanged: (value) {
              setState(() {
                nickname = value;
              });
            },
          ),
          DropdownButton(
              value: age,
              items: list.map<DropdownMenuItem>((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  age = value;
                });
              }),
          OutlinedButton(onPressed: _signup, child: Text("회원가입"))
        ],
      ),
    ));
  }
}
