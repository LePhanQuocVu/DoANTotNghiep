const express = require('express');
const adminRouter = express.Router();

var  UserController = require('../controllers/UserController');
var WaterController = require('../controllers/WaterController');
/** GET ALL USER */

adminRouter.get('/api/getAllUsers', UserController.getAllUsers);

/********** ADMIN */
/**Devices */
adminRouter.get('/api/getAllDevices', WaterController.getAllDevices);

module.exports = adminRouter;