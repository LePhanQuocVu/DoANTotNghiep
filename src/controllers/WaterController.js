
const { json } = require('express');
const Water = require('../models/WaterMeterModel');
const WaterMeter = require('../models/WaterMeterModel');

class WaterController {
    // GET DATA
    // getData = async (req, res) => {
    //     try{
    //         console.log("Fetching data from watermeter...");
    //         const waterData = await Water.find();
    //         console.log("Retrieved data:", waterData);
    //         // const water = await Water.find();
    //         // console.log(water);
    //         return res.status(200).json(waterData);
    //     }catch(err){
    //         return res.status(500).json(err);
    //     }
    // }
    createDevice = async(req, res) => {
        try{
            const {user_id, type, location, status} = req.body;
            if(!user_id) {
                return res.status(400).json({msg: "Bad Request, User_id required"});
            }
            // create waterDevice
            const newDevice = new WaterMeter({
                deviceType: type, // loại đồng hồ
                user_id: user_id, // Lấy user_id từ req.body
                location: location, // Optional
                status: status || false, // Default là false
            });

            const waterDevice = await newDevice.save();
            
            return res.status(200).json(waterDevice);
        } catch(e) {
            console.log(e);
            return res.status(500).json({msg: "Error from Server"});
        }
    } 

    updateDevice = async(req, res) => {
        try {
            const deviceId = req.params.id;
            console.log(deviceId);
            const {type, location, status} = req.body;
           
            const device =  await WaterMeter.findById(deviceId);
            if(!device) {
                return res.status(400).json({msg: "Device not exit"});
            }

            //update information
            device.deviceType = type || device.deviceType;
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
}


module.exports = new WaterController;