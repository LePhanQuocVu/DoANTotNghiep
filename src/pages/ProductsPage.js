import React, { useState } from "react";

function ProductsPage() {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedImage, setSelectedImage] = useState(null);


  const openModal = () => {
    setIsModalOpen(true);
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setSelectedImage(null); // Xóa hình ảnh đã chọn khi đóng modal
  };

  const handleImageChange = (event) => {
    const file = event.target.files[0];
    if (file) {
      setSelectedImage(URL.createObjectURL(file)); // Tạo URL tạm thời để hiển thị hình ảnh
    }
  };


  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">Quản lý danh sách sản phẩm</h1>
      <div className="mb-4">
        <button
          onClick={openModal}
          className="bg-blue-500 text-white px-4 py-2 rounded shadow hover:bg-blue-600"
        >
          Tạo mới
        </button>
      </div>

      {/* Bảng danh sách sản phẩm */}
      <div className="overflow-x-auto">
        <table className="min-w-full bg-white border border-gray-200 rounded-lg shadow-md">
          <thead className="bg-gray-100">
            <tr>
              <th className="px-4 py-2 border">Id</th>
              <th className="px-4 py-2 border">Tên sản phẩm</th>
              <th className="px-4 py-2 border">Loại sản phẩm</th>
              <th className="px-4 py-2 border">Image</th>
              <th className="px-4 py-2 border">Thao tác</th>
            
            </tr>
          </thead>
          <tbody>
            <tr>
              <td className="px-4 py-2 border">1</td>
              <td className="px-4 py-2 border">Sản phẩm A</td>
              <td className="px-4 py-2 border">Loại A</td>
              <td className="px-4 py-2 border">
                <img
                  src="https://via.placeholder.com/50"
                  alt="Product"
                  className="w-12 h-12 object-cover"
                />
              </td>
              <td className="px-4 py-2 border">
                <button className="bg-green-500 text-white px-3 py-1 rounded hover:bg-green-600 btn-display mx-5">
                  Xem
                </button>
                <button className="bg-red-500 text-white px-3 py-1 rounded hover:bg-red-600 btn-delete">
                  Xóa
                </button>
              </td>
            </tr>
            {/* Thêm các sản phẩm khác ở đây */}
          </tbody>
        </table>
      </div>

      {/* Modal Tạo sản phẩm */}
      {isModalOpen && (
        <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50">
          <div className="bg-white w-1/2 p-6 rounded-lg shadow-lg">
            <h2 className="text-xl font-bold mb-4">Tạo sản phẩm mới</h2>
            <form>
              <div className="mb-4">
                <label className="block text-gray-700 font-medium mb-2">
                  Tên sản phẩm
                </label>
                <input
                  type="text"
                  className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-400"
                  placeholder="Nhập tên sản phẩm"
                />
              </div>
              <div className="mb-4">
                <label className="block text-gray-700 font-medium mb-2">
                  Giá
                </label>
                <input
                  type="text"
                  className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-400"
                  placeholder="Giá"
                />
              </div>
              <div className="mb-4">
                <label className="block text-gray-700 font-medium mb-2">
                  Danh mục
                </label>
                <input
                  type="text"
                  className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-400"
                  placeholder="Nhập loại sản phẩm"
                />
              </div>
               <div className="mb-4">
                <label className="block text-gray-700 font-medium mb-2">
                  Hình ảnh
                </label>
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleImageChange}
                  className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-400"
                />
                {selectedImage && (
                  <img
                    src={selectedImage}
                    alt="Preview"
                    className="w-24 h-24 mt-2 object-cover rounded-lg"
                  />
                )}
              </div>
              <div className="flex justify-end">
                <button
                  type="button"
                  onClick={closeModal}
                  className="mr-2 bg-gray-400 text-white px-4 py-2 rounded hover:bg-gray-500"
                >
                  Hủy
                </button>
                <button
                  type="submit"
                  className="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"
                >
                  Lưu
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}

export default ProductsPage;