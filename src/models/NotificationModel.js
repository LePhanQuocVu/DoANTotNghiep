const mongoose = require('mongoose');

const Schema = mongoose.Schema;

const notifySchema = Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "users",
        require: true
    },
    title: {
        type: String,
        require: true
    },
    message: {
        type: String,
        require: true
    },
    category: {
        type: String,
        default: "THong bao chung"
    },
    type: {
        type: String,
        enum: ['alert', 'warning', 'infor'],
        default: 'info'
    },
    read: {
        type: Boolean,
        default: false
    },
    metaData: {
        deviceId: String,
        serverity: String
    }
}, {timestamps: true});

module.exports = mongoose.model("notifications",notifySchema);