

// import { GoogleMap, LoadScript, Marker } from "@react-google-maps/api";
import { useState, useEffect } from "react";
import {APIProvider, Map, Marker, InfoWindow } from '@vis.gl/react-google-maps';

const mapContainerStyle = {
  width: "80%",
  height: "400px"
};
  
const center = { lat: 10.762622, lng: 106.660172 };

function HomePage() {
  const [devices, setDevices] = useState([]);
  const HCM = {
    lat: 20.827215, // Latitude
    lng: 106.718903, // Longitude
  }
  useEffect(() => {
    const ws = new WebSocket("ws://localhost:4000");

    ws.onmessage = (event) => {
      const device = JSON.parse(event.data);
      setDevices((prevDevices) => [...prevDevices, device]);
    };

    return () => ws.close();
  }, []);
  
 return (
  <div class="body">
    <div className="header-body">
      <div className="container px-18 py-8 bg-gray-100">
          <div className="grid lg:grid-cols-4 md:grid-cols-2 gap-10 mx-8">
            
            {/* Thiết bị */}
            <div className="bg-blue-500 text-white rounded-xl p-4 shadow-md text-center">
              <i className="fa fa-cogs text-4xl mb-4"></i> {/* Icon thiết bị */}
              <h3 className="text-lg">Thiết bị</h3>
              <h3 className="text-2xl font-bold mt-2">3</h3>
            </div>

            {/* Hoạt động */}
            <div className="bg-green-500 text-white rounded-xl p-6 shadow-md text-center">
              <i className="fa fa-play-circle text-4xl mb-4"></i> {/* Icon hoạt động */}
              <h3 className="text-lg">Hoạt động</h3>
              <h3 className="text-2xl font-bold mt-2">2</h3>
            </div>

            {/* Cảnh báo */}
            <div className="bg-yellow-500 text-white rounded-xl p-6 shadow-md text-center">
              <i className="fa fa-bell text-4xl mb-4"></i> {/* Icon cảnh báo */}
              <h3 className="text-lg">Cảnh báo</h3>
              <h3 className="text-2xl font-bold mt-2">0</h3>
            </div>

            {/* Hệ thống */}
            <div className="bg-red-500 text-white rounded-xl p-6 shadow-md text-center">
              <i className="fa fa-server text-4xl mb-4"></i> {/* Icon hệ thống */}
              <h3 className="text-lg">Hệ thống</h3>
              <h3 className="text-2xl font-bold mt-2">5</h3>
            </div>
          </div>
      </div>
    </div>
    <div class="map py-4 mx-8">
      <div class="heading-map mb-4">
        <h3 className="font-bold">Bieu do</h3>
      </div>
      <div className="googlemap flex flex-row">
      <APIProvider apiKey={process.env.REACT_APP_GOOGLE_MAP_API_KEY}>
        <Map
          style={{width: '70%', height: '350px'}}
          defaultCenter={{lat: 22.54992, lng: 0}}
          defaultZoom={3}
          gestureHandling={'greedy'}
          disableDefaultUI={true}
        />
        <Marker 
          key={1}
          position={{lat: HCM.lat, lng: HCM.lng}}
          icon={{
            url: "http://maps.google.com/mapfiles/ms/icons/red-dot.png", // Cờ đỏ
            scale: 1.5, // Tùy chỉnh kích thước
          }}
        /> 
        <InfoWindow 
        position={{lat: HCM.lat, lng: HCM.lng}}>
          <div>
              <h3 className="text-sm font-bold">Quoc vux</h3>
                <p>Lat: {HCM.lat}</p>
                <p>Lng: {HCM.lng}</p>
          </div>
        </InfoWindow>
      </APIProvider>
      </div>
      <div class="information">
        <h3>Bên này hiện thị thông tin</h3>
      </div>
    </div>
    <div class="history">
      <h3>Xem lịch sử cảnh báo của các thiết bị ở dưới này</h3>
      <h3>Xem lịch sử cảnh báo của các thiết bị ở dưới này</h3>
      <h3>Xem lịch sử cảnh báo của các thiết bị ở dưới này</h3>
      <h3>Xem lịch sử cảnh báo của các thiết bị ở dưới này</h3>
      <h3>Xem lịch sử cảnh báo của các thiết bị ở dưới này</h3>
      <h3>Xem lịch sử cảnh báo của các thiết bị ở dưới này</h3>
      <h3>Xem lịch sử cảnh báo của các thiết bị ở dưới này</h3>
    </div>
  </div>
 );
}
  
export default HomePage;