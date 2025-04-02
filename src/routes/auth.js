var express  = require('express');
var authRouter = express.Router();
var UserController = require('../controllers/UserController')

authRouter.post("/api/register", UserController.registerUser);
authRouter.post("/api/login", UserController.loginUser);

module.exports = authRouter;