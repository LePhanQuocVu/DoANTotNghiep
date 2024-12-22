const mqtt = require('mqtt');


class MqttServer {
    
    constructor(host, port, protocol, username, password) {
        const mqttInfor = {
            host: host,
            port: port,
            protocol: protocol,
            username: username,
            password: password
        }
        const client = mqtt.connect(mqttInfor);
        
        client.on('connect', () => {
            console.log('Connected to MQTT broker');
            const topic = 'datawater';
            client.subscribe(topic, (err) => {
              if (err) {
                console.error(`Cannot subscribe to topic: ${err.message}`);
              } else {
                console.log(`Subscribed to topic: ${topic}`);
              }
            });
          });
        
        client.on('message', (topic, message) => {
        console.log(`Received message on topic ${topic}: ${message}`);
        io.emit('mqtt_data', { data: message.toString() }); // Send data to Flutter app
        });
        

        client.on('error', (error) => {
        console.error('MQTT connection failed', error);
        });
        
        client.on('reconnect', () => {
        console.log('MQTT reconnecting...');
        });
        

    }

}
const HOST_NAME =  '89ffa4ed74ef4736ba72d21bf3de00ab.s1.eu.hivemq.cloud';
const PORT = 8883;
const PROTOCOL = 'mqtts';
const  USER_NAME = 'test1';
const PASSWORD = 'Test12345';


const mqttServer = new MqttServer(HOST_NAME,PORT, PROTOCOL, USER_NAME, PASSWORD);
module.exports = mqttServer;