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
    data VARCHAR, \
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

//Show all columns
sql = "SHOW COLUMNS FROM users; SHOW COLUMNS FROM memes; SHOW COLUMNS FROM user_meme_interaction;"

//Add Foreign Key Constraints
    sql = "ALTER TABLE memes \
        ADD CONSTRAINT fk_upload_user_id \
        FOREIGN KEY (upload_user_id) REFERENCES users(id) \
        ON DELETE CASCADE"

sql = "ALTER TABLE user_meme_interaction \
    ADD CONSTRAINT fk_user_id \
    FOREIGN KEY (user_id) REFERENCES users(id) \
    ON DELETE CASCADE"

sql = "ALTER TABLE user_meme_interaction \
    ADD CONSTRAINT fk_meme_id \
    FOREIGN KEY (meme_id) REFERENCES memes(id) \
    ON DELETE CASCADE"

//Modify data type of memes
sql = "ALTER TABLE memes \
    MODIFY COLUMN data MEDIUMBLOB;"

//Download-meme
sql = "SELECT top_memes_for_user.meme_id, top_memes_for_user.user_id, \
    top_memes_for_user.reaction, top_memes_for_user.score, memes.data \
    FROM (SELECT * FROM user_meme_interaction WHERE user_id = ? ORDER BY score  DESC LIMIT ?) \
    AS top_memes_for_user \
    JOIN memes ON top_memes_for_user.meme_id = memes.id;"