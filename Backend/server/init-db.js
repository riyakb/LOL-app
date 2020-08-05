const mysql = require('mysql');

const sourceFile = require('./source-file.js');


//Connection to sqlServer
const serverCon = mysql.createConnection(sourceFile.serverconCreationObject);

//Create Database
serverCon.query("CREATE DATABASE lol_app;", function (err) {
    if (err) throw err;
    console.log("Database lol_app created");
});

//Connection to DB
const con = mysql.createConnection(sourceFile.conCreationObject);

//Create Tables
sql = "CREATE TABLE users ( \
    id INT AUTO_INCREMENT PRIMARY KEY, \
    name VARCHAR(255), \
    email VARCHAR(255), \
    password VARCHAR(255), \
    location VARCHAR(255), \
    age INTEGER(3), \
    signup_time DATETIME \
    )";
con.query(sql, function (err) {
    if (err) throw err;
    console.log("Table users created");
});

sql = "CREATE TABLE memes ( \
    id INT AUTO_INCREMENT PRIMARY KEY, \
    data VARCHAR(255), \
    upload_user_id INT, \
    upload_time DATETIME \
    )";
con.query(sql, function (err) {
    if (err) throw err;
    console.log("Table memes created");
});

sql = "CREATE TABLE user_meme_interaction ( \
    id INT AUTO_INCREMENT PRIMARY KEY, \
    user_id INT, \
    meme_id INT, \
    reaction VARCHAR(255), \
    score INT)";


//Delete Rows
sql = "DELETE FROM user_meme_interaction; DELETE FROM users; DELETE FROM memes;";

//Obtain all Rows
sql = "select * from users; select * from memes; select * from user_meme_interaction;"

