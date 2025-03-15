
const { json } = require('express');
const Water = require('../models/WaterMeterModel');
const WaterMeter = require('../models/WaterMeterModel');
const mongoose = require('mongoose');

class WaterController {
    
    createDevice = async(req, res) => {
        try{
            const {user_id, deviceType, location, status, longitude, latitude} = req.body;
            if(!user_id) {
                return res.status(400).json({msg: "Bad Request, User_id required"});
            }
            const existingDevice = await WaterMeter.findOne({user_id});
            if(existingDevice) {    
                return res.status(400).json({msg: "User đã cài đặt thiết bị!"});
            }

            // create waterDevice
            const newDevice = new WaterMeter({
                deviceType: deviceType, // loại đồng hồ
                user_id: user_id, // Lấy user_id từ req.body
                location: location, //location
                status: status || false, // Default là false
                cordinates: {
                    longitude: longitude,
                    latitude: latitude,
                },
            });
            const waterDevice = await newDevice.save();
            if(!waterDevice) {
                return res.status(400).json({msg: "Không thể tạo thiết bị!"});
            }
            return res.status(200).json(waterDevice);
        } catch(e) {
            console.log(e);
            return res.status(500).json({msg: "Error from Server"});
        }
    } 
    getDeviceByUserId = async(req, res) => {
        try{
            const user_id = req.params.id;
            console.log(req.params);
            console.log(user_id);
            if(!user_id) {
                return res.status(400).json({msg: "Người dùng chưa cài đặt!"})
            }
            const device = await WaterMeter.find({user_id: user_id});
            console.log(device);
            if(!device) {
                return res.status(400).json({msg: "Error"});
            }
            return res.status(200).json(device);

        }
        catch(e) {
            console.log(e);
        }
    }

    updateDevice = async(req, res) => {
        try {
            const deviceId = req.params.id;
            console.log(deviceId);
            const {deviceType, location, status} = req.body;
           
            const device =  await WaterMeter.findById(deviceId);
            if(!device) {
                return res.status(400).json({msg: "Device not exit"});
            }

            //update information
            device.deviceType = deviceType || device.deviceType;
            device.status = status || device.status;
            device.location = location || device.location;
            device.status = status || device.status;

            const deviceUpdated = await device.save();
            
            if(!deviceUpdated) {
                return res.status(404).json({msg: "Not updated"});
            }
            return res.status(200).json(deviceUpdated);
        }
        catch (e){
            console.error(e);
            return res.status(500).json({error: e.message});
        }
    }
    getDataByDay = async (req,res) => {
        try {
            const userId = req.params.id;
            // const type = 'day';
            const {date, type,} = req.query;
            if(!date) {
                return res.status(400).json({msg: "Vui lòng chọn ngày!"});
            }
             // Kiểm tra userId hợp lệ
            if (!mongoose.Types.ObjectId.isValid(userId)) {
                return res.status(400).json({ error: "User ID không hợp lệ!" });
            }
            const objectId = new mongoose.Types.ObjectId(userId);
            let startDate;
            let endDate;
            startDate = new Date(date);
            startDate.setUTCHours(0, 0, 0, 0);
            endDate = new Date(date);
            endDate.setUTCHours(23, 59, 59, 999);

            // Truy vấn MongoDB
            const result = await WaterMeter.aggregate([
                { $match: { user_id: objectId } }, // Lọc theo userId
                { $unwind: "$data" }, // Mở mảng `data`
                { $match: { "data.timestamp": { $gte: startDate, $lte: endDate } } }, // Lọc theo thời gian
                {
                    $group: {
                        // _id: type === "day" ? null : { $dateToString: { format: "%Y-%m-%d", date: "$data.timestamp" } },
                        _id: { $dateToString: { format: "%Y-%m-%d", date: "$data.timestamp" } }, // Nhóm theo ngày
                        totalFlow: { $sum: "$data.value" }, // Tính tổng
                        // records: { $push: "$data" } // Giữ lại dữ liệu từng ngày
                    }
                },
                { $sort: { "_id": 1 } }
            ]);
            const formattedResult = result.map(item => ({
                date: item._id, // Chuyển _id thành date
                totalFlow: item.totalFlow
            }));
           const totalAllDays = formattedResult.reduce((sum, item) => sum + item.totalFlow, 0)
            // Trả về dữ liệu
            return res.status(200).json({totalAllDays,data: formattedResult});
           
        } catch(e) {
            console.error("❌ Lỗi lấy dữ liệu:", e);
            res.status(500).json({ error: "Lỗi server!" });
        }
    }
    getDataByRange = async (req,res) => {
        try {
        const userId = req.params.id;
        const { start, end} = req.query;
        if ((!start || !end)) {
            return res.status(400).json({ error: "Vui lòng cung cấp ngày hoặc khoảng thời gian" });
        }
        if (!mongoose.Types.ObjectId.isValid(userId)) {
            return res.status(400).json({ error: "User ID không hợp lệ!" });
        }
        const objectId = new mongoose.Types.ObjectId(userId);
        let startDate, endDate;
        // Nếu người dùng truyền `start` và `end`
        startDate = new Date(start);
        startDate.setUTCHours(0, 0, 0, 0);
        endDate = new Date(end);
        endDate.setUTCHours(23, 59, 59, 999);

        console.log("Start Date:", startDate);
        console.log("End Date:", endDate);

        const result = await WaterMeter.aggregate([
            { $match: { user_id: objectId } }, // Lọc theo userId
            { $unwind: "$data" }, // Mở rộng mảng data
            { $match: { "data.timestamp": { $gte: startDate, $lte: endDate } } }, // Lọc theo thời gian
            {
                $group: {
                    _id: { $dateToString: { format: "%Y-%m-%d", date: "$data.timestamp" } }, // Nhóm theo ngày
                    totalFlow: { $sum: "$data.value" }, // Tổng giá trị theo ngày
                }
            },
            { $sort: { "_id": 1 } } // Sắp xếp theo ngày tăng dần
        ]);

        const formattedResult = result.map(item => ({
            date: item._id, // Chuyển _id thành date
            totalFlow: item.totalFlow
        }));

       // Tính tổng của tất cả các ngày
       const totalAllDays = formattedResult.reduce((sum, item) => sum + item.totalFlow, 0);

       // Nếu không có dữ liệu, trả về thông báo
       if (formattedResult.length === 0) {
           return res.json({ msg: "Không có dữ liệu trong khoảng thời gian này", totalAllDays: 0, data: [] });
       }

       // Trả về dữ liệu có tổng
       return res.status(200).json({ totalAllDays, data: formattedResult });

        } catch (error) {
            console.error("❌ Lỗi lấy dữ liệu tuần:", error);
            res.status(500).json({ error: "Lỗi server!" });
        }
    }
}


module.exports = new WaterController;