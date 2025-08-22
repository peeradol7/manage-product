# String Cleaning Implementation Guide

## Overview

ระบบได้ถูกอัปเดตให้สามารถทำความสะอาดข้อความโดยอัตโนมัติ โดยจะ**ตัดช่องว่าง (spaces) ทิ้ง**และ**เก็บเฉพาะตัวอักษร**เท่านั้น

## Features Implemented

### 🧹 String Cleaning Service

- **Location**: `Application/Services/StringCleaningService.cs`
- **Purpose**: ทำความสะอาดข้อความโดยลบช่องว่างและเก็บเฉพาะตัวอักษรไทยและอังกฤษ

### 🔍 Search Functionality

- **Where**: `SkuMasterService.GetPagedListAsync()`
- **Behavior**:
  - SearchTerm จะถูกทำความสะอาดก่อนการค้นหา
  - ลบช่องว่างออกทั้งหมด
  - เก็บเฉพาะตัวอักษรไทย (Unicode: 0E00-0E7F) และอังกฤษ (A-Z, a-z)

### ✏️ Update Operations

- **Basic Update**: `SkuMasterService.UpdateBasicInfoAsync()`
- **Image Update**: `SkuMasterImageController.UpdateSkuMaster()`
- **Behavior**: SkuName จะถูกทำความสะอาดก่อนบันทึกลงฐานข้อมูล

## Supported Characters

### ✅ Allowed Characters

- **English Letters**: A-Z, a-z
- **Thai Characters**: ก-ฮ, ะ-๙ (Unicode range: 0E00-0E7F)

### ❌ Removed Characters

- **Spaces**: ` ` (all spaces removed)
- **Numbers**: 0-9
- **Special Characters**: !@#$%^&\*()\_+-=[]{}|;:'"<>,.?/
- **Other Unicode characters** (except Thai)

## API Behavior Examples

### Search Examples

```
Input:  "Product สินค้า 123!@#"
Output: "Productสินค้า"

Input:  "Test   Product"
Output: "TestProduct"

Input:  "   ก ข ค   "
Output: "กขค"
```

### Update Examples

```json
// Request
{
  "skuName": "Mixed Product สินค้า Test 123!@#",
  "skuPrice": 100
}

// Saved to database
{
  "skuName": "MixedProductสินค้าTest",
  "skuPrice": 100
}
```

## Mobile App Integration

### 📱 Client-Side Cleaning

- **Location**: `mobile/lib/services/string_cleaning_service.dart`
- **Purpose**: Preview และ validation ฝั่ง client
- **Note**: การทำความสะอาดหลักจะทำที่ API server

### 🔍 Search Integration

- **Location**: `mobile/lib/services/dio_service.dart`
- **Behavior**: SearchTerm จะถูกทำความสะอาดก่อนส่งไป API

## Testing

### 🧪 Test Cases

File: `TestStringCleaning.http`

1. **Search with spaces and special characters**
2. **Search with Thai text and spaces**
3. **Mixed Thai/English search**
4. **Update with spaces and special characters**
5. **Update with Thai text and spaces**
6. **Form data update with spaces**
7. **Empty and whitespace-only strings**
8. **Strings with only special characters**

### 🚀 How to Test

1. Start the API server
2. Open `TestStringCleaning.http` in VS Code with REST Client extension
3. Run each test case
4. Verify the behavior matches expected results

## Edge Cases Handled

### Empty/Null Strings

- `null` → `""`
- `""` → `""`
- `"   "` → `""`

### Only Special Characters

- `"123!@#"` → `""` (falls back to original if cleaned result is empty)
- `"!@#$%"` → `""` (falls back to original if cleaned result is empty)

### Fallback Behavior

- If cleaned string is empty but original is not empty → use original string
- This prevents data loss for edge cases

## Configuration

### Service Registration

```csharp
// Program.cs
builder.Services.AddScoped<IStringCleaningService, StringCleaningService>();
```

### Dependency Injection

```csharp
// Controllers and Services
public SkuMasterService(
    TFHDbContext context,
    IUrlHelperService urlHelperService,
    IStringCleaningService stringCleaningService)
```

## Benefits

1. **Consistent Data**: ข้อมูลในฐานข้อมูลจะมีรูปแบบที่สม่ำเสมอ
2. **Better Search**: การค้นหาจะแม่นยำมากขึ้นเมื่อไม่มีช่องว่างรบกวน
3. **Data Quality**: ลดปัญหาข้อมูลที่มีช่องว่างไม่จำเป็น
4. **Unicode Support**: รองรับภาษาไทยและอังกฤษอย่างเต็มรูปแบบ

## Notes

- การทำความสะอาดจะทำที่ API server เป็นหลัก
- Mobile app มี string cleaning service สำหรับ preview และ validation
- ระบบจะ fallback ไปใช้ข้อความเดิมหากผลลัพธ์ที่ทำความสะอาดแล้วเป็นค่าว่าง
- การเปลี่ยนแปลงนี้ไม่ส่งผลกระทบต่อข้อมูลเดิมในฐานข้อมูล

