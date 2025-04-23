const express = require('express');
const adminRouter = express.Router();
const multer = require('multer');
const path = require('path');

const upload = multer({ dest: 'uploads/' }); // tạm lưu

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


/**LOCATION */

adminRouter.get('/api/getLocationAllDevices', waterController.getLocationAllDevices);

/** GET HISTORY DATA */


adminRouter.get('/api/getHistory/:id/byDate', waterController.getDataByDate);
adminRouter.get('/api/getHistory/:id/hourly', waterController.getDataHours);
adminRouter.get('/api/getHistory/:id/daily', waterController.getDataDaily);
adminRouter.get('/api/getHistory/:id/weekly', waterController.getDataWeekly);
adminRouter.get('/api/getHistory/:id/monthly', waterController.getDataMonthly);


/** UPLOAD FIRMWARE\ */

adminRouter.post('/api/uploadFirmware', upload.single('firmware'), AdminController.uploadFirmWare);
adminRouter.get('/api/getAllFirmwares', AdminController.getAllFirmwares);

module.exports = adminRouter;