var express  = require('express');
var waterRouter = express.Router();

var Water = require('../controllers/WaterController');

waterRouter.post('/api/water/create', Water.createDevice);
waterRouter.put('/api/water/update/:id', Water.updateDevice);

waterRouter.get('/api/device/getByUserId/:id', Water.getDeviceByUserId);

waterRouter.get('/api/device/daily/:id', Water.getDataByDay);

waterRouter.get('/api/device/range/:id', Water.getDataByRange);

module.exports = waterRouter;