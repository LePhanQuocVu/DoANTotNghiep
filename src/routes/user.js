var express = require('express');
var userRouter = express.Router();

var User = require('../controllers/UserController');

userRouter.get("api/users/id", User.getUserById);

module.exports = userRouter;
