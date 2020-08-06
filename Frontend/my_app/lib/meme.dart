import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Meme extends StatefulWidget {

  Meme({Key key, this.image, this.id}) : super(key: key);

  List<int> image;
  int id;
  int selectedemoji = 0;

  @override
  _Meme createState() => _Meme();

}

// To parse this JSON data, do
//
//     final feedback = feedbackFromJson(jsonString);

Feedback feedbackFromJson(String str) => Feedback.fromJson(json.decode(str));

String feedbackToJson(Feedback data) => json.encode(data.toJson());

class Feedback {
    Feedback({
        this.id,
        this.reaction,
    });

    int id;
    int reaction;

    factory Feedback.fromJson(Map<String, dynamic> json) => Feedback(
        id: json["id"],
        reaction: json["reaction"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "reaction": reaction,
    };
}


class _Meme extends State<Meme>{
  
  @override
  Widget build(BuildContext context) {

      Future<void> _feedback(int id, int selectedemoji) async {
        final url = "https://summer20-sps-85.el.r.appspot.com/feedback";
        Feedback feedback = Feedback(id: id, reaction: selectedemoji);
        final response = await http.post('$url',
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json'
          },
          body: feedbackToJson(feedback),
        );
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
                    _feedback(widget.id,widget.selectedemoji);
                    setState(() //<--whenever icon is pressed, force redraw the widget
                    {
                      widget.selectedemoji = 1;
                    });
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
                    _feedback(widget.id,widget.selectedemoji);
                    setState(() //<--whenever icon is pressed, force redraw the widget
                    {
                      widget.selectedemoji = 2;
                    });
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
                    _feedback(widget.id,widget.selectedemoji);
                    setState(() //<--whenever icon is pressed, force redraw the widget
                    {
                      widget.selectedemoji = 3;
                    });
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