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
    type: {
        type: String,
        enum: ['alert', 'warning', 'infor'],
        default: 'info'
    },
    isRead: {
        type: Boolean,
        default: false
    },
}, {timestamps: true});

module.exports = mongoose.model("notifications",notifySchema);