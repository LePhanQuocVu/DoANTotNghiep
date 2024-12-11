var express = require('express');
var authRouter = require('./routes/auth');
const bodyParser = require('body-parser');
const cors = require('cors');
const db = require('./config/db');
const mqtt = require('mqtt');
const http = require('http');

// Create an express app
var app = express();

// Create an HTTP server
const { Server } = require("socket.io");
const { createServer } = require('node:http');
const server = createServer(app);  // Đảm bảo server được tạo sau khi app
// Socket IO
const io = new Server(server);

// Đảm bảo kết nối socket.io đúng
io.on('connection', (socket) => {
  console.log('a user connected');
});
//
// MQTT Broker configuration
const mqttInfor = {
  host: '89ffa4ed74ef4736ba72d21bf3de00ab.s1.eu.hivemq.cloud',
  port: 8883,
  protocol: 'mqtts',
  username: 'test1',
  password: 'Test12345',
};
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

// Connect to DB (Make sure db.connectDB() is correctly implemented)
db.connectDB();

// Use CORS middleware
app.use(cors());

// Middleware setup
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(express.json());

// Setup routes
app.use('/', authRouter);
app.use('/', (req, res) => {
  res.send('<h1>Test Socket.IO server</h1>');
});

// Start the server
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`App listening at http://localhost:${PORT}`);
});
