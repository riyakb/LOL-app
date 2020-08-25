import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'meme.dart';
import 'toast.dart';

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

  int index;
  // ScrollController _scrollController = ScrollController();
  List<String> _memes = List<String>(); 
  List<int> ids = List<int>();
  String cookie;
  bool bo = true;

  MemesListState(this.cookie);

  @override
  void initState() {
    index = 0;
    super.initState();
    _populateMemes(true); 
    // setState(() {});
    // _scrollController.addListener(() {
    //   if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
    //     if(bo) this._populateMemes();
    //   }
    // });
  }

  void nextMeme() {
    if(bo == false || index+1 == _memes.length) {
      showToast("This is the last meme");
      return;
    }
    index++;
    if(index + 2 == _memes.length && bo) _populateMemes(false);
    setState(() {});
  }

  Future<void> _populateMemes(bool callSet) async {
    print("entered");
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
      if(data.length == 0) bo = false;
      for(var i = 0; i < data.length; i++){
        if(ids.length>1 && ids[ids.length-2]==data[i].memeId) continue;
        if(ids.length>0 && ids[ids.length-1]==data[i].memeId) continue;
        _memes.add(data[i].data);
        ids.add(data[i].memeId);
      }
    } 
    else {
      throw Exception('Failed to load memes!');
    }
    print(response.statusCode);
    print(response.body);
    print(response.request);
    if(callSet) setState(() {});
  }

  Widget _buildItemsForListView(BuildContext context, int index) {
    if(index >= _memes.length) return Text("Loading...", textAlign: TextAlign.center,);
    List<int> image = img.encodeJpg(img.decodeImage(base64Decode(_memes[index])));
    return Meme(image: image, id: ids[index], cookie: cookie, nextMeme: nextMeme);
  }

  @override
  Widget build(BuildContext context) {
    print(_memes.length);
    return SingleChildScrollView( child: _buildItemsForListView(context, index));
    // return ListView.builder(
    //   controller: _scrollController,
    //   padding: const EdgeInsets.all(8),
    //   itemCount: _memes.length,
    //   itemBuilder: _buildItemsForListView,
    // );
  }
}