import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

// To parse this JSON data, do
//
//     final upload = uploadFromJson(jsonString);

Upload uploadFromJson(String str) => Upload.fromJson(json.decode(str));

String uploadToJson(Upload data) => json.encode(data.toJson());

class Upload {
    Upload({
        this.data,
    });

    String data;

    factory Upload.fromJson(Map<String, dynamic> json) => Upload(
        data: json["data"],
    );

    Map<String, dynamic> toJson() => {
        "data": data,
    };
}

class UploadWidget extends StatelessWidget {

  File file;
  String cookie;

  UploadWidget(this.cookie);

  void _choose() async {
    // file = await ImagePicker.pickImage(source: ImageSource.camera);
    file = await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  Future<void> _upload() async {
    final url = "https://summer20-sps-85.el.r.appspot.com/upload-meme";
    if (file == null) return;
    String base64Image = base64Encode(file.readAsBytesSync());
    Upload upload = Upload(data: base64Image);
    print(cookie);
    Map<String, String> headers = {"content-type": "application/json", "cookie": cookie};

    final response = await http.post('$url',
      headers: headers,
      body: uploadToJson(upload),
    );
    debugPrint(base64Image.length.toString(), wrapWidth: 1000);
    print(response.statusCode);
    print(response.body.split('').reversed.join(''));
  }

  @override
  Widget build(BuildContext context) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialButton(
              elevation: 5.0,
              color: Colors.grey,
              onPressed: _choose,
              child: Text('Choose Image',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(height: 10.0),
            MaterialButton(
              minWidth: MediaQuery.of(context).size.width/2,
              elevation: 5.0,
              color: Colors.blue,
              onPressed: _upload,
              child: Text('Upload Image',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
  }
}