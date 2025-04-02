const mqtt = require('mqtt');
const WaterMeter = require('../models/WaterMeterModel');

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
      const userId = topicPicker[1];

      console.log(`Received message for user: ${userId} : ${message.toString()}`);
        // Gửi dữ liệu qua socket.io (nếu io đã được khởi tạo)
        if (this.io) {
          this.io.emit(`mqtt_data/${userId}`, { data: message.toString() });
          console.log(`Đã gửi tới Web Socket!: mqtt_data/${userId}`);
        }
        // Lưu dữ liệu vào cơ sở dữ liệu
        try {
          const flowRate = JSON.parse(message.toString());
          // if (isNaN(flowRate)) {
          //   console.error(`Invalid data received: ${message.toString()}`);
          //   return;
          // }

          const device = await WaterMeter.findOne({ user_id: userId });
          if (!device) {
            console.error(`No device found for user_id: ${userId}.`);
            return;
          }
          if (typeof flowRate === 'number' && !isNaN(flowRate)) {
            device.data.push({ value: flowRate, timestamp: new Date() });
            await device.save();
            console.log(`✅ Data saved for user_id: ${userId}, value: ${flowRate}`);
          } else {
              console.error(`❌ Invalid data received: ${message.toString()}`);
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
