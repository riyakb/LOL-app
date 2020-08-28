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
import 'package:flutter_multiselect/flutter_multiselect.dart';

class Profile extends StatefulWidget {

  String cookie;
  Info info;

  Profile(this.cookie, this.info);

  @override
  createState() => ProfileState(this.cookie, this.info); 
}

List<String> decode1(String topics_string){
        var temp = topics_string.split('"');
        List<String> ret;
        for(int i=1; i<temp.length; i+=2){
          ret.add(temp[i]);
        }
        return ret;
}

Widget normal_mode(BuildContext context, Info info, String cookie){
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
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30.0),
                Text("email: " + info.email,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 10.0),
                Text("location: " + info.location,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 10.0),
                Text("Age: " + info.age.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 10.0),
                Text("Topics: " + info.topics,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 10.0),
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
                        MaterialPageRoute(builder: (context) => MyMemesList(cookie, info.id)),
                      );
                      // return MyMemesList(widget.cookie, info.id);
                    },
                    child: Text("Edit",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
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
                        MaterialPageRoute(builder: (context) => MyMemesList(cookie, info.id)),
                      );
                      // return MyMemesList(widget.cookie, info.id);
                    },
                    child: Text("Posts",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
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
                    onPressed: () async { 
                      final url = "https://summer20-sps-85.el.r.appspot.com/delete-user";
                      Map<String, String> headers = {"content-type": "application/json", "cookie": cookie};
                      final response = await http.post('$url',
                        headers: headers,
                      );
                      showToast(response.body);
                      if(response.statusCode == 200){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyLoginPage(title: 'Login')),
                        );
                      }
                      // return MyMemesList(widget.cookie, info.id);
                    },
                    child: Text("Delete Account",
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

String signupToJson(Signup data) => json.encode(data.toJson());

Signup signupFromJson(String data) => Signup.fromJson(json.decode(data));

List<String> decode(String topics_string){
        topics_string = topics_string.substring(1,topics_string.length-1);
        // print(topics_string);
        var temp = topics_string.split(',');
        // print(temp.length);
        List<String> ret = List<String>();
        for(int i=0; i<temp.length; i++){
          ret.add(temp[i]);
        }
        // print(ret);
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

Widget edit_mode(BuildContext context, Info info, String cookie){

    

    // List<int> value = [2];
    // List<SmartSelectOption<int>> frameworks = [
    //   SmartSelectOption<int>(value: 1, title: 'Ionic'),
    //   SmartSelectOption<int>(value: 2, title: 'Flutter'),
    //   SmartSelectOption<int>(value: 3, title: 'React Native'),
    // ];

    
}

class ProfileState extends State<Profile> {

  String cookie;
  Info info;
  ProfileState(this.cookie, this.info);
  bool bo = false;

    TextEditingController nameController;
    TextEditingController emailController;
    TextEditingController passwordController;
    TextEditingController locationController;
    TextEditingController ageController;
    List<String> topics;

  @override
  void initState() {
    topics = decode(info.topics);
    print(topics.length);
    nameController = new TextEditingController(text: info.name);
    emailController = new TextEditingController(text: info.email);
    passwordController = new TextEditingController(text: info.password);
    locationController = new TextEditingController(text: info.location);
    ageController = new TextEditingController(text: info.age.toString());
    super.initState();
    setState(() {});
  }
  

  @override
  Widget build(BuildContext context) {
    // List<String> topics = decode1(info.topics);
    print(info.topics);
    if(bo) {
      
    print(topics);
    print(info.topics);

    Future<void> _submit() async {
      final url = "https://summer20-sps-85.el.r.appspot.com//update-profile";
      Signup signup = Signup(name: nameController.text, email: emailController.text, password: passwordController.text, location: locationController.text, age: ageController.text, topics: encode(topics));
      Map<String, String> headers = {"content-type": "application/json", "cookie": cookie};
      final response = await http.post('$url',
        headers: headers,
        body: signupToJson(signup),
      );
      print(nameController.text);
      print(emailController.text);
      print(passwordController.text);
      print(locationController.text);
      print(ageController.text);
      print(response.statusCode);
      print(response.body);
      showToast(response.body);
      if(response.statusCode == 200){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyLoginPage(title: 'Login')),
        );
      }
      else{
        
      }
    }

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

    print(topics);

    var topicsField = MultiSelect(
      // initialValue: ["Politics",  "Fitness",  "Others"],
      initialValue: topics,
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
      value: topics,
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
        onPressed: _submit,
        child: Text("Submit",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );



      return SingleChildScrollView( child: Center(
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
      ),);
    }
    else return SingleChildScrollView( child: Center(
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
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30.0),
                Text("email: " + info.email,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 10.0),
                Text("location: " + info.location,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 10.0),
                Text("Age: " + info.age.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 10.0),
                Text("Topics: " + info.topics,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 10.0),
                Material(
                  borderRadius: BorderRadius.circular(30.0),
                  child: MaterialButton(
                    elevation: 5.0,
                    color: Colors.blue,
                    minWidth: MediaQuery.of(context).size.width/2,
                    padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    onPressed: () { 
                      bo = true;
                      setState(() {});
                    },
                    child: Text("Edit",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
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
                        MaterialPageRoute(builder: (context) => MyMemesList(cookie, info.id)),
                      );
                      // return MyMemesList(widget.cookie, info.id);
                    },
                    child: Text("Posts",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
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
                    onPressed: () async { 
                      final url = "https://summer20-sps-85.el.r.appspot.com/delete-user";
                      Map<String, String> headers = {"content-type": "application/json", "cookie": cookie};
                      final response = await http.post('$url',
                        headers: headers,
                      );
                      showToast(response.body);
                      if(response.statusCode == 200){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyLoginPage(title: 'Login')),
                        );
                      }
                      // return MyMemesList(widget.cookie, info.id);
                    },
                    child: Text("Delete Account",
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