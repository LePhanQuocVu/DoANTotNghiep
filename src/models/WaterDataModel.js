const mongoose = require('mongoose');

const Schema = mongoose.Schema;

const dataWaterSchema = new Schema({
    flow_rate: [ {
        flow_rate: { type: Number, required: true }, // Giá trị tốc độ
        timestamp: { type: Date, default: Date.now } // Thời gian ghi nhận
    }],
    device_id: {
        type: Schema.Types.ObjectId,
        ref: 'waterDevice',
        require: true,
    },
    user_id: {
        type: Schema.Types.ObjectId,
        ref: 'users',
        require: true
    },
    
});

const DataFlow = mongoose.model('waterData', dataWaterSchema);

module.exports = DataFlow;