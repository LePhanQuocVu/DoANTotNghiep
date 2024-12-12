var express  = require('express');
var waterRouter = express.Router();

var Water = require('../controllers/WaterController');


waterRouter.put('/api/water/update/:id', Water.updateDevice);

module.exports = waterRouter;