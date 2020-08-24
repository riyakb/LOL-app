const bcrypt = require('bcrypt');
const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql');
const {spawn} = require('child_process');

const session = require('express-session');
const FORBIDDEN_STATUSCODE = 403

const sourceFile = require('./source-file.js');
const { timingSafeEqual } = require('crypto');
const { userInfo } = require('os');

const saltRounds = 10;
const maxDownloadCount = 10;
const maxDataSize = '50mb';

function getHashFromUserPassword(userPassword) {
    return bcrypt.hashSync(userPassword, saltRounds);
}

function compareUserPassword(userPassword, hash) {
    return bcrypt.compareSync(userPassword, hash);
}

//Express Service
app = express();
app.use(bodyParser.json({limit : maxDataSize, extended : true}));
app.use(bodyParser.urlencoded({limit : maxDataSize, extended : true}));
app.use(session(sourceFile.sessionInilizationObject));

const con = mysql.createConnection(sourceFile.conCreationObject);
// const pool = promiseMysql.createPool(sourceFile.conCreationObject);

//handle Requests
app.post('/signup', function(request, response) {
    var name = request.body.name;
	var email = request.body.email;
    var password = request.body.password;
    var location = request.body.location;
    var age = request.body.age;

	if (name && email && password && location && age) {
		con.query("SELECT * FROM users WHERE email = ?", [email], function(error, results) {
            if (error) {
                throw error;
            }

			if (results.length > 0) {
                response.status(FORBIDDEN_STATUSCODE)
                response.write("Email already exists");
                response.end();
			} else {
                var hashToStoreInDb = getHashFromUserPassword(password);
                sql = "INSERT INTO users (name, email, password, location, age, signup_time) VALUES (?, ?, ?, ?, ?, ?)";
				con.query(sql, [name, email, hashToStoreInDb, location, age, new Date()], function(insertError, insertResults) {
                    if (insertError) {
                        throw insertError;
                    }
                    user_id = insertResults.insertId;
                    sql = "SELECT id FROM memes";
                    con.query(sql, function(error, results) {
                        sql = "INSERT INTO user_meme_interaction (user_id, meme_id) VALUES (?, ?)";
                        for (i = 0; i < results.length; i++) {
                            con.query(sql, [user_id, results[i].id]);
                        }
                    });
                    response.write("Registration Successful");
                    response.end();
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
        response.status(FORBIDDEN_STATUSCODE)
        response.write("Please enter " + unFilled);
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
                response.write("Signin Successful!")
			} else {
                response.status(FORBIDDEN_STATUSCODE)
				response.write('Incorrect Email and/or Password!');
			}			
			response.end();
		});
	} else {
        response.status(FORBIDDEN_STATUSCODE)
		response.write('Please enter Email and Password!');
		response.end();
	}
});

app.post('/signout', function(request, response) {
    if (request.session.loggedin) {
        request.session.loggedin = false;
        response.write("Signout Successful!");
    }
    response.end();
});

app.post('/upload-meme', function(request, response) {
    if (request.session.loggedin) {
        if (request.body.data) {
            sql = "INSERT INTO memes (data, upload_user_id, upload_time) VALUES (?, ?, ?)";
            con.query(sql, [request.body.data, request.session.user_id, new Date()], function(error, results) {
                if (error) {
                    response.status(FORBIDDEN_STATUSCODE)
                    response.write("Error occurred. Please try again.");
                    response.end();
                    throw error;
                } else {
                    meme_id = results.insertId;
                    sql = "SELECT id FROM users";   
                    con.query(sql, function(error, results) {
                        sql = "INSERT INTO user_meme_interaction (user_id, meme_id) VALUES (?, ?)";
                        for (i = 0; i < results.length; i++) {
                            con.query(sql, [results[i].id, meme_id]);
                        }
                    });
                    response.write("Meme-upload successful");
                    response.end();
                }
            });
        } else {
            response.status(FORBIDDEN_STATUSCODE)
            response.write("Please enter data");
            response.end();
        }
    } else {
        response.status(FORBIDDEN_STATUSCODE)
        response.write("You forgot to signin memer ;)");
        response.end();
    }
});


app.get('/', function(request, response) {
    response.write("Awesome\n");
    response.end();
});

function convertBytesToText(bytes) {
    res = ""
    for (bytesPtr = 0; bytesPtr < bytes.length; bytesPtr++) {
        res += String.fromCharCode(bytes[bytesPtr])
    }
    return res
}

app.post('/download-meme', function(request, response) {
    if (request.session.loggedin) {
        sql = "SELECT top_memes_for_user.meme_id, top_memes_for_user.user_id, \
            top_memes_for_user.reaction, top_memes_for_user.score, memes.data \
            FROM (SELECT * FROM user_meme_interaction WHERE user_id = ? AND reaction = '0' ORDER BY score  DESC LIMIT ?) \
            AS top_memes_for_user \
            JOIN memes ON top_memes_for_user.meme_id = memes.id;"
        con.query(sql, [request.session.user_id, maxDownloadCount], function(error, results) {
            if (error) {
                response.status(FORBIDDEN_STATUSCODE)
                response.write("Error occurred. Please try again.");
                throw error;
            } else {
                toSend = []
                for (i = 0; i < results.length; i++) {
                    data = convertBytesToText(results[i].data)
                    toSend.push({
                        "meme_id" : results[i].meme_id,
                        "user_id" : results[i].user_id,
                        "reaction" : results[i].reaction, 
                        "score" : results[i].score, 
                        "data" : data
                    });
                }
                response.json(toSend);
            }
            response.end();
        });
    } else {    
        response.status(FORBIDDEN_STATUSCODE)
        response.write("Please signin to download-meme");
        response.end();
    }
})

app.post('/react-meme', function(request, response) {
    if (request.session.loggedin) {
        user_id = request.session.user_id;
        meme_id = request.body.meme_id;
        reaction = request.body.reaction;
        if (meme_id && reaction) {
            sql = "UPDATE user_meme_interaction \
                SET reaction = ? \
                WHERE user_id = ? AND meme_id = ?"
            con.query(sql, [reaction, user_id, meme_id], function(err, res) {
                if (err) {
                    throw err;
                } else {
                    console.log(res)
                    if (res.affectedRows > 0) {
                        response.write("Reaction Updated")
                        response.end()
                    } else {
                        response.status(FORBIDDEN_STATUSCODE)
                        response.write("Incorrect meme_id")
                        response.end()
                    }
                }
            })
        } else {
            response.status(FORBIDDEN_STATUSCODE)
            response.write("Please provide meme_id and reaction")
            response.end()
        }
    } else {
        response.status(FORBIDDEN_STATUSCODE)
        response.write("Please signin");
        response.end();
    }
})

app.post('/delete-meme', function(request, response) {
    if (request.session.loggedin) {
        user_id = request.session.user_id;
        meme_id = request.body.meme_id;
        if (meme_id) {
            sql = "SELECT id FROM memes WHERE upload_user_id = ? AND id = ?;";
            con.query(sql, [user_id, meme_id], function(error, results) {
                if (error) {
                    throw error;
                } else {
                    if (results.length > 0) {
                        sql = "DELETE FROM memes WHERE upload_user_id = ? AND id = ?;";
                        con.query(sql, [user_id, meme_id], function(error, results) {
                            response.write("Deleted Successfully");
                            response.end();
                        });
                    } else {
                        response.status(FORBIDDEN_STATUSCODE)
                        response.write("Can't delete, meme is not yours!");
                        response.end();
                    }
                }
            });
        } else {
            response.status(FORBIDDEN_STATUSCODE)
            response.write("Please send meme_id");
            response.end();
        }
    } else {
        response.status(FORBIDDEN_STATUSCODE)
        response.write("Please signin");
        response.end();
    }
})

app.post('/delete-user', function(request, response) {
    if (request.session.loggedin) {
        user_id = request.session.user_id;
        sql = "DELETE FROM users WHERE id = ?";
        con.query(sql, [user_id], function(error) {
            if (error) {
                throw error;
            } else {
                request.session.loggedin = false;
                response.write("Congratulations! You have removed yourself!!");
            }
            response.end();
        })
    } else {
        response.status(FORBIDDEN_STATUSCODE)
        response.write("Please signin");
        response.end();
    }
    
})




const PORT = process.env.PORT || 8080;
app.listen(PORT);