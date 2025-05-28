const mqtt = require('mqtt');
const WaterMeter = require('../models/WaterMeterModel');
const User = require('../models/UserModel');
const https = require('https');
const mongoose = require('mongoose');
const jwt = require('jsonwebtoken');
const { json } = require('stream/consumers');
const { sendNotification } = require('../helper/sendNotify');
class MqttController {
  constructor(host, port, protocol, username, password) {
    const mqttInfo = {
      host: host,
      port: port,
      protocol: protocol,
      username: username,
      password: password,
    };
    this.client = mqtt.connect(mqttInfo);
    this.io = null; // Để giữ tham chiếu đến io
    this.setupListeners();
    this.userToken = null;
  }
  // Hàm khởi tạo để truyền io từ index.js
  initialize(io) {
    this.io = io;
  }

  setupListeners() {
    this.client.on('connect', () => {
      console.log('Connected to MQTT broker');
      const topic = 'datawater/+';
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
      const userObjectId = new mongoose.Types.ObjectId(userId);
      console.log(`Received message for user: ${userId} : ${message}`);
        // Gửi dữ liệu qua socket.io (nếu io đã được khởi tạo) -> flutter
        // Lưu dữ liệu vào cơ sở dữ liệu
        try {
          const payload = JSON.parse(message.toString());
          const { flowRate, volume, total_monthly } = payload;
           // Emit flowRate via socket.io
          if (this.io && typeof flowRate === 'number') {
            this.io.emit(`mqtt_data/${userId}`, { flowRate });
            console.log(`Đã gửi tới Web Socket!: mqtt_data/${userId}`);
          }
        // get fcmUer to puh notify
        const user = await User.findById(userObjectId);
        this.userToken = user['fcmToken'];
        console.log(`User: ${user}`);
        // save to database
          const device = await WaterMeter.findOne({ user_id: userId });
          const deviceJson = (device);
          console.log(`Device to puh: ${deviceJson}`);
          var token = device['iotToken'];
          console.log(`Token: ${token}`); // -> trả về token của userID
          if (!device) {
            res.status(400).json({msg: "Người dùng chưa lắp đặt thiết bị!"});
            console.error(`No device found for user_id: ${userId}.`);
            return;
          }
          if (typeof volume === 'number' && !isNaN(volume)) {
            device.data.push({ value: volume, timestamp: new Date() });
            this.sendDataToCoreIOT({flowRate: flowRate, volume: volume, total_monthly: total_monthly}, token);
            await device.save(); // save data to mongoDB
            console.log(` Data saved for user_id: ${userId}, value: ${flowRate}`);
          } else {
            console.error(`Invalid volume received: ${volume}`);
              return;
          }
        } catch (e) {
          console.error('Failed to add data to waterData:', e);
        }
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
      console.log('Connect to CoreIOT');

      if(res.statusCode == 200) {
        console.log(`CoreIOT Response Status: ${res.statusCode}`);
        res.on('data', d => process.stdout.write(d));
      } else if(res.statusCode == 401) {
        // sendNotification(); -> connect fail to core IOT
        sendNotification(this.userToken, "Cảnh báo", "Kết nối CoreIOT thất bại, cập nhật AccessTOken");
        console.log('Fail to Connect on CoreIOT');
      }
    });
   
    req.on('error', error => {
      console.error('Lỗi gửi dữ liệu đến CoreIOT:', error);
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
