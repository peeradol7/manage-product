# Final API Guide - 3 Essential APIs

## 🎯 ระบบจัดการ SkuMaster แบบเรียบง่าย

### **API 1: Get List with Pagination**

```
GET /api/SkuMaster/list?page=1&pageSize=20
```

**Response:**

```json
{
  "data": [
    {
      "skuKey": 1,
      "skuCode": "SKU001",
      "skuName": "Product Name",
      "imageUrls": [
        "https://localhost:7071/images/skumasters/uuid1.jpg",
        "https://localhost:7071/images/skumasters/uuid2.png"
      ]
    }
  ],
  "currentPage": 1,
  "pageSize": 20,
  "totalCount": 100,
  "totalPages": 5,
  "hasPreviousPage": false,
  "hasNextPage": true
}
```

---

### **API 2: Get Detail**

```
GET /api/SkuMaster/{key}/detail
```

**Response:**

```json
{
  "skuKey": 1,
  "skuName": "Product Name",
  "imageUrls": [
    "https://localhost:7071/images/skumasters/uuid1.jpg",
    "https://localhost:7071/images/skumasters/uuid2.png"
  ],
  "width": 15.5,
  "length": 25.0,
  "height": 8.2,
  "weight": 3.1
}
```

---

### **API 3: Update Everything**

```
POST /api/SkuMasterImage/update
Content-Type: multipart/form-data
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `skuKey` | integer | Yes | SkuMaster Key ID |
| `skuName` | string | No | Product name |
| `newImages` | IFormFile[] | No | New images to upload |
| `deleteImageIds` | int[] | No | Image IDs to delete |
| `width` | decimal | No | Product width |
| `length` | decimal | No | Product length |
| `height` | decimal | No | Product height |
| `weight` | decimal | No | Product weight |

**Example Request:**

```bash
curl -X POST "https://localhost:7071/api/SkuMasterImage/update" \
  -F "skuKey=1" \
  -F "skuName=Updated Product Name" \
  -F "newImages=@image1.jpg" \
  -F "newImages=@image2.png" \
  -F "deleteImageIds=1" \
  -F "deleteImageIds=2" \
  -F "width=15.5" \
  -F "length=25.0" \
  -F "height=8.2" \
  -F "weight=3.1"
```

**Response:**

```json
{
  "success": true,
  "message": "SkuMaster updated successfully",
  "updatedSkuName": "Updated Product Name",
  "uploadedImages": [
    {
      "id": 5,
      "masterId": 1,
      "imageName": "/images/skumasters/uuid.jpg",
      "imagePath": "/images/skumasters/uuid.jpg",
      "createdDate": "2024-01-15T10:30:00"
    }
  ],
  "deletedImageIds": [1, 2],
  "updatedSizeDetail": {
    "id": 1,
    "masterId": 1,
    "width": 15.5,
    "length": 25.0,
    "height": 8.2,
    "weight": 3.1,
    "dateTimeUpdate": "2024-01-15T10:30:00"
  },
  "errors": [],
  "warnings": []
}
```

## 💡 Usage Examples

### **JavaScript/React**

```javascript
// 1. Get List
const getSkuMasterList = async (page = 1, pageSize = 20) => {
  const response = await fetch(
    `/api/SkuMaster/list?page=${page}&pageSize=${pageSize}`
  );
  return response.json();
};

// 2. Get Detail
const getSkuMasterDetail = async (id) => {
  const response = await fetch(`/api/SkuMaster/${id}/detail`);
  return response.json();
};

// 3. Update Everything
const updateSkuMaster = async (skuKey, data) => {
  const formData = new FormData();
  formData.append("skuKey", skuKey);

  if (data.skuName) formData.append("skuName", data.skuName);
  if (data.width) formData.append("width", data.width);
  if (data.length) formData.append("length", data.length);
  if (data.height) formData.append("height", data.height);
  if (data.weight) formData.append("weight", data.weight);

  // Add new images
  data.newImages?.forEach((file) => {
    formData.append("newImages", file);
  });

  // Add delete image IDs
  data.deleteImageIds?.forEach((id) => {
    formData.append("deleteImageIds", id);
  });

  const response = await fetch("/api/SkuMasterImage/update", {
    method: "POST",
    body: formData,
  });

  return response.json();
};
```

## 🎯 Key Features

### **📋 List API**

- ✅ Pagination support (default: page=1, pageSize=20)
- ✅ Returns SkuName and all image URLs
- ✅ Automatic URL generation based on host

### **🔍 Detail API**

- ✅ Complete product information
- ✅ SkuName, Image URLs, Size details (Width, Length, Height, Weight)
- ✅ Single size record per SkuMaster

### **🔄 Update API**

- ✅ Update product name
- ✅ Upload multiple new images
- ✅ Delete specific images by ID
- ✅ Update size dimensions
- ✅ Flexible - update any combination of fields
- ✅ All operations in single request

## 🛡️ Data Structure

### **Database Tables Used:**

- `SKUMASTER` - Main product table
- `SKUMASTERIMAGE` - Product images
- `SKUSIZEDETAIL` - Product dimensions

### **Size Management:**

- One size record per SkuMaster
- Automatic creation if doesn't exist
- Update existing if already exists
- DateTime auto-updated on changes

### **File Management:**

- UUID-based file naming
- Physical file deletion when removing from database
- Automatic directory creation
- Image validation (type, size)

## 📝 Best Practices

1. **Always include skuKey** in update requests
2. **Partial updates supported** - only send fields you want to change
3. **Handle errors gracefully** - check response.success
4. **Consider file sizes** when uploading images
5. **Use appropriate page sizes** for better performance
6. **Validate image formats** before upload

## 🚀 Simple & Efficient

This streamlined API design focuses on the three most essential operations:

- **Browse** products with pagination
- **View** complete product details
- **Modify** any aspect of a product in one call

Perfect for mobile apps, admin interfaces, and any system that needs straightforward product management.

