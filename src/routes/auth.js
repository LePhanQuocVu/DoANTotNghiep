var express  = require('express');
var authRouter = express.Router();
var User = require('../controllers/UserController')

authRouter.post("/api/register", User.registerUser);
authRouter.post("/api/login", User.loginUser);

module.exports = authRouter;