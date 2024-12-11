const mongoose = require('mongoose');

async function connectDB()  {
    try {
        await mongoose.connect('mongodb://localhost:27017/water_meter_db', {
          useNewUrlParser: true,
          useUnifiedTopology: true,
        });
        console.log('MongoDB connected successfully');
      } catch (error) {
        console.error('MongoDB connection error:', error);
        process.exit(1); // Dừng ứng dụng nếu kết nối thất bại
      }
}

module.exports = { connectDB };


