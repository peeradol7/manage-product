# Database Connection Fix

## Problem

```
fail: Microsoft.EntityFrameworkCore.Database.Connection[20004]
      An error occurred using the connection to database 'TFH' on server 'localhost,1433'.
fail: Microsoft.EntityFrameworkCore.Query[10100]
      Microsoft.Data.SqlClient.SqlException (0x80131904): A network-related or instance-specific error occurred while establishing a connection to SQL Server. The server was not found or was not accessible.
```

## Root Cause

1. **SQL Server ไม่ได้เปิดใช้งาน** หรือ **ไม่สามารถเชื่อมต่อได้**
2. **Connection String ไม่ถูกต้อง** สำหรับ development environment
3. **Network connectivity** ไปยัง database server

## Solution

### 1. Check SQL Server Status

#### Windows

```cmd
# Check if SQL Server is running
net start | findstr "SQL Server"

# Start SQL Server if not running
net start "SQL Server (MSSQLSERVER)"
```

#### SQL Server Management Studio (SSMS)

1. เปิด SSMS
2. เชื่อมต่อกับ `localhost` หรือ `192.168.1.20`
3. ตรวจสอบว่า database `TFH` มีอยู่

### 2. Update Connection String

#### appsettings.json (Production)

```json
{
  "ConnectionStrings": {
    "TFHDatabase": "Server=192.168.1.20,1433;Database=TFH;User Id=business;Password=Sy$temB+;TrustServerCertificate=true;"
  }
}
```

#### appsettings.Development.json (Development)

```json
{
  "ConnectionStrings": {
    "TFHDatabase": "Server=localhost,1433;Database=TFH;User Id=sa;Password=YourPassword;TrustServerCertificate=true;"
  }
}
```

### 3. Program.cs Changes

**เดิม (มีปัญหา):**

```csharp
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<TFHDbContext>();
    try
    {
        context.Database.EnsureCreated();
        Console.WriteLine("Database ensured/created successfully");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Database creation error: {ex.Message}");
    }
}
```

**ใหม่ (แก้ไขแล้ว):**

```csharp
// Test database connection
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<TFHDbContext>();
    try
    {
        // Test connection first
        var canConnect = await context.Database.CanConnectAsync();
        if (canConnect)
        {
            Console.WriteLine("Database connection successful");
            context.Database.EnsureCreated();
            Console.WriteLine("Database ensured/created successfully");
        }
        else
        {
            Console.WriteLine("Cannot connect to database");
        }
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Database connection error: {ex.Message}");
        Console.WriteLine("Please check:");
        Console.WriteLine("1. SQL Server is running");
        Console.WriteLine("2. Connection string is correct");
        Console.WriteLine("3. Network connectivity to database server");
    }
}
```

## Troubleshooting Steps

### Step 1: Check SQL Server Service

```cmd
# Windows
services.msc
# Look for "SQL Server (MSSQLSERVER)" and ensure it's running
```

### Step 2: Test Connection with SQL Server Management Studio

1. เปิด SSMS
2. Server name: `localhost,1433` หรือ `192.168.1.20,1433`
3. Authentication: SQL Server Authentication
4. Login: `sa` หรือ `business`
5. Password: ตามที่ตั้งไว้

### Step 3: Check Firewall

```cmd
# Windows Firewall
# Allow SQL Server through firewall
netsh advfirewall firewall add rule name="SQL Server" dir=in action=allow protocol=TCP localport=1433
```

### Step 4: Check SQL Server Configuration

1. เปิด SQL Server Configuration Manager
2. SQL Server Network Configuration
3. Protocols for MSSQLSERVER
4. Enable TCP/IP
5. Restart SQL Server service

### Step 5: Alternative Connection Strings

#### Local SQL Server

```json
"Server=localhost,1433;Database=TFH;User Id=sa;Password=YourPassword;TrustServerCertificate=true;"
```

#### SQL Server Express

```json
"Server=localhost\\SQLEXPRESS,1433;Database=TFH;User Id=sa;Password=YourPassword;TrustServerCertificate=true;"
```

#### Windows Authentication

```json
"Server=localhost,1433;Database=TFH;Integrated Security=true;TrustServerCertificate=true;"
```

## Quick Fixes

### Option 1: Use Local SQL Server

1. ติดตั้ง SQL Server Express
2. เปลี่ยน connection string เป็น localhost
3. สร้าง database `TFH`

### Option 2: Use SQLite for Development

```csharp
// In Program.cs
builder.Services.AddDbContext<TFHDbContext>(options =>
    options.UseSqlite("Data Source=TFH.db"));
```

### Option 3: Use In-Memory Database

```csharp
// In Program.cs
builder.Services.AddDbContext<TFHDbContext>(options =>
    options.UseInMemoryDatabase("TFH"));
```

## Files Modified

- `SkuMasterAPI/Program.cs` - Better error handling and connection testing
- `SkuMasterAPI/appsettings.Development.json` - Development connection string
- `SkuMasterAPI/DATABASE_CONNECTION_FIX.md` - This documentation

## Next Steps

1. **Check SQL Server Status**: ตรวจสอบว่า SQL Server เปิดใช้งานอยู่
2. **Update Connection String**: แก้ไข connection string ให้ถูกต้อง
3. **Test Connection**: ทดสอบการเชื่อมต่อด้วย SSMS
4. **Run Application**: รันแอปพลิเคชันใหม่

## Common Solutions

### If SQL Server is not installed:

1. ติดตั้ง SQL Server Express
2. ใช้ connection string สำหรับ SQL Server Express

### If SQL Server is running but can't connect:

1. ตรวจสอบ firewall settings
2. ตรวจสอบ SQL Server configuration
3. ตรวจสอบ username/password

### If database doesn't exist:

1. สร้าง database `TFH` ใน SSMS
2. หรือใช้ `context.Database.EnsureCreated()` ในโค้ด


