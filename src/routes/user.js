var express = require('express');
var userRouter = express.Router();

var UserController = require('../controllers/UserController');

userRouter.post("/api/register", UserController.registerUser);
userRouter.post("/api/login", UserController.loginUser);


// userRouter.put("api/users/:id", User.updateUser);
userRouter.get("/api/getById/:id", UserController.getUserById);
// update infomation
userRouter.put("/api/update/:id", UserController.updateUser);

// // update firmare
// userRouter.post("api/updateFirm/:id", UserController.updateFirmware);

// udpate fcmToken
userRouter.put("/api/:userId/updateFcmToken", UserController.updateFcmToken);
// postNotification

userRouter.post("/api/notification", UserController.notification);


module.exports = userRouter;
