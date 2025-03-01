import React from 'react'
import { Link } from 'react-router-dom'
import { Dashboard } from '@mui/icons-material'
function Header() {
  return (
    <div className="header container ">
        <div className='flex items-center px-6  bg-gray-100  border-bottom h-[65px]'>
            <button className='p-2 bg-gray-200 rounded hover:bg-gray-300'>
                <i className='fa fa-bars' aria-hidden='true'></i>
            </button>
            <ul className='flex space-x-4 mx-4 ' >
                <li className='hover:text-blue-500 cursor-pointer'>
                    <Link
                    
                    >  Dashboard</Link>    
                  
                </li>
                <li className='hover:text-blue-500 cursor-pointer'>Users</li>
                <li className='hover:text-blue-500 cursor-pointer'>Setting</li>
            </ul>
           
            <ul className='flex items-center space-x-4  ms-auto' >
                <li><div className='border-l h-6 cursor-pointer'></div></li>
                <li><i className='fa fa-bell cursor-pointer' aria-hidden='true'></i></li>
                <li><i className='fa fa-bell cursor-pointer' aria-hidden='true'></i></li>
                <li><div className='border-l h-6 cursor-pointer'></div></li>
                <li>
                    <a href='#'>
                        <div className='avatar w-10 h-10 rounded-full overflow-hidden'>
                            <img className='w-full h-full object-cover' src='../assets/admin.jpg' alt='user@email.com' />
                        </div>
                    </a>
                </li>
            </ul>
        </div>
        <div className='min-h-[48px]'>
            <div className = "flex px-6 py-2">
                <h3 className='font-bold underline '>
                    <a href="">Home</a>
                </h3>
                <span>/</span>
                <span className='px-5'>Dashboard</span>
            </div>
        </div>
    </div>
  )
}

export default Header