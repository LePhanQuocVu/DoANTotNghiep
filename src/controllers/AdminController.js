
const User = require('../models/UserModel');

class AdminController {
    login = async(req,res) =>{
        try {
            const {adminName, adminPass} = req.body;
            if(adminName == 'admin' && adminPass == 'admin') {
                return res.status(200).json({msg: 'Đăng nhập thành công!'});
            }
            if(adminName != 'admin' && adminPass != 'admin') {
                return res.status(200).json({msg: 'Đăng nhập thành công!'});
            }
        } catch (e) {
            return res.status(500).json({msg: e});
        }
    }
    getAllUsers = async(req,res) => {
         try{
            const users = await User.find({});
            if(users.length == 0) {
                return res.status(400).json({msg: "No user!"});
            } 
            return res.status(200).json(users);
        }catch(err){
            return res.status(500).json(err);
        }
    }

}

module.exports = new AdminController;

   