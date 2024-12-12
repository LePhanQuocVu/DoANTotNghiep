const mongoose = require("mongoose");

const Schema = mongoose.Schema;

const deviceSchema = new Schema({
    location: { type: String, default: null},
    status: {type: Boolean, default: false},
    timestamp: { 
        type: Date, 
        default: Date.now 
    },
})

const WaterMeter = mongoose.model('waters', deviceSchema);
module.exports = WaterMeter;

