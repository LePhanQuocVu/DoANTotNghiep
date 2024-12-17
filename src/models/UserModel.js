const mongoose = require('mongoose');

const Schema = mongoose.Schema;

const userSchema = new Schema({
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, require: true},
    age: { type: Number, default: null },  
    phone: {type: String,  default: null },
    address: {type: String,  default: null},
    create_at: {type: Date, default: Date.now}
});

const User = mongoose.model('users', userSchema);
module.exports = User;  
