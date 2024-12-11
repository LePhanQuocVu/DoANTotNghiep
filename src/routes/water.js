var express  = require('express');
var router = express.Router();

var waterController = require('../controllers/WaterController');


router.use('/', waterController.getData);


module.exports = router;