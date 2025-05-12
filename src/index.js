const express = require('express');
const http = require('http');
const accessToken = '6mT5gue0VvOMQv6B1biX'; // Thay bằng token của thiết bị thật

const authRouter = require('./routes/auth');
const userRouter = require('./routes/user');
const waterRouter = require('./routes/water');
const adminRouter = require('./routes/admin');
const admin = require('./config/firebase');

const { Server } = require("socket.io");
const { createServer } = require('http');

const bodyParser = require('body-parser');
const cors = require('cors');
const db = require('./config/db');
 const mqttController = require('./controllers/MqttController');
const { getMessaging } = require('firebase-admin/messaging');

// Tạo ứng dụng Express
const app = express();
const server = createServer(app); // Tạo HTTP server
const io = new Server(server);   // Tạo Socket.IO server

const data = JSON.stringify({
  tempesrature: 25
});

// const options = {
//   hostname: 'app.coreiot.io',
//   port: 80,
//   path: `/api/v1/${accessToken}/telemetry`,
//   method: 'POST',
//   headers: {
//     'Content-Type': 'application/json',
//     'Content-Length': data.length
//   }
// };



// Kết nối database
db.connectDB();

// Middleware
app.use(cors());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(express.json());

// Thiết lập các route cho User
// app.use('/', authRouter);
app.use('/user', userRouter);
app.use('/water', waterRouter);

// // Thiết lập các route cho Admin
app.use('/admin',adminRouter);

// Test route cho socket.io
app.use('/', (req, res) => {
  res.send('<h1>Test Socket.IO server</h1>');
});


//Truyền `io` vào `mqttController`
mqttController.initialize(io);

// Socket.IO event handler//
io.on('connection', (socket) => {
  console.log('A user connected');
  socket.on('mode_selected', (mode) => {
    console.log(`Received mode from Flutter: ${mode}`);
    const topic = 'command';
    mqttController.publishToMQTT(topic, mode);
  });
  socket.on('ota_update_requested', (data) => {
    const { userId, message} = data;
    const topic = `${userId}/ota`; 
    console.log(`OTA update requested -> Topic: ${topic}, Message: ${message}`);

    mqttController.publishToMQTT(topic, message);
  });
});

// Khởi động server
const PORT = process.env.PORT || 3000;
server.listen(PORT,() => {
  console.log(`App listening at http://localhost:${PORT}`);
});
