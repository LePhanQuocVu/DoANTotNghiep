import { NavLink } from "react-router-dom";

function Sidebar() {
    const linkClass = "flex items-center space-x-3 py-2.5 px-4 rounded-lg text-white hover:bg-gray-600 transition";
    const activeClass = "bg-gray-500"; // Màu nền khi active

    return (
        <div className="w-64 bg-gray-700 text-white h-full flex flex-col p-4">
            <h3 className="text-2xl font-bold mb-6">Trang quản lý</h3>
            
            <div className="flex flex-col space-y-2">
                <h3 className="font-semibold">Thông tin chung</h3>
                <NavLink
                    to="/"
                    className={({ isActive }) =>
                        `${linkClass} ${isActive ? activeClass : ""}`
                    }
                >
                    <i className="fa fa-tachometer-alt"></i> 
                    <span>DashBoard</span>
                </NavLink>

                <h3 className="font-semibold">Quản lý</h3>
                <NavLink
                    to="/products"
                    className={({ isActive }) =>
                        `${linkClass} ${isActive ? activeClass : ""}`
                    }
                >
                    <i className="fa fa-box"></i>
                    <span>Thiết bị</span>
                </NavLink>
                
                <NavLink
                    to="/users"
                    className={({ isActive }) =>
                        `${linkClass} ${isActive ? activeClass : ""}`
                    }
                >
                    <i className="fa fa-users"></i>
                    <span>Người dùng</span>
                </NavLink>

                <h3 className="font-semibold">Cập nhật phần cứng</h3>
                <NavLink
                    to="/settings"
                    className={({ isActive }) =>
                        `${linkClass} ${isActive ? activeClass : ""}`
                    }
                >
                    <i className="fa fa-tools"></i>
                    <span>Update Firmware</span>
                </NavLink>

                <NavLink
                    to="/config"
                    className={({ isActive }) =>
                        `${linkClass} ${isActive ? activeClass : ""}`
                    }
                >
                    <i className="fa fa-network-wired"></i>
                    <span>Cấu hình IP</span>
                </NavLink>
            </div>
        </div>
    );
}

export default Sidebar;
