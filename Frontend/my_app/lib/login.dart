import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'signup.dart';
import 'home_page.dart';

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
    print(response.headers['set-cookie']);
    print(emailController.text);
    print(passwordController.text);
    print(response.statusCode);
    print(response.body);
    print(response.request);
    // Logout logout = logoutFromJson(response.body);
    // final sessionId = logout.sessionId;
    // final sessionId = "47a0479900504cb3ab";
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage(title: 'Home Page', cookie: response.headers['set-cookie'])),
    );
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
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 155.0,
                  child: Icon(Icons.device_hub),
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
