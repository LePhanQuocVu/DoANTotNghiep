const { json } = require('express');
var bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const User = require('../models/UserModel');
class UserController {
    // GET ALL USER
    getAllUser = async (req, res) => {
        try{
            const users = await User.find();
            console.log(users);
            return res.status(200).json(users);
        }catch(err){
            return res.status(500).json(err);
        }
    }
    // get UserbyID
    getUserById = async (req,res) => {
        try {
            const userId = req.params.id;
            console.log(userId);
            const user = await User.findById(userId); // Tìm user theo ID
            if (!user) {
                return res.status(404).json({ message: 'User not found' });
            }
            return res.status(200).json(user);
        } catch(err) {
            return res.status(500).json({ message: 'Error retrieving user', error: err });
        }
    }
    // GET :slug
    // POST register usser
    registerUser = async (req, res) => {
        try{
            const { name, email, password} = req.body;
            console.log(req.body);
            const existingUser = await User.findOne({email});
            if(existingUser) {
                return res
                .status(400)
                .json({msg: "Tài khoản email đã tồn tại!"});
            }
            const hashpassword = await bcrypt.hash(password,8);
            let user = User({
                name: name,
                email: email,
                password: hashpassword
            });
            user = await user.save();
            res.json(user);
        } catch(e) {
            res.status(500).json({error: e.message});
        }
    }
    
    /** POST login  */
    loginUser = async (req, res) => {
        try{
            const { email, password } = req.body;
            console.log(req.body);
            const user = await User.findOne({email});

            if(!user) {
                return res
                .status(400)
                .json({msg: "Email không tồn tại!"});
            }
            var isMatch = await bcrypt.compare(password, user.password);
            if(!isMatch) {
                return res
                    .status(400)
                    .json({msg: "Mật khẩu không đúng!"});
            }

            const token = jwt.sign({id: user._id}, "passwordKey");
            res.json({token, ...user._doc});

        }catch(e) {
            res.status(500).json({error: e.message});
        }
    }
    show(req,res) {
        res.send("Lấy được user!");
    }
}

module.exports = new UserController;