const express = require('express');
const adminRouter = express.Router();

// var  UserController = require('../controllers/UserController');
const { waterController } = require('../controllers/WaterController');

// var AdminController = require('../controllers/AdminController') 
var UserController = require('../controllers/UserController');
const  AdminController = require('../controllers/AdminController');

/** GET ALL USER */
adminRouter.get('/api/getAllUsers', AdminController.getAllUsers);

/********** ADMIN */
/**Devices */
adminRouter.get('/api/getAllDevices', waterController.getAllDevices);

module.exports = adminRouter;