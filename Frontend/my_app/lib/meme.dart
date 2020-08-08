import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'toast.dart';

class Meme extends StatefulWidget {

  Meme({Key key, this.image, this.id, this.cookie}) : super(key: key);

  List<int> image;
  int id;
  int selectedemoji = 0;
  String cookie;

  @override
  _Meme createState() => _Meme(cookie);

}

// To parse this JSON data, do
//
//     final feedback = feedbackFromJson(jsonString);

Feedback feedbackFromJson(String str) => Feedback.fromJson(json.decode(str));

String feedbackToJson(Feedback data) => json.encode(data.toJson());

class Feedback {
    Feedback({
        this.meme_id,
        this.reaction,
    });

    int meme_id;
    int reaction;

    factory Feedback.fromJson(Map<String, dynamic> json) => Feedback(
        meme_id: json["id"],
        reaction: json["reaction"],
    );

    Map<String, dynamic> toJson() => {
        "meme_id": meme_id,
        "reaction": reaction,
    };
}


class _Meme extends State<Meme>{

  String cookie;

  _Meme(this.cookie);
  
  @override
  Widget build(BuildContext context) {

      Future<void> _feedback(int id, int selectedemoji) async {
        final url = "https://summer20-sps-85.el.r.appspot.com/react-meme";
        Feedback feedback = Feedback(meme_id: id, reaction: selectedemoji);
        print(id);
        print(selectedemoji);
        Map<String, String> headers = {"content-type": "application/json", "cookie": cookie};
        final response = await http.post('$url',
          headers: headers,
          body: feedbackToJson(feedback),
        );
        showToast(response.body);
        print(response.statusCode);
        print(response.body);
        print(response.request);
      }

      return Column(
        children: <Widget>[
          Text("caption " + widget.id.toString(),
            style: TextStyle(fontSize: 18),
          ),
          Image.memory(widget.image), 
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                color: (widget.selectedemoji == 1) ? Colors.lightBlue : null,
                child: IconButton(
                  icon: Image.asset(
                    'images/haha.png',
                    height: 25,
                  ),
                  tooltip: 'ROFL',
                  onPressed: () { 
                    widget.selectedemoji = 1;
                    _feedback(widget.id, widget.selectedemoji);
                    setState(() {});
                  },
                  // highlightColor: Colors.blue,
                ),
              ),
              Container(
                color: (widget.selectedemoji == 2) ? Colors.lightBlue : null,
                child: IconButton(
                  icon: Image.asset(
                    'images/smile.png',
                    height: 25,
                  ),
                  tooltip: 'LOL',
                  onPressed: () { 
                    widget.selectedemoji = 2;
                    _feedback(widget.id,widget.selectedemoji);
                    setState(() {});
                  },
                  // highlightColor: Colors.blue,
                ),
              ),
              Container(
                color: (widget.selectedemoji == 3) ? Colors.lightBlue : null,
                child: IconButton(
                  icon: Image.asset(
                    'images/dislike.png',
                    height: 25,
                  ),
                  tooltip: 'PJ',
                  onPressed: () { 
                    widget.selectedemoji = 3;
                    _feedback(widget.id,widget.selectedemoji);
                    setState(() {});
                  },
                  // highlightColor: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 40,)
        ],
      );
  }
}