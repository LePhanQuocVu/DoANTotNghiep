const { json } = require('express');
const WaterMeter = require('../models/WaterMeterModel');
const User = require('../models/UserModel');
const Notification = require('../models/NotificationModel');
const mongoose = require('mongoose');
const { sendNotification } = require('../helper/sendNotify');
const { hashToken } = require('../helper/hashAccessToken');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const CoreIOTClient = require('../controllers/CoreIotController');
let coreIOTClientInstance = null;
class WaterController {
    
    createDevice = async(req, res) => {
        try{
            const {user_id, deviceType, location, status, longitude, latitude, iotToken} = req.body;
            if(!user_id) {
                return res.status(400).json({msg: "Bad Request, User_id required"});
            }
            const existingDevice = await WaterMeter.findOne({user_id});
            if(existingDevice) {    
                return res.status(400).json({msg: "User đã cài đặt thiết bị!"});
            }

            // const hashedToken = await hashToken(iotToken);
            // create waterDevice
            const newDevice = new WaterMeter({
                deviceType: deviceType, // loại đồng hồ
                user_id: user_id, // Lấy user_id từ req.body
                location: location, //location
                status: status || true, // Default là false
                longitude: longitude,
                latitude: latitude,
                iotToken: iotToken || null,
            });

            // // connect to CoreIOT
            // coreIOTClientInstance = new CoreIOTClient(iotToken);
            console.log(`CorreIOT Instance: ${coreIOTClientInstance}`);
            const waterDevice = await newDevice.save();
            if(!waterDevice) {
                return res.status(400).json({msg: "Không thể tạo thiết bị!"});
            } 
            // Create devce and update to MongoDB

            const newNotify = new Notification({
                userId: user_id,
                title: "Tạo mới thành công!",
                message: "Đã lắp đặt thiết bị thành công!",
                type: "infor",
                isRead: false
            });

            // Save to mongo
            /**Todo */
            const newNotification = await newNotify.save();
            if(!newNotification) {
                res.status(400).json({msg: "Lưu không thành công"})
            }
            // send tofication to FCM 
            const user = await User.findById(user_id).select('fcmToken');// laytoken tu device
            const fcmToken = user.fcmToken;
            console.log('FCM token get from user to push notify: '  + user.fcmToken); 
            await sendNotification(fcmToken, "Thông báo", "Tạo thiết bị thành công!");
            res.status(200).json(waterDevice);
        } catch(e) {
            console.log(`Loi: ${e}`);
            return res.status(500).json({msg: "Error from Server"});
        }
    } 

    // GET ALL DEVICE

    getAllDevices = async(req, res) => {
        try{
            const devices = await WaterMeter.find().select('-data');
            console.log(devices);
            if(devices.length == 0) {
                return res.status(200).json({msg: "Chưa có thiết bị cài đặt"});
            }
            return res.status(200).json({allDevices: devices});
        } catch (e){
            console.log(e);
        }
    }

    // GET DEVICE BY ID
    getDeviceByUserId = async(req, res) => {
        try{
            const user_id = req.params.id;
            if(!user_id) {
                return res.status(400).json({msg: "Người dùng chưa cài đặt!"})
            }
            const device = await WaterMeter.find({user_id: user_id}).select('-data');
            console.log(device);
            if(device.length == 0) {
                return res.status(400).json({msg: "Người dùng chưa cài đặt thiết bị"});
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
            const {deviceType, location, status, longitude, latitude} = req.body;
            const device =  await WaterMeter.findById(deviceId).select('-data');
            if(!device) {
                return res.status(400).json({msg: "Device not exit"});
            }

            //update information
            device.deviceType = deviceType || device.deviceType;
            device.status = status || device.status;
            device.location = location || device.location;
            device.status = status || device.status;
            device.longitude = longitude || device.longitude;
            device.latitude = latitude || device.latitude;

            const deviceUpdated = await device.save();
            
            if(!deviceUpdated) {
                return res.status(404).json({msg: "Not updated"});
            }
            return res.status(200).json(deviceUpdated);
        }
        catch (e){
            console.log(`Loi update device: ${e}`);
            return res.status(500).json({error: e.message});
        }
    }

    deleteDevice = async (req,res) => {
        try {
            const userId = req.params.id;
    
            if (!userId) {
                return res.status(400).json({ msg: "Thiếu userId để xoá thiết bị!" });
            }
    
            // Tìm và xoá tất cả thiết bị có userID
            const result = await WaterMeter.deleteMany({ user_id: userId });
    
            if (result.deletedCount === 0) {
                return res.status(404).json({ msg: "Không tìm thấy thiết bị để xoá!" });
            }
    
            // Ghi log hoặc gửi thông báo nếu cần
            const newNotify = new Notification({
                userId: userId,
                title: "Xoá thiết bị",
                message: "Thiết bị đã được xoá thành công!",
                type: "warning",
                isRead: false
            });
    
            await newNotify.save();
    
            return res.status(200).json({ msg: `User Đã xoá ${result.deletedCount} thiết bị.` });
        } catch (e) {
            console.error('Lỗi xoá thiết bị: ', e);
            return res.status(500).json({ msg: "Lỗi máy chủ khi xoá thiết bị." });
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
            console.error(" Lỗi lấy dữ liệu:", e);
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

        console.log(result);
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
            console.error(" Lỗi lấy dữ liệu tuần:", error);
            res.status(500).json({ error: "Lỗi server!" });
        }
    }

    getLocationAllDevices = async(req,res) => {
        try {
            const devices = await WaterMeter.find({}, { location: 1, longitude: 1, latitude: 1, _id: 0 });
            if(devices.length == 0) {
                res.status(200).json({msg: 'Không thiết bị nào tìm thấy'});
            } else {
                res.status(200).json({devicesLocation: devices});
            }
        } catch (e) {
            console.log(`Error get location: ${e}`);
            res.status(500).json({e: "Server Error get locationtion"});
        }

    }

    getDataByDate = async(req,res) => {

    }

    getDataHours = async(req,res) => {
        try {
            const { id } = req.params;
            const date = new Date(req.query.date);
    
            // Lấy 1 ngày cụ thể
            const startOfDay = new Date(date.setHours(0, 0, 0, 0));
            const endOfDay = new Date(date.setHours(23, 59, 59, 999));
            console.log(`id: ${id}`);
            const device = await WaterMeter.findById(id);
            if (!device) return res.status(404).json({ message: "Device not found" });
    
            // Lọc dữ liệu theo ngày
            const hourlyData = device.data.filter(d => {
                const ts = new Date(d.timestamp);
                return ts >= startOfDay && ts <= endOfDay;
            }).map(d => ({
                time: new Date(d.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
                value: d.value
            }));
    
            res.json(hourlyData);
        } catch (err) {
            res.status(500).json({ message: err.message });
        }
    }

    getDataDaily = async (req, res) => {
        try {
            const { id } = req.params;
            const selectedDate = new Date(req.query.date); // chỉ truyền 1 ngày
        
            if (isNaN(selectedDate)) {
              return res.status(400).json({ message: "Invalid date format" });
            }
        
            // Tính ngày đầu và cuối tháng từ ngày truyền vào
            const start = new Date(selectedDate.getFullYear(), selectedDate.getMonth(), 1);
            const end = new Date(selectedDate.getFullYear(), selectedDate.getMonth() + 1, 0); // ngày cuối tháng
            start.setHours(0, 0, 0, 0);
            end.setHours(23, 59, 59, 999);
        
            const device = await WaterMeter.findById(id);
            if (!device) return res.status(404).json({ message: "Device not found" });
        
            const dailyMap = {};
        
            device.data.forEach(d => {
              const ts = new Date(d.timestamp);
        
              if (ts >= start && ts <= end) {
                const dateStr = ts.toLocaleDateString("en-CA"); // YYYY-MM-DD
                if (!dailyMap[dateStr]) dailyMap[dateStr] = [];
                dailyMap[dateStr].push(d.value);
              }
            });
        
            const dailyData = Object.entries(dailyMap).map(([date, values]) => ({
              date,
              value: values.reduce((a, b) => a + b, 0),
            }));
        
            res.json(dailyData);
          } catch (err) {
            res.status(500).json({ message: err.message });
          }
    }

    getDataWeekly = async (req, res) => {
        try {
            const { id } = req.params;
            const selectedDate = new Date(req.query.date);
    
            if (isNaN(selectedDate)) {
                return res.status(400).json({ message: "Invalid date format" });
            }
    
            const year = selectedDate.getFullYear();
            const month = selectedDate.getMonth(); // 0-indexed (0 = January)
    
            const startOfMonth = new Date(year, month, 1);
            const endOfMonth = new Date(year, month + 1, 0);
            startOfMonth.setHours(0, 0, 0, 0);
            endOfMonth.setHours(23, 59, 59, 999);
    
            const device = await WaterMeter.findById(id);
            if (!device) return res.status(404).json({ message: "Device not found" });
    
            const weeklyMap = {
                "Week 1": [],
                "Week 2": [],
                "Week 3": [],
                "Week 4": [],
                "Week 5": [] // trường hợp tháng có hơn 28 ngày
            };
    
            device.data.forEach(d => {
                const ts = new Date(d.timestamp);
    
                if (ts >= startOfMonth && ts <= endOfMonth) {
                    const day = ts.getDate();
    
                    let weekLabel;
                    if (day >= 1 && day <= 7) weekLabel = "Week 1";
                    else if (day >= 8 && day <= 14) weekLabel = "Week 2";
                    else if (day >= 15 && day <= 21) weekLabel = "Week 3";
                    else if (day >= 22 && day <= 28) weekLabel = "Week 4";
                    else weekLabel = "Week 5"; // từ 29 đến hết tháng
    
                    weeklyMap[weekLabel].push(d.value);
                }
            });
    
            // Chỉ trả về các tuần có dữ liệu
            const weeklyData = Object.entries(weeklyMap)
                .filter(([_, values]) => values.length > 0)
                .map(([week, values]) => ({
                    week,
                    value: values.reduce((a, b) => a + b, 0)
                }));
    
            res.json(weeklyData);
        } catch (err) {
            res.status(500).json({ message: err.message });
        }
    };
    

    getDataMonthly = async (req, res) => {
        try {
            const { id } = req.params;
            const selectedDate = new Date(req.query.date);
    
            if (isNaN(selectedDate)) {
                return res.status(400).json({ message: "Invalid date format" });
            }
    
            const year = selectedDate.getFullYear();
    
            const device = await WaterMeter.findById(id);
            if (!device) return res.status(404).json({ message: "Device not found" });
    
            const monthlyMap = {
                Jan: [],
                Feb: [],
                Mar: [],
                Apr: [],
                May: [],
                Jun: [],
                Jul: [],
                Aug: [],
                Sep: [],
                Oct: [],
                Nov: [],
                Dec: []
            };
    
            const monthNames = Object.keys(monthlyMap);
    
            device.data.forEach(d => {
                const ts = new Date(d.timestamp);
    
                if (ts.getFullYear() === year) {
                    const monthIndex = ts.getMonth(); // 0-11
                    const monthName = monthNames[monthIndex];
                    monthlyMap[monthName].push(d.value);
                }
            });
    
            const monthlyData = monthNames.map(month => ({
                month,
                value: monthlyMap[month].reduce((a, b) => a + b, 0)
            }));
    
            res.json(monthlyData);
        } catch (err) {
            res.status(500).json({ message: err.message });
        }
    };
    
}

module.exports = {
    waterController: new WaterController(),
    getCoreIOTClientInstance: () => coreIOTClientInstance,
};