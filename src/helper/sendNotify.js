const { getMessaging } = require('firebase-admin/messaging');
const admin = require('../config/firebase');
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

async function sendNotificationToTopic(topic,title,body){
    const message = {
        notification: {
            title: title,
            body: body
        },
        topic: topic
    };

    try {
        const response = await admin.messaging().send(message);
          console.log("Successfully sent message:", response);
    }catch(e) {
            console.error("Error sending message:", error);
    }


}
module.exports = {
    sendNotification,
    sendNotificationToTopic,
};
