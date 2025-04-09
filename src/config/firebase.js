const admin = require('firebase-admin');

const serviceAccount = require('../../water-notification-f6724-firebase-adminsdk-fbsvc-fe3e4fb64e.json'); // Đường dẫn đến file JSON của bạn

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

module.exports = admin;

