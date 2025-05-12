const { getMessaging } = require('firebase-admin/messaging');

async function sendNotification(fcmToken, title, body)  {
    const message = {
        notification: {
            title: title,
            body: body
        },
        token: fcmToken
    }
    getMessaging().send(message)
    .then((res) => {
        console.log('Gửi thông báo thành công:', res);
        return res;
    })
    .catch((error) => { 
        console.error('Gửi thông báo thất bại:', error);
        throw error;
    })
}
module.exports = {
    sendNotification,
};
