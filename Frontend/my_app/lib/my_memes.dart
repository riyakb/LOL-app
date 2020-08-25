import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
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

DeleteMeme deleteMemeFromJson(String str) => DeleteMeme.fromJson(json.decode(str));

String deleteMemeToJson(DeleteMeme data) => json.encode(data.toJson());

class DeleteMeme {
    DeleteMeme({
        this.memeId,
        this.userId,
    });

    int memeId;
    int userId;

    factory DeleteMeme.fromJson(Map<String, dynamic> json) => DeleteMeme(
        memeId: json["meme_id"],
        userId: json["user_id"],
    );

    Map<String, dynamic> toJson() => {
        "meme_id": memeId,
        "user_id": userId,
    };
}

class MyMemesList extends StatefulWidget {

  String cookie;
  int user_id;

  MyMemesList(this.cookie, this.user_id);

  @override
  createState() => MyMemesListState(this.cookie, this.user_id); 
}

Map<String, dynamic> toJson(int idx) => {
  "startidx": idx,
};

class MyMemesListState extends State<MyMemesList> {

  int index;
  List<String> _memes = List<String>(); 
  List<int> ids = List<int>();
  String cookie;
  bool bo = true;
  int user_id;

  MyMemesListState(this.cookie, this.user_id);

  @override
  void initState() {
    index = 0;
    super.initState();
    _populateMemes(true);
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

  Future<void> _deleteMeme() async{
    final url = "https://summer20-sps-85.el.r.appspot.com/delete-meme";
    Map<String, String> headers = {"content-type": "application/json", "cookie": cookie};
    print(user_id.toInt());
    print(ids[index]);
    DeleteMeme del = DeleteMeme(userId: user_id.toInt(), memeId: ids[index]);
    final response = await http.post('$url',
      headers: headers,
      body: deleteMemeToJson(del),
    );
    showToast(response.body);
    if(response.statusCode == 200) nextMeme();
  }

  Future<void> _populateMemes(bool callSet) async {
    final url = "https://summer20-sps-85.el.r.appspot.com/download-my-meme";
    Map<String, String> headers = {"content-type": "application/json", "cookie": cookie};
    final response = await http.post('$url',
      headers: headers,
      body: json.encode(toJson(_memes.length)),
    );
    if(response.statusCode == 200) {
      List<Memes> data = memesFromJson(response.body);
      print(data.length);
      if(data.length == 0) bo = false;
      for(var i = 0; i < data.length; i++){
        _memes.add(data[i].data);
        ids.add(data[i].memeId);
      }
    } 
    else {
      if(response.body == "startidx should be less than total memes (0-based index)") {
        bo = false;
        if(_memes.length == 0) showToast("You have not uploaded any meme yet");
      }
      else throw Exception('Failed to load memes!');
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
    return Scaffold( body:
      SingleChildScrollView( child: Center(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildItemsForListView(context, index),
                SizedBox(height: 10.0),
                Material(
                  borderRadius: BorderRadius.circular(30.0),
                  child: MaterialButton(
                    elevation: 5.0,
                    color: Colors.blue,
                    minWidth: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    onPressed: _deleteMeme,
                    child: Text("Delete",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),))
    ;
    // return ListView.builder(
    //   controller: _scrollController,
    //   padding: const EdgeInsets.all(8),
    //   itemCount: _memes.length,
    //   itemBuilder: _buildItemsForListView,
    // );
  }
}