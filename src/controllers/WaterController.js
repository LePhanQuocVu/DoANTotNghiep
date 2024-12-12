
const { json } = require('express');
const Water = require('../models/WaterDataModel');

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
    updateDevice = async(req, res) => {
        try {
            const deviceId = req.params.id;

            const {location, status, timestamp} = req.body;
            
            let device = Water({
                location: location,
                status: status,
                timestamp: timestamp,
            })
            const deviceUpdate = await device.save();
            if(!deviceUpdate) {
                return res.status(400).json({msg: "Not update"});
            }
            return res.status(200).json(deviceUpdate);
        }
        catch (e){
            return res.status(500).json({msg: "Error"});
        }
    }
}


module.exports = new WaterController;