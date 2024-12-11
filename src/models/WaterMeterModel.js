const mongoose = require('mongoose');

const Schema = mongoose.Schema;

const waterModel = new Schema({
    deviceId: { 
        type: String, 
        required: true 
    }, 
    flowRate: { 
        type: Number, 
        required: false 
    }, 
    timestamp: { 
        type: Date, 
        default: Date.now 
    },
    location: { 
        type: String, 
        required: false 
    },
});


const Water = mongoose.model('waters',waterModel);
module.exports = Water;