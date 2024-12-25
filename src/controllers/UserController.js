const { json } = require('express');
const mongoose = require('mongoose');
var bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const User = require('../models/UserModel');
class UserController {
    // GET ALL USER
    getAllUser = async (req, res) => {
        try{
            const users = await User.find({});
            return res.status(200).json(user);
        }catch(err){
            return res.status(500).json(err);
        }
    }
    // get UserbyID
    getUserById = async (req,res) => {
        try {
            const userId = req.params.id;
            console.log(req);
            console.log(typeof(userId));
             // Kiểm tra xem ID có hợp lệ không
            if (!mongoose.Types.ObjectId.isValid(userId)) {
                return res.status(400).json({ msg: "ID không hợp lệ!" });
            }
            const user = await User.findById(userId); // Tìm user theo ID
            if (!user) {
                return res.status(404).json({ message: 'User not found' });
            }
             //res.json(user);
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
            // create user
            let user = User({
                name: name,
                email: email,
                password: hashpassword
            });
            // save user
            user = await user.save();
            return res.status(200).json(user);
            // res.json(user);
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
            return res.status(200).json({token, ...user._doc});
           // res.json({token, ...user._doc});

        }catch(e) {
            res.status(500).json({error: e.message});
        }
    }
    show(req,res) {
        res.send("Lấy được user!");
    }


    /** METHOD: PUT ---------- UPDATE INFOR PART 1 */
    updateUser= async (req, res) => {
        try {
            const userId = req.params.id;
            const {name, email, age, address, phone} = req.body;

            if (!mongoose.Types.ObjectId.isValid(userId)) {
                return res.status(400).json({ msg: "ID không hợp lệ!" });
            }
            console.log(req.body);
            // find user to check email
            const user = await User.findById(userId);
            if(!user) {
                return res.status(400).json({msg: "User not exit"});
            }
             // check email exits
            if(email && email !== user.email) {
                const existingEmail = await User.findOne({email});
                if(existingEmail) {
                    return res.status(400).json({msg: "Email đã tồn tại!"});
                }
            }

            // update information
            user.name = name || user.name;
            user.email = email ||user.email;
            user.age = age || user.age;
            user.password = user.password;
            user.phone = phone || user.phone;
            user.address = address || user.address;
            
            const userUpdated = await user.save();
            if(!userUpdated) {
                return res.status(404).json({ msg: "Người dùng không tồn tại!" });
            }
            return res.status(200).json(userUpdated);
            }
        catch (e) {
            res.status(500).json({ error: e.message });
        }
    }
  
    /** METHOD: PUT ---------- UPDATE INFOR PART 2 -> Not use */
    // updateUser = async (req, res) => {
    //     try {
    //         const userId = req.params.id; // Lấy ID từ params
        
    //         const updates = req.body;
            
    //         console.log("User ID:", userId);
    //         console.log("Payload:", req.body);
    //         // Kiểm tra ID hợp lệ
    //         if (!mongoose.Types.ObjectId.isValid(userId)) {
    //             return res.status(400).json({ msg: "ID không hợp lệ!" });
    //         }
    //         // finde User
    //         const user = await User.findById(userId);
    //         if (updates.email && updates.email !== user.email) {
    //             const existingEmail = await User.findOne({ email: updates.email });
    //             if (existingEmail) {
    //                 return res.status(400).json({ msg: "Email đã tồn tại!" });
    //             }
    //         }
    //      //   Tìm user và cập nhật
    //         const updatedUser = await User.findByIdAndUpdate(
    //             userId, 
    //             updates,
    //             { new: true, runValidators: true } // Tùy chọn
    //         );
    //         // const update = await user.save();
    //         if (!updatedUser) {
    //             return res.status(404).json({ msg: "Người dùng không tồn tại!" });
    //         }
    //         // Trả về kết quả
    //         res.status(200).json(updatedUser);
    //     } catch (error) {
    //         res.status(500).json({ error: error.message });
    //     }
    // };
    
}

module.exports = new UserController;