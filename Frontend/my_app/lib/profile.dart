import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'meme.dart';
import 'toast.dart';
import 'login.dart';
import 'my_memes.dart';

class Profile extends StatefulWidget {

  String cookie;
  Info info;

  Profile(this.cookie, this.info);

  @override
  createState() => ProfileState(this.cookie, this.info); 
}

class ProfileState extends State<Profile> {

  String cookie;
  Info info;

  ProfileState(this.cookie, this.info);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( child: Center(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(info.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 45.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30.0),
                Text("email: " + info.email,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 10.0),
                Text("location: " + info.location,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 10.0),
                Text("Age: " + info.age.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 30.0),
                Material(
                  borderRadius: BorderRadius.circular(30.0),
                  child: MaterialButton(
                    elevation: 5.0,
                    color: Colors.blue,
                    minWidth: MediaQuery.of(context).size.width/2,
                    padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    onPressed: () { 
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyMemesList(widget.cookie, info.id)),
                      );
                      // return MyMemesList(widget.cookie, info.id);
                    },
                    child: Text("Posts",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),);
  }
}