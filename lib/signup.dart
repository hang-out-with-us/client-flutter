import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

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

  _signup() async {
    Response res = await http.post(Uri.parse(dotenv.env['SIGNUP_URL']!),
        headers: {"Content-Type": "application/json"},
        body: json.encode(
            {'name': name, 'email': email, 'password': password, 'age': age}));
    print(res.body);
    print(res.statusCode);
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
    ;
  }
}
