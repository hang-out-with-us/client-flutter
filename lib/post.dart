import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import 'httpInterceptor.dart';

class Post extends StatefulWidget {
  const Post({Key? key}) : super(key: key);

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  final ImagePicker _picker = ImagePicker();
  String content = "";
  List<XFile?> images = [null, null, null];
  final _storage = const FlutterSecureStorage();
  final Dio dio;

  _PostState() : dio = Dio()..interceptors.add(HttpInterceptor());

  _request() async {
    var request =
        http.MultipartRequest("POST", Uri.parse(dotenv.env['POST_URL']!));
    String? token = await _storage.read(key: "token");
    String? refreshToken = await _storage.read(key: "refreshToken");
    request.files.add(http.MultipartFile.fromString(
        'data',
        jsonEncode({
          "content": content,
        }),
        contentType: MediaType("application", "json")));

    for (int i = 0; i < images.length; i++) {
      if (images[i] != null) {
        request.files
            .add(await http.MultipartFile.fromPath('files', images[i]!.path));
      }
    }
    request.headers['Authorization'] = "Bearer " + token!;
    request.headers['RefreshToken'] = refreshToken!;
    request.send().then((response) {
      if (response.statusCode == 200) {
        print("Uploaded!");
        Navigator.pop(context);
      } else {
        print(response.statusCode);
        print(response.reasonPhrase);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                imagePicker(0),
                imagePicker(1),
                imagePicker(2),
              ],
            ),
            TextField(
              decoration: InputDecoration(hintText: "내용"),
              onChanged: ((s) => {
                    setState(() {
                      content = s;
                    })
                  }),
            ),
            OutlinedButton(
              onPressed: _request,
              child: Text("등록"),
            )
          ],
        ),
      ),
    );
  }

  //if tapped, pick image from gallery and put it in the image widget
  Widget imagePicker(int index) {
    return GestureDetector(
      onTap: () async {
        XFile? file = await _picker.pickImage(source: ImageSource.gallery);
        setState(() {
          images[index] = (file);
        });
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10)),
        child: images[index] == null
            ? Icon(Icons.add)
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(images[index]!.path),
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }
}
