const mongoose = require("mongoose");

const firmWareSchema = new mongoose.Schema({
    version: {
        type:  String,
        require: true
    },
    description: {
        type: String
    },
    fileName: {
        type: String,
        required: true,
    }
}, {timestamps: true})

module.exports = mongoose.model("Firmware", firmWareSchema);