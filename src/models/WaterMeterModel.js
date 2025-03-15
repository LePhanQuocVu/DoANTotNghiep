const { lazyrouter } = require("express/lib/application");
const mongoose = require("mongoose");

const Schema = mongoose.Schema;

const deviceSchema = new Schema({
    user_id: {
        type: Schema.Types.ObjectId,
        ref: "user", // 1 :1 
        require: true,
    },
    location: { type: String, require: true},
    deviceType: {type: String, require: true},
    status: {type: Boolean, default: false},
    bateryLevel: {type: Number, default: 100}, // 100% batery
    cordinates: {
        longitude: { type: String, require: true },
        latitude: { type: String, require: true },
    },
    create_at: { 
        type: Date, 
        default: Date.now 
    },
    data: {
        type: [
            {
                value: { type: Number, required: true },
                timestamp: { type: Date, default: Date.now },
                _id: false,        }
        ],
        default: [], // Mặc định là mảng rỗng
    }
});

const WaterMeter = mongoose.model('waterdevice', deviceSchema);
module.exports = WaterMeter;

