var express = require('express');
var userRouter = express.Router();

var User = require('../controllers/UserController');

// userRouter.put("api/users/:id", User.updateUser);
userRouter.get("/api/user/:id", User.getUserById);
userRouter.get("/api/users", User.getAllUser);

// update infomation
userRouter.put("/api/user/update/:id", User.updateUser);

module.exports = userRouter;
