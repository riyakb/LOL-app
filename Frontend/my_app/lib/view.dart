import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'meme.dart';

// To parse this JSON data, do
//
//     final upload = uploadFromJson(jsonString);

// Upload uploadFromJson(String str) => Upload.fromJson(json.decode(str));

// String uploadToJson(Upload data) => json.encode(data.toJson());

// class Upload {
//     Upload({
//         this.data,
//     });

//     String data;

//     factory Upload.fromJson(Map<String, dynamic> json) => Upload(
//         data: json["data"],
//     );

//     Map<String, dynamic> toJson() => {
//         "data": data,
//     };
// }

// To parse this JSON data, do
//
//     final memes = memesFromJson(jsonString);

List<Memes> memesFromJson(String str) => List<Memes>.from(json.decode(str).map((x) => Memes.fromJson(x)));

String memesToJson(List<Memes> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Memes {
    Memes({
        this.memeId,
        this.userId,
        this.reaction,
        this.score,
        this.data,
    });

    int memeId;
    int userId;
    dynamic reaction;
    dynamic score;
    String data;

    factory Memes.fromJson(Map<String, dynamic> json) => Memes(
        memeId: json["meme_id"],
        userId: json["user_id"],
        reaction: json["reaction"],
        score: json["score"],
        data: json["data"],
    );

    Map<String, dynamic> toJson() => {
        "meme_id": memeId,
        "user_id": userId,
        "reaction": reaction,
        "score": score,
        "data": data,
    };
}


class MemesList extends StatefulWidget {

  String cookie;

  MemesList(this.cookie);

  @override
  createState() => MemesListState(this.cookie); 
}

class MemesListState extends State<MemesList> {

  List<String> _memes = List<String>(); 
  List<int> ids = List<int>();
  String cookie;

  MemesListState(this.cookie);

  @override
  void initState() {
    super.initState();
    _populateMemes(); 
  }

  Future<void> _populateMemes() async {
    final url = "https://summer20-sps-85.el.r.appspot.com/download-meme";
    print(cookie);
    Map<String, String> headers = {"content-type": "application/json", "cookie": cookie};
    final response = await http.post('$url',
      headers: headers,
      body: null,
    );
    if(response.statusCode == 200) {
      List<Memes> data = memesFromJson(response.body);
      print(data.length);
      // data.map((e) => {
      //   _memes.add(e.data),
      //   ids.add(e.memeId)
      // });
      for(var i = 0; i < data.length; i++){
        _memes.add(data[i].data);
        ids.add(data[i].memeId);
      }
    } else {
      throw Exception('Failed to load memes!');
    }
    print(response.statusCode);
    print(response.body);
    print(response.request); 
    setState(() {});
  }

  Future<void> _fetch_memes() async {
    
  }

  Widget _buildItemsForListView(BuildContext context, int index) {
    List<int> image = img.encodeJpg(img.decodeImage(base64Decode(_memes[index])));
    return Meme(image: image, id: ids[index], cookie: cookie);
  }

  @override
  Widget build(BuildContext context) {
    print(_memes.length);
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _memes.length,
      itemBuilder: _buildItemsForListView,
    );
  }
}