import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Post extends StatefulWidget {
  const Post({Key? key}) : super(key: key);

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  final ImagePicker _picker = ImagePicker();
  String content = "";
  List<XFile?> images = [null, null, null];

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
              onPressed: () async {},
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
            : Image.file(
                File(images[index]!.path),
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
