const { lazyrouter } = require("express/lib/application");
const mongoose = require("mongoose");

const Schema = mongoose.Schema;

const deviceSchema = new Schema({
    user_id: {
        type: Schema.Types.ObjectId,
        ref: "user", // 1 :1 
        require: true,
    },
    location: { type: String, required: true},
    deviceType: {type: String, required: true},
    status: {type: Boolean, default: true}, // new device setup
    bateryLevel: {type: Number, default: 100}, // 100% batery
    longitude: { type: String, required: true},
    latitude: { type: String, required: true},
    iotToken: {type: String, required: false},
    data: {
        type: [
            {
                value: { type: Number, required: true },
                timestamp: { type: Date, default: Date.now },
                _id: false,        }
        ],
        default: [], // dafault empty
    }
    }, 
    {timestamps: true}
);

const WaterMeter = mongoose.model('waterdevice', deviceSchema);
module.exports = WaterMeter;

