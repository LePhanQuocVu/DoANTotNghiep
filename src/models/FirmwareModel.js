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
    },
    filePath: {
        type: String,
        required: true
    },
    uploadedAt: {
        type: Date,
        default: Date.now
    }
})

module.exports = mongoose.model("Firmware", firmWareSchema);