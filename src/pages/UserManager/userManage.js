import * as React from 'react';
import {useState, useEffect} from 'react'
import axios from 'axios'

function UserManager() {
    const [users, setUser] = useState([]);
    const [selectedUsers, setSelectedUsers] = useState([]);

    const fetchUser =  () => {
        axios.get(`http://localhost:3000/api/users`)
        .then(data => {
            console.log(typeof data);
            const usersWithIndex = data.data.map((user, index) => ({ ...user, id: index + 1 }));
            setUser(usersWithIndex);
        })
        
    }
    const handleSelectAll = (event) => {
      if (event.target.checked) {
        const allUserIds = users.map(user => user.id);
        setSelectedUsers(allUserIds);
      } else {
        setSelectedUsers([]);
      }
    };
    
  
    const handleSelectUser = (userId) => {
      if (selectedUsers.includes(userId)) {
        setSelectedUsers(selectedUsers.filter(id => id !== userId));
      } else {
        setSelectedUsers([...selectedUsers, userId]);
      }
    };

    const formatDate = (dateTimeString) => {
      const date = new Date(dateTimeString);
      const day = date.getDate().toString().padStart(2, '0');
      const month = (date.getMonth() + 1).toString().padStart(2, '0');
      const year = date.getFullYear();
    
      return `${day}/${month}/${year}`;
    };
  
    const handleDeleteSelected = () => {
      // Thực hiện xóa người dùng đã chọn
      // axios.post('/api/delete-users', { ids: selectedUsers })
      //   .then(() => {
      //     setUsers(users.filter(user => !selectedUsers.includes(user.id)));
      //     setSelectedUsers([]);
      //   })
      //   .catch(error => console.error('Error deleting users:', error));
    };
    useEffect(() => {
       fetchUser();
    }, [])

  return (
     <div className="container mx-auto p-4">
      <div className="overflow-x-auto">
        <h3 className='text-lg font-bold py-4'>Danh sách người dùng</h3>
        <table className="min-w-full bg-white border border-gray-300">
          <thead>
            <tr className="bg-gray-200">
              <th className="p-2 border-r">
                <input
                  type="checkbox"
                  onChange={handleSelectAll}
                  checked={selectedUsers.length === users.length}
                />
              </th>
              <th className="p-2 border-r">ID</th>
              <th className="p-2 border-r">Name</th>
              <th className="p-2 border-r">Email</th>
              <th className="p-2 border-r">SDT</th>
              <th className="p-2 border-r">Created_at</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200">
            {users.map(user => (
              <tr
                key={user.id}
                className={`hover:bg-gray-100 ${selectedUsers.includes(user.id) ? 'bg-gray-100' : ''}`}
              >
                <td className="p-2 border-r text-center">
                  <input
                    type="checkbox"
                    checked={selectedUsers.includes(user.id)}
                    onChange={() => handleSelectUser(user.id)}
                  />
                </td>
                <td className="p-2 border-r text-center">{user.id}</td>
                <td className="p-2 border-r">{user.name}</td>
                <td className="p-2 border-r">{user.email}</td>
                <td className="p-2 border-r">{ user.phone ? user.pphone : "Chưa cập nhật"}</td>
                <td className="p-2 border-r">{formatDate(user.create_at)}</td>
               
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      {selectedUsers.length > 0 && (
        <div className="mt-4">
          <button
            onClick={handleDeleteSelected}
            className="bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600"
          >
            Xóa người dùng đã chọn
          </button>
        </div>
      )}
    </div>
  );
}

export default UserManager;