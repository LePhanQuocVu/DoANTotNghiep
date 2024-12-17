const mongoose = require("mongoose");

const Schema = mongoose.Schema;

const deviceSchema = new Schema({
    user_id: {
        type: Schema.Types.ObjectId,
        ref: "user", // 1 :1 
        require: true,
    },
    location: { type: String, require: true},
    status: {type: Boolean, default: false},
    bateryLevel: {type: Number, default: 100}, // 100% batery
    create_at: { 
        type: Date, 
        default: Date.now 
    },
});

const WaterMeter = mongoose.model('waterdevice', deviceSchema);
module.exports = WaterMeter;

