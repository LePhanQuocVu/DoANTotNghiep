const path = require('path');
const fs = require('fs');
const User = require('../models/UserModel');
const FirmwareModel = require('../models/FirmwareModel');

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

    uploadFirmWare = async(req,res) => {
        const { version, description } = req.body;

        if (!req.file) {
            return res.status(400).json({ msg: 'No file uploaded.' });
        }
    
        if (!version || !description) {
            return res.status(400).json({ msg: 'Version and description are required.' });
        }
        console.log(`Request: ${req.file}`);
        const tempPath = req.file.path;
        console.log(`file path: ${tempPath}`);
        
        // Tên file sẽ bao gồm version
        const fileName = `firmware-v0.bin`; // lưu vào folder

        const fileNameSaveToDBS = `firmware-${version}.bin`;
        const targetPath = path.join(__dirname, `../firmwares/${fileName}`);
    
        try {
            // Tạo thư mục nếu chưa có
            const firmwareDir = path.join(__dirname, '../firmwares');
            if (!fs.existsSync(firmwareDir)) {
                fs.mkdirSync(firmwareDir);
            }
    
            // Xóa file cũ nếu đã tồn tại cùng version
            if (fs.existsSync(targetPath)) {
                fs.unlinkSync(targetPath);
            }
    
            fs.renameSync(tempPath, targetPath);
            console.log('Firmware uploaded and saved at:', targetPath);
    
            // Lưu metadata (phiên bản và mô tả) vào file JSON hoặc database (ở đây dùng file tạm thời)
            const metadataPath = path.join(__dirname, '../firmwares/metadata.json');
            const metadata = fs.existsSync(metadataPath)
                ? JSON.parse(fs.readFileSync(metadataPath))
                : [];
    
            metadata.push({
                version,
                description,
                fileName,
                uploadedAt: new Date().toISOString()
            });
    
            fs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));
            

            // lưu firmware vào database

            const newFirmware = new FirmwareModel({
                version: version,
                description: description,
                fileName: fileNameSaveToDBS
            })

            await newFirmware.save();
            return res.status(200).json({
                msg: 'File uploaded and saved to DB successfully!',
                newFirmware
            });
            // return res.status(200).json({ msg: 'Firmware uploaded successfully!', version });
        } catch (err) {
            console.error('Upload failed:', err);
            return res.status(500).json({ msg: 'Failed to save firmware.' });
        }
    }

    getAllFirmwares = async(req,res) =>{
        try {
            const firmWares = await FirmwareModel.find().sort({ createdAt: -1 });
                // Kiểm tra xem có dữ liệu không
            if (!firmWares || firmWares.length === 0) {
                return res.status(400).json({ msg: "No firmware data found" });
            }
        
            // Trả về dữ liệu nếu thành công
            res.status(200).json({ msg: "Get firmware success", firmWares });
        
        } catch(error) {
            console.log('Error get Firware: ', error);
            res.status(500).json({msg: "Erro from server"});
        }
    }

}

module.exports = new AdminController;

   