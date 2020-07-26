const bcrypt = require('bcrypt');
const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql');
const session = require('express-session');

const sourceFile = require('./source-file.js');

const saltRounds = 10;


function getHashFromUserPassword(userPassword) {
    return bcrypt.hashSync(userPassword, saltRounds);
}

function compareUserPassword(userPassword, hash) {
    return bcrypt.compareSync(userPassword, hash);
}

//Express Service
app = express();
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended : true}));
app.use(session(sourceFile.sessionInilizationObject));


const con = mysql.createConnection(sourceFile.conCreationObject);

//handle Requests
app.post('/signup', function(request, response) {
    var name = request.body.name;
	var email = request.body.email;
    var password = request.body.password;
    var location = request.body.location;
    var age = request.body.age;

	if (name && email && password && location && age) {
		con.query("SELECT * FROM users WHERE email = ?", [email], function(error, results) {
            if (error) throw error;
			if (results.length > 0) {
                response.send("Email already exists");
			} else {
                var hashToStoreInDb = getHashFromUserPassword(password);
                sql = "INSERT INTO users (name, email, password, location, age, signup_time) VALUES (?, ?, ?, ?, ?, ?)";
				con.query(sql, [name, email, hashToStoreInDb, location, age, new Date()], function(insertError, insertResults) {
                    if (insertError) {
                        throw insertError;
                    }
                    response.send("Registration Successful");
                });
            }
		});
	} else {
        var unFilled = "";
        if (!age) { unFilled = "age"; }
        if (!location) { unFilled = "location"; }
        if (!password) { unFilled = "password"; }
        if (!email) { unFilled = "email"; }
        if (!name) { unFilled = "name"; }
        response.send("Please enter " + unFilled);
		response.end();
	}
});

app.post('/signin', function(request, response) {
	var email = request.body.email;
    var password = request.body.password;
	if (email && password) {
		con.query('SELECT * FROM users WHERE email = ?', [email], function(error, results) {
            if (error) throw error;
            var ok = false;
            if (results.length > 0) {
                var hashInDb = results[0].password;
                if (compareUserPassword(password, hashInDb)) { ok = true; }
            }
			if (ok) {
				request.session.loggedin = true;
                request.session.email = email;
                request.session.user_id = results[0].id;
                response.send("Signin Successful!")
			} else {
				response.send('Incorrect Email and/or Password!');
			}			
			response.end();
		});
	} else {
		response.send('Please enter Email and Password!');
		response.end();
	}
});

app.post('/signout', function(request, response) {
    if (request.session.loggedin) {
        request.session.loggedin = false;
        response.send("Signout Successful!");
    }
    response.end();
});

app.post('/upload-meme', function(request, response) {
    if (request.session.loggedin) {
        if (request.body.data) {
            sql = "INSERT INTO memes (data, upload_user_id, upload_time) VALUES (?, ?, ?)";
            con.query(sql, [request.body.data, request.session.user_id, new Date()], function(error) {
                if (error) {
                    response.send("Error occurred. Please try again.");
                    throw error;
                } else {
                    response.send("Meme-upload successful");
                }
            });
        } else {
            response.send("Please enter data");
        }
    } else {
        response.send("You forgot to signin memer ;)");
    }
});

app.listen(3001);