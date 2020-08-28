import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'toast.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';

// To parse this JSON data, do
//
//     final upload = uploadFromJson(jsonString);

Upload uploadFromJson(String str) => Upload.fromJson(json.decode(str));

String uploadToJson(Upload data) => json.encode(data.toJson());

class Upload {
    Upload({
        this.data,
        this.topics,
    });

    String data;
    List<String> topics;

    String encode(List<String> topics){
        String topics_string = "[";
        for(int i=0; i < topics.length; i++){
          if(i>0) topics_string += ','; 
          topics_string += '\"' + topics[i].toString() + '\"';
        }
        topics_string += "]";
        return topics_string;
    }

    factory Upload.fromJson(Map<String, dynamic> json) => Upload(
        data: json["data"],
    );

    Map<String, dynamic> toJson() => {
        "data": data,
        "topics": this.encode(topics),
    };
}

class UploadWidget extends StatelessWidget {

  File file;
  String cookie;
  List<String> topics = [];

  UploadWidget(this.cookie);

  void _choose() async {
    // file = await ImagePicker.pickImage(source: ImageSource.camera);
    file = await ImagePicker.pickImage(source: ImageSource.gallery, maxHeight: 500, maxWidth: 500);
  }

  Future<void> _upload() async {
    final url = "https://summer20-sps-85.el.r.appspot.com/upload-meme";
    if (file == null) return;
    String base64Image = base64Encode(file.readAsBytesSync());
    Upload upload = Upload(data: base64Image, topics: topics);
    print(cookie);
    Map<String, String> headers = {"content-type": "application/json", "cookie": cookie};

    final response = await http.post('$url',
      headers: headers,
      body: uploadToJson(upload),
    );
    showToast(response.body);
    debugPrint(base64Image.length.toString(), wrapWidth: 1000);
    print(response.statusCode);
    print(response.body.split('').reversed.join(''));
  }

  

  @override
  Widget build(BuildContext context) {
      final topicsField = MultiSelect(
      autovalidate: false,
      titleText: "Meme topics : ",
      validator: (value) {
              if (value == null) {
                return 'Please select one or more option(s)';
              }
            },
      errorText: 'Please select one or more option(s)',
      dataSource: [
        {
          "display": "Politics",
          "value": 1,
        },
        {
          "display": "Cartoons",
          "value": 2,
        },
        {
          "display": "Animals",
          "value": 3,
        },
        {
          "display": "Movies/Music",
          "value": 4,
        },
        {
          "display": "Fitness",
          "value": 5,
        },
        {
          "display": "Sports",
          "value": 6,
        },
        {
          "display": "College/School",
          "value": 7,
        },
        {
          "display": "Career",
          "value": 8,
        },
        {
          "display": "Others",
          "value": 9,
        },
      ],
      textField: 'display',
      valueField: 'display',
      filterable: true,
      required: true,
      value: [],
      onSaved: (value) {
        print(value);
        topics = value.cast<String>();
        print('The value is $value');
      },
      change: (value){
              print(value);
              topics = value.cast<String>();
              print(topics);
            },
    );

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 200,
              child: topicsField
            ),
            SizedBox(height: 10.0),
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