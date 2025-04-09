var express  = require('express');
var waterRouter = express.Router();

var WaterController = require('../controllers/WaterController');

/********** USER */
/** Device  */
waterRouter.post('/api/create', WaterController.createDevice);
waterRouter.put('/api/update/:id', WaterController.updateDevice);
waterRouter.get('/api/getDeviceByUserId/:id', WaterController.getDeviceByUserId);
waterRouter.delete('/api/deleteDevice/:id', WaterController.deleteDevice);
/** HISTORY */

waterRouter.get('/api/device/daily/:id', WaterController.getDataByDay);
waterRouter.get('/api/device/range/:id', WaterController.getDataByRange);

// waterRouter.get('api/getAllUsers', )

module.exports = waterRouter;