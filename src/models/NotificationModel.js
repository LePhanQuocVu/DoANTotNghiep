const mongoose = require('mongoose');

const Schema = mongoose.Schema;

const notifySchema = new Schema({
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
        default: 'infor'
    },
    isRead: {
        type: Boolean,
        default: false
    },
}, {timestamps: true});

const Notification= mongoose.model("notifications",notifySchema);
module.exports = Notification;