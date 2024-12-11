
const { json } = require('express');
const Water = require('../models/WaterMeterModel');

class WaterController {
    // GET DATA
    getData = async (req, res) => {
        try{
            console.log("Fetching data from watermeter...");
            const waterData = await Water.find();
            console.log("Retrieved data:", waterData);
            // const water = await Water.find();
            // console.log(water);
            return res.status(200).json(waterData);
        }catch(err){
            return res.status(500).json(err);
        }
    }
    // index = async (req, res)=>{
    //     return res.send("get water");
    // }
}


module.exports = new WaterController;