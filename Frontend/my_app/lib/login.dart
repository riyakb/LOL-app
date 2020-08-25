import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'signup.dart';
import 'home_page.dart';
import 'toast.dart';

class MyLoginPage extends StatefulWidget {
  MyLoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyLoginPageState createState() => _MyLoginPageState();
}

String loginToJson(Login data) => json.encode(data.toJson());

class Login {
    Login({
        this.email,
        this.password,
    });

    String email;
    String password;

    factory Login.fromJson(Map<String, dynamic> json) => Login(
        email: json["email"],
        password: json["password"],
    );

    Map<String, dynamic> toJson() => {
        "email": email,
        "password": password,
    };
}

Info infoFromJson(String str) => Info.fromJson(json.decode(str));

String infoToJson(Info data) => json.encode(data.toJson());

class Info {
    Info({
        this.id,
        this.name,
        this.email,
        this.password,
        this.location,
        this.age,
        this.signupTime,
    });

    int id;
    String name;
    String email;
    String password;
    String location;
    int age;
    DateTime signupTime;

    factory Info.fromJson(Map<String, dynamic> json) => Info(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        password: json["password"],
        location: json["location"],
        age: json["age"],
        signupTime: DateTime.parse(json["signup_time"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "password": password,
        "location": location,
        "age": age,
        "signup_time": signupTime.toIso8601String(),
    };
}


class _MyLoginPageState extends State<MyLoginPage> {
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  Future<void> _login() async {
    final url = "https://summer20-sps-85.el.r.appspot.com/signin";
    Login login = Login(email: emailController.text, password: passwordController.text);
    final response = await http.post('$url',
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },
      body: loginToJson(login),
    );
    // showToast(response.body);
    print(response.headers['set-cookie']);
    print(emailController.text);
    print(passwordController.text);
    print(response.statusCode);
    print(response.body);
    print(response.request);
    // Logout logout = logoutFromJson(response.body);
    // final sessionId = logout.sessionId;
    // final sessionId = "47a0479900504cb3ab";
    if(response.statusCode == 200){
      var resp = response.body.split('}');
      String fresp = resp[0]+'}';
      print(fresp);
      Info ret = infoFromJson(fresp);
      showToast(resp[1]);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage(title: 'Home Page', cookie: response.headers['set-cookie'], info: ret)),
      );
    }
    else{
      showToast(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {

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

    final loginButon = Material(
      borderRadius: BorderRadius.circular(30.0),
      child: MaterialButton(
        elevation: 5.0,
        color: Colors.blue,
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: _login,
        child: Text("Login",
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
                onPressed:  () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MySignupPage(title: 'Sign up')),
                  );
                },
                child: Text("Signup",
                  textAlign: TextAlign.center,
                ),
              )
            )
          )
        ],
      ),
      body: SingleChildScrollView( child: Center(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 155.0,
                  child: Image.asset(
                    'images/logo.png',
                    height: 25,
                  ),
                ),
                SizedBox(height: 45.0),
                emailField,
                SizedBox(height: 25.0),
                passwordField,
                SizedBox(height: 35.0),
                loginButon,
                SizedBox(height: 15.0),
              ],
            ),
          ),
        ),
      ),),
    );
  }
}
