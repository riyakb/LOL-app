import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'login.dart';
import 'toast.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';

class MySignupPage extends StatefulWidget {
  MySignupPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MySignupPageState createState() => _MySignupPageState();
}

String signupToJson(Signup data) => json.encode(data.toJson());

Signup signupFromJson(String data) => Signup.fromJson(json.decode(data));

List<String> decode(String topics_string){
        var temp = topics_string.split('"');
        List<String> ret;
        for(int i=1; i<temp.length; i+=2){
          ret.add(temp[i]);
        }
        return ret;
}

String encode(List<String> topics){
        String topics_string = "[";
        for(int i=0; i < topics.length; i++){
          if(i>0) topics_string += ','; 
          topics_string += '\"' + topics[i].toString() + '\"';
        }
        topics_string += "]";
        return topics_string;
    }

class Signup {
    Signup({
        this.name,
        this.email,
        this.password,
        this.location,
        this.age,
        this.topics,
    });

    String name;
    String email;
    String password;
    String location;
    String age;
    String topics;

    factory Signup.fromJson(Map<String, dynamic> json) => Signup(
        name: json["name"],
        email: json["email"],
        password: json["password"],
        location: json["location"],
        age: json["age"],
        topics: json["topics"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "password": password,
        "location": location,
        "age": age,
        "topics": topics,
    };
}




class _MySignupPageState extends State<MySignupPage> {

  TextEditingController nameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController locationController = new TextEditingController();
  TextEditingController ageController = new TextEditingController();
  List<String> topics = [];

  Future<void> _signup() async {
    final url = "https://summer20-sps-85.el.r.appspot.com/signup";
    Signup signup = Signup(name: nameController.text, email: emailController.text, password: passwordController.text, location: locationController.text, age: ageController.text, topics: encode(topics));
    final response = await http.post('$url',
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },
      body: signupToJson(signup),
    );
    print(nameController.text);
    print(emailController.text);
    print(passwordController.text);
    print(locationController.text);
    print(ageController.text);
    print(response.statusCode);
    print(response.body);
    if(response.statusCode == 200){
      var resp = response.body.split('}');
      showToast(resp[1]);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyLoginPage(title: 'Login')),
      );
    }
    else{
      showToast(response.body);
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

    final topicsField = MultiSelect(
      autovalidate: false,
      titleText: "Preferred Memes topics : ",
      validator: (value) {
              if (value == null) {
                return 'Please select one or more option(s)';
              }
            },
      errorText: 'Please select one or more option(s)',
      dataSource: [
        {
          "display": "Politics",
          "value": 1,
        },
        {
          "display": "Cartoons",
          "value": 2,
        },
        {
          "display": "Animals",
          "value": 3,
        },
        {
          "display": "Movies/Music",
          "value": 4,
        },
        {
          "display": "Fitness",
          "value": 5,
        },
        {
          "display": "Sports",
          "value": 6,
        },
        {
          "display": "College/School",
          "value": 7,
        },
        {
          "display": "Career",
          "value": 8,
        },
        {
          "display": "Others",
          "value": 9,
        },
      ],
      textField: 'display',
      valueField: 'display',
      filterable: true,
      required: true,
      value: [],
      onSaved: (value) {
        print(value);
        topics = value.cast<String>();
        print('The value is $value');
      },
      change: (value){
              print(value);
              topics = value.cast<String>();
              print(topics);
            },
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

    // List<int> value = [2];
    // List<SmartSelectOption<int>> frameworks = [
    //   SmartSelectOption<int>(value: 1, title: 'Ionic'),
    //   SmartSelectOption<int>(value: 2, title: 'Flutter'),
    //   SmartSelectOption<int>(value: 3, title: 'React Native'),
    // ];

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
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 100.0,
                  child: Image.asset(
                    'images/logo.png',
                    height: 25,
                  ),
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
                SizedBox(height: 10.0),
                topicsField,
                // SmartSelect<int>.multiple(
                //   title: 'Frameworks',
                //   value: value,
                //   options: options,
                //   onChange: (val) => setState(() => value = val),
                // );
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