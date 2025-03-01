import React from 'react'
import Sidebar from '../component/SideBar'
import Header from '../component/Header'
import { Outlet } from 'react-router-dom'
function MainLayout() {
  return (
    <div class="flex h-screen">
      <Sidebar />
      <div className="flex-1 flex flex-col">
        {/* Header */}
        <Header />
        <main className="flex-1  overflow-auto">
          <Outlet />
        </main>
      </div>
    </div>
  )
}

export default MainLayout;