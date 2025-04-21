const https = require('https');

class CoreIOTClient {
  constructor(accessToken) {
    this.accessToken = accessToken;
    this.hostname = 'app.coreiot.io';
    this.port = 80;
    this.isConnected = false;
  }

  async sendDataToCoreIOT(dataObj) {
    const data = JSON.stringify(dataObj);
//
    const options = {
      hostname: this.hostname,
      port: this.port,
      path: `/api/v1/${this.accessToken}/telemetry`,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(data),
      },
    };

    try {
      const req = https.request(options, (res) => {
        let responseData = '';
        res.on('data', (chunk) => {
          responseData += chunk;
        });
        res.on('end', () => {
            if (!this.isConnected) {
                this.isConnected = true;
                console.log('✅ Đã thiết lập kết nối với CoreIOT.');
            }
            if (res.statusCode == 200) {
                console.log('Dữ liệu đã được gửi thành công đến CoreIOT.');
            } else {
                console.error(`Lỗi từ CoreIOT: ${res.statusCode} - ${responseData}`);
            }
        });
      });

      req.on('error', (error) => {
        console.error('Lỗi khi gửi dữ liệu đến CoreIOT:', error.message);
      });

      req.write(data);
      req.end();
    } catch (error) {
      console.error('Lỗi đồng bộ khi gửi dữ liệu:', error.message);
    }
  }

  test() {
    print('Is testing');
  }
}

module.exports = CoreIOTClient;
