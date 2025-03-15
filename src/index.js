const express = require('express');

const authRouter = require('./routes/auth');
const userRouter = require('./routes/user');
const waterRouter = require('./routes/water');

const { Server } = require("socket.io");
const { createServer } = require('http');

const bodyParser = require('body-parser');
const cors = require('cors');
const db = require('./config/db');
const mqttController = require('./controllers/MqttController');

// Tạo ứng dụng Express
const app = express();
const server = createServer(app); // Tạo HTTP server
const io = new Server(server);   // Tạo Socket.IO server

// Kết nối database
db.connectDB();

// Middleware
app.use(cors());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(express.json());

// Thiết lập các route
app.use('/', authRouter);
app.use('/', userRouter);
app.use('/', waterRouter);

// Test route cho socket.io
app.use('/', (req, res) => {
  res.send('<h1>Test Socket.IO server</h1>');
});

// Truyền `io` vào `mqttController`
mqttController.initialize(io);

// Socket.IO event handler
io.on('connection', (socket) => {
  console.log('A user connected');
  socket.on('mode_selected', (mode) => {
    console.log(`Received mode from Flutter: ${mode}`);
    const topic = 'command';
    mqttController.publishToMQTT(topic, mode);
  });
});

// Khởi động server
const PORT = process.env.PORT || 3000;
server.listen(PORT,() => {
  console.log(`App listening at http://localhost:${PORT}`);
});
