import 'package:flutter/material.dart';
// import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'login.dart';
import 'upload.dart';
import 'view.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.cookie}) : super(key: key);

  // This widget is the Login page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final String cookie;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// To parse this JSON data, do
//
//     final logout = logoutFromJson(jsonString);

// Logout logoutFromJson(String str) => Logout.fromJson(json.decode(str));

// String logoutToJson(Logout data) => json.encode(data.toJson());

// class Logout {
//     Logout({
//         this.sessionId,
//     });

//     String sessionId;

//     factory Logout.fromJson(Map<String, dynamic> json) => Logout(
//         sessionId: json["session-id"],
//     );

//     Map<String, dynamic> toJson() => {
//         "session-id": sessionId,
//     };
// }

class _MyHomePageState extends State<MyHomePage> {

  int _currentIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _logout() async {
    final url = "https://summer20-sps-85.el.r.appspot.com/signout";
    // Logout logout = Logout(sessionId: widget.sessionId);
    final response = await http.post('$url',
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.setCookieHeader: widget.cookie
      },
      // body: logoutToJson(logout),
    );

    // print(logout.sessionId);
    print(response.statusCode);
    print(response.body);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyLoginPage(title: 'Login')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [
      MemesList(widget.cookie),
      UploadWidget(widget.cookie),
      Text('Profile'),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Positioned(
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: MaterialButton(
                color: Colors.white,
                onPressed:  _logout,
                child: Text("Logout",
                  textAlign: TextAlign.center,
                ),
              )
            )
          )
        ],
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            title: new Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.file_upload),
            title: new Text('Upload Meme'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('Profile')
          )
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}