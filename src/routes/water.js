var express  = require('express');
var waterRouter = express.Router();

const { waterController } = require('../controllers/WaterController');

/********** USER */
/** Device  */
waterRouter.post('/api/create', waterController.createDevice);
waterRouter.put('/api/update/:id', waterController.updateDevice);
waterRouter.get('/api/getDeviceByUserId/:id', waterController.getDeviceByUserId);
waterRouter.delete('/api/deleteDevice/:id', waterController.deleteDevice);
/** HISTORY */

waterRouter.get('/api/device/daily/:id', waterController.getDataByDay);
waterRouter.get('/api/device/range/:id', waterController.getDataByRange);


module.exports = waterRouter;