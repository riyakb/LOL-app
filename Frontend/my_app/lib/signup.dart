import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'login.dart';
import 'toast.dart';

class MySignupPage extends StatefulWidget {
  MySignupPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MySignupPageState createState() => _MySignupPageState();
}

String signupToJson(Signup data) => json.encode(data.toJson());

class Signup {
    Signup({
        this.name,
        this.email,
        this.password,
        this.location,
        this.age,
    });

    String name;
    String email;
    String password;
    String location;
    String age;

    factory Signup.fromJson(Map<String, dynamic> json) => Signup(
        name: json["name"],
        email: json["email"],
        password: json["password"],
        location: json["location"],
        age: json["age"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "password": password,
        "location": location,
        "age": age,
    };
}


class _MySignupPageState extends State<MySignupPage> {

  TextEditingController nameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController locationController = new TextEditingController();
  TextEditingController ageController = new TextEditingController();

  Future<void> _signup() async {
    final url = "https://summer20-sps-85.el.r.appspot.com/signup";
    Signup signup = Signup(name: nameController.text, email: emailController.text, password: passwordController.text, location: locationController.text, age: ageController.text);
    final response = await http.post('$url',
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },
      body: signupToJson(signup),
    );
    showToast(response.body);
    print(nameController.text);
    print(emailController.text);
    print(passwordController.text);
    print(locationController.text);
    print(ageController.text);
    print(response.statusCode);
    print(response.body);
    if(response.statusCode == 200){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyLoginPage(title: 'Login')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final nameField = TextField(
      obscureText: false,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Name",
        border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
      ),
      controller: nameController,
    );

    final emailField = TextField(
      obscureText: false,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Email",
        border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
      ),
      controller: emailController,
    );

    final passwordField = TextField(
      obscureText: true,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Password",
        border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
      ),
      controller: passwordController,
    );

    final locationField = TextField(
      obscureText: false,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Location",
        border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
      ),
      controller: locationController,
    );

    final ageField = TextField(
      obscureText: false,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Age",
        border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
      ),
      controller: ageController,
    );

    final signupButon = Material(
      child: MaterialButton(
        elevation: 5.0,
        color: Colors.blue,
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: _signup,
        child: Text("Signup",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyLoginPage(title: 'Login')),
                  );
                },
                child: Text("Login",
                  textAlign: TextAlign.center,
                ),
              )
            )
          )
        ],
      ),
      body: SingleChildScrollView( child: Center(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 100.0,
                  child: Icon(Icons.device_hub),
                ),
                nameField,
                SizedBox(height: 10.0),
                emailField,
                SizedBox(height: 10.0),
                passwordField,
                SizedBox(height: 10.0),
                locationField,
                SizedBox(height: 10.0),
                ageField,
                SizedBox(height: 30.0),
                signupButon,
              ],
            ),
          ),
        ),
      ),),
    );
  }
}