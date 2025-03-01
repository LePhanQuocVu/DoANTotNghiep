import React from 'react'
import {BrowserRouter, Routes, Route } from 'react-router-dom'
import HomePage from '../pages/HomePage'
import UserManager from '../pages/UserManager/userManage'
import DevicePage from '../pages/DevicePage'
import ConfigPage from '../pages/ConfigPage' 
import ProductsPage from '../pages/ProductsPage'
import MainLayout from '../layout/mainLayout'
function AppRouter() {
  return (
    <BrowserRouter>
        <Routes>
            <Route path="/" element={<MainLayout />}>
            {/* Các route con nằm bên trong MainLayout */}
            <Route index element={<HomePage />} />  {/* index là trang mặc định */}
            <Route path="/products" element={<ProductsPage />} />
            <Route path="/users" element={<UserManager />} />
            <Route path="/devices" element={<DevicePage />} />
            <Route path="/config" element={<ConfigPage />} />
            </Route>
            </Routes>
    </BrowserRouter>
  )
}

export default AppRouter;