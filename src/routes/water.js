var express  = require('express');
var waterRouter = express.Router();

var Water = require('../controllers/WaterController');

waterRouter.post('/api/water/create', Water.createDevice);
waterRouter.put('/api/water/update/:id', Water.updateDevice);

waterRouter.get('/api/water/getByUserId/:id', Water.getDeviceByUserId);

module.exports = waterRouter;