var express = require('express');
var router = express.Router();
var jwt = require('express-jwt');
var passport = require('passport');
var http = require('http').Server(express);


var users = {};

/* GET home page. */
router.get('/', function(req, res) {
    res.render('index', { title: 'Express' });
});


var mongoose = require('mongoose');
var User = mongoose.model('User');

var auth = jwt({secret: 'SECRET', userProperty: 'payload'});


http.listen(8100, function(){
    console.log('Listening on *:8100');
});


router.post('/login', function(req, res, next){
    if(!req.body.username || !req.body.password){
        return res.status(400).json({message: 'Please fill out all fields'});
    }
        passport.authenticate('local', function (err, user, info) {
            if (err) {
                return res.status(401).json({message :'Wrong Credentials entered'});
                
            }
            if (user) {
                return res.json({token: user.generateJWT(), user: user});
                
            } else {
                return res.status(401).json({message :'Error logging in'});
            }
        })(req, res, next);
});


router.post('/register', function(req, res, next){
    console.log("registering");
    if(!req.body.username || !req.body.password || !req.body.firstName || !req.body.lastName ){
        return res.status(400).json({message :'Please fill out all fields'});
    }
        var user = new User();

        user.username = req.body.username;
        user.setPassword(req.body.password);
        user.firstName = req.body.firstName;
        user.lastName = req.body.lastName;
        user.email = req.body.email;

        user.save(function (err) {
            if (err) {
                return next(err);
            }
            return res.json({token: user.generateJWT(), user: user})
        });

});



module.exports = router;
