const mqtt = require('mqtt');
const WaterMeter = require('../models/WaterMeterModel');
const https = require('https');
const jwt = require('jsonwebtoken');
const { json } = require('stream/consumers');
class MqttController {
  constructor(host, port, protocol, username, password) {
    const mqttInfo = {
      host: host,
      port: port,
      protocol: protocol,
      username: username,
      password: password,
    };
    // this.accessToken = 'ja1a4dwxgwhwi4oj93mm';
    this.client = mqtt.connect(mqttInfo);
    this.io = null; // Để giữ tham chiếu đến io
    this.setupListeners();
  }
  
 

  // Hàm khởi tạo để truyền io từ index.js
  initialize(io) {
    this.io = io;
  }

  setupListeners() {
    this.client.on('connect', () => {
      console.log('Connected to MQTT broker');
      const topic = 'data/+';
      this.client.subscribe(topic, (err) => {
        if (err) {
          console.error(`Cannot subscribe to topic: ${err.message}`);
        } else {
          console.log(`Subscribed to topic: ${topic}`);
        }
      });
    });
    //
    this.client.on('message', async (topic, message) => {
      console.log(`topic: ${topic}`);
      const topicPicker = topic.split('/');
      if(topicPicker.length !== 2) {
        return;
      }
    // connect to CoreIOT
      
      const userId = topicPicker[1];

      console.log(`Received message for user: ${userId} : ${message}`);
        // Gửi dữ liệu qua socket.io (nếu io đã được khởi tạo) -> flutter
      
       
        // send to coreIOT TODO:

        // Lưu dữ liệu vào cơ sở dữ liệu
        try {
          const payload = JSON.parse(message.toString());
          const { flowRate, volume, total_monthly } = payload;
           // Emit flowRate via socket.io
          if (this.io && typeof flowRate === 'number') {
            this.io.emit(`mqtt_data/${userId}`, { flowRate });
            console.log(`Đã gửi tới Web Socket!: mqtt_data/${userId}`);
          }
          // const flowRate = JSON.parse(message.toString());
        // save to database
          const device = await WaterMeter.findOne({ user_id: userId });
          console.log(`Move to device: ${device}`);
          const deviceJson = (device);
          var token = device['iotToken'];
          console.log(`Token: ${token}`); //  sẽ ra lại 'ja1a4dwxgwhwi4oj93m
          if (!device) {
            console.error(`No device found for user_id: ${userId}.`);
            return;
          }
          if (typeof volume === 'number' && !isNaN(volume)) {
            device.data.push({ value: volume, timestamp: new Date() });
            this.sendDataToCoreIOT({flowRate: flowRate}, token);
            await device.save();
            console.log(` Data saved for user_id: ${userId}, value: ${flowRate}`);
          } else {
            console.error(`Invalid volume received: ${volume}`);
              return;
          }
          // console.log(`Device found: ${device}`);
          // device.data.push({ value: parseFloat(flowRate) });
          // await device.save();
          // console.log(`Data saved for user_id: ${userId}, value: ${flowRate}`);
        } catch (e) {
          console.error('Failed to add data to waterData:', e);
        }
      //}
    });

    this.client.on('error', (error) => {
      console.error('MQTT connection failed', error);
    });

    this.client.on('reconnect', () => {
      console.log('MQTT reconnecting...');
    });
  }
  

  //  Hàm gửi dữ liệu đến CoreIOT qua HTTPS
  sendDataToCoreIOT(dataObj, accessToken) {
    const data = JSON.stringify(dataObj);

    const options = {
      hostname: 'app.coreiot.io',
      port: 443,
      path: `/api/v1/${accessToken}/telemetry`,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(data)
      }
    };

    const req = https.request(options, res => {
      console.log('Connect to CoreIOT')
      console.log(`🌐 CoreIOT Response Status: ${res.statusCode}`);
      res.on('data', d => psrocess.stdout.write(d));
    });
   
    req.on('error', error => {
      console.error('❌ Lỗi gửi dữ liệu đến CoreIOT:', error);
    });

    req.write(data);
    req.end();
  }


  // Hàm để publish dữ liệu lên MQTT
  publishToMQTT(topic, message) {
    this.client.publish(topic, message, (error) => {
      if (error) {
        console.error('Failed to publish message to MQTT:', error);
      } else {
        console.log('Message published to MQTT:', message);
      }
    });
  }
}

const HOST_NAME = '89ffa4ed74ef4736ba72d21bf3de00ab.s1.eu.hivemq.cloud';
const PORT = 8883;
const PROTOCOL = 'mqtts';
const USER_NAME = 'testapp';
const PASSWORD = 'Test123456@';

const mqttController = new MqttController(HOST_NAME, PORT, PROTOCOL, USER_NAME, PASSWORD);
module.exports = mqttController;
