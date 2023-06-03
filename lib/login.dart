import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:hang_out_with_us/httpInterceptor.dart';

import 'home.dart';
import 'signup.dart';

class Login extends StatelessWidget {
  final _storage = const FlutterSecureStorage();

  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String email = "";
    String pwd = "";
    final dio = Dio();
    dio.interceptors.add(HttpInterceptor());
    final _storage = const FlutterSecureStorage();

    _oauth(String provider) async {
      var result = await FlutterWebAuth.authenticate(
        url: dotenv.env['OAUTH_LOGIN_URL']! +
            provider +
            "?redirect_uri=hangoutwithus://",
        callbackUrlScheme: 'hangoutwithus',
      );
      var param = Uri.parse(result).queryParameters;
      if (param['state'] == 'error') {
      } else if (param['state'] == 'signup_not_completed') {
        await _storage.write(key: 'token', value: param['token']);
        await _storage.write(key: 'refreshToken', value: param['refreshToken']);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignupOauth2()));
      } else {
        _storage.write(key: 'token', value: param['token']);
        _storage.write(key: 'refreshToken', value: param['refreshToken']);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home()));
      }
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextField(
            decoration: const InputDecoration(hintText: "아이디"),
            onChanged: (text) => {email = text},
          ),
          TextField(
              obscureText: true,
              decoration: const InputDecoration(hintText: "비밀번호"),
              onChanged: (text) => {pwd = text}),
          OutlinedButton(
              onPressed: () async {
                Map data = {"email": email, "password": pwd};
                var res = await dio.post(dotenv.env['LOGIN_URL']!,
                    data: data,
                    options: Options(
                      headers: {
                        "Content-Type": "application/json",
                      },
                    ));
                if (res.statusCode == 200) {
                  var body = res.data;
                  await _storage.write(key: "token", value: body['token']);
                  await _storage.write(key: "email", value: email);
                  await _storage.write(
                      key: "refreshToken", value: body['refreshToken']);
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => Home()));
                }
              },
              child: const Text("로그인")),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("계정이 없으신가요?"),
              TextButton(
                  onPressed: () => {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Signup()))
                      },
                  child: Text("회원가입"))
            ],
          ),
          OutlinedButton(
              onPressed: () {
                _oauth("google");
              },
              child: Text("구글 로그인"))
        ]),
      ),
    );
  }
}
