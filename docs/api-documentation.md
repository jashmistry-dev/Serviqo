# Serviqo API Documentation

Base URL: `http://127.0.0.1:8080/api` (Local Dev) / `http://10.0.2.2:8080/api` (Android Emulator)

All endpoints accept and return JSON (`Accept: application/json`, `Content-Type: application/json`).
All authenticated endpoints require an `Authorization: Bearer <token>` header issued via Laravel Sanctum 4.3.

---

## 1. Authentication Endpoints

### 1.1 Customer Registration
- **URL**: `POST /auth/register/customer`
- **Access**: Public
- **Description**: Registers a new customer account, creates linked customer profile in `customers` table, and issues a Sanctum personal access token.

#### Request Body
```json
{
  "name": "Jane Customer",
  "email": "jane@example.com",
  "phone": "9876543210",
  "password": "Password@123",
  "password_confirmation": "Password@123"
}
```

#### Response (`201 Created`)
```json
{
  "success": true,
  "message": "Customer registered successfully",
  "data": {
    "user": {
      "id": "9d90...-uuid",
      "name": "Jane Customer",
      "email": "jane@example.com",
      "phone": "9876543210",
      "role": "customer",
      "status": "active",
      "customer": {
        "id": "...",
        "total_requests": 0
      }
    },
    "token": "1|sanctum_token_string..."
  }
}
```

---

### 1.2 Technician Registration
- **URL**: `POST /auth/register/technician`
- **Access**: Public
- **Description**: Registers a new technician account, creates linked technician profile with `verification_status: 'pending'`, and issues a token.

#### Request Body
```json
{
  "name": "Rajesh Sharma",
  "email": "rajesh@example.com",
  "phone": "9811223344",
  "password": "Password@123",
  "password_confirmation": "Password@123",
  "experience_years": 5,
  "visiting_charge": 150.00,
  "bio": "Experienced HVAC & Refrigeration specialist with 5 years field experience."
}
```

#### Response (`201 Created`)
```json
{
  "success": true,
  "message": "Technician registered successfully. Verification required before taking jobs.",
  "data": {
    "user": {
      "id": "...",
      "name": "Rajesh Sharma",
      "email": "rajesh@example.com",
      "phone": "9811223344",
      "role": "technician",
      "status": "active",
      "technician": {
        "id": "...",
        "experience_years": 5,
        "visiting_charge": "150.00",
        "verification_status": "pending",
        "is_available": false
      }
    },
    "token": "2|sanctum_token_string..."
  }
}
```

---

### 1.3 Login (Unified)
- **URL**: `POST /auth/login`
- **Access**: Public
- **Description**: Authenticates users by email OR phone. Rejects inactive or suspended accounts. Optionally enforces `expected_role` (e.g. Admin portal passes `expected_role: 'admin'`).

#### Request Body
```json
{
  "login": "admin@serviqo.com",
  "password": "Admin@123",
  "expected_role": "admin"
}
```

#### Response (`200 OK`)
```json
{
  "success": true,
  "message": "Logged in successfully",
  "data": {
    "user": {
      "id": "...",
      "name": "Serviqo Super Admin",
      "email": "admin@serviqo.com",
      "role": "admin",
      "status": "active"
    },
    "token": "3|sanctum_token_string..."
  }
}
```

---

### 1.4 Current User Profile
- **URL**: `GET /auth/me`
- **Access**: Authenticated (`auth:sanctum`)
- **Headers**: `Authorization: Bearer <token>`
- **Description**: Returns authenticated user with linked role-specific profile (`customer` or `technician`).

---

### 1.5 Logout
- **URL**: `POST /auth/logout`
- **Access**: Authenticated (`auth:sanctum`)
- **Description**: Revokes the current access token used for authentication.

---

## 2. Service Discovery & Customer Foundation (Phase 4)

### 2.1 List Service Categories
- **URL**: `GET /categories`
- **Access**: Public
- **Description**: Retrieves all active marketplace categories ordered by `sort_order`.

#### Response (`200 OK`)
```json
{
  "success": true,
  "message": "Service categories retrieved successfully",
  "data": {
    "categories": [
      {
        "id": "uuid",
        "name": "Air Conditioner Repair",
        "slug": "ac-repair",
        "description": "Cooling and repair services",
        "min_visiting_charge": "199.00",
        "is_active": true,
        "sort_order": 1
      }
    ]
  }
}
```

---

### 2.2 Category Detail
- **URL**: `GET /categories/{slugOrId}`
- **Access**: Public
- **Description**: Returns details for a specific category by slug or UUID.

---

### 2.3 List Operating Cities
- **URL**: `GET /cities`
- **Access**: Public
- **Description**: Returns all active operating cities where Serviqo operates.

#### Response (`200 OK`)
```json
{
  "success": true,
  "message": "Cities retrieved successfully",
  "data": {
    "cities": [
      {
        "id": "uuid",
        "name": "Mumbai",
        "state": "Maharashtra",
        "pincode": "400001",
        "is_active": true
      }
    ]
  }
}
```

---

### 2.4 Get Customer Profile
- **URL**: `GET /customer/profile`
- **Access**: Authenticated Customer (`auth:sanctum`, `role:customer`)
- **Description**: Returns the customer's personal details, delivery address, coordinates, and operating city.

---

### 2.5 Update Customer Profile
- **URL**: `PUT /customer/profile`
- **Access**: Authenticated Customer (`auth:sanctum`, `role:customer`)
- **Description**: Updates customer profile fields (name, phone, alternate phone, city, address line 1, address line 2, pincode, coordinates).

#### Request Body
```json
{
  "name": "Kavita Sharma",
  "phone": "9899887766",
  "alternate_phone": "9811223344",
  "city_id": "city-uuid",
  "address_line1": "A-101, Blue Ridge",
  "address_line2": "Hinjewadi Phase 1",
  "pincode": "411057",
  "latitude": 18.5912,
  "longitude": 73.7389
}
```

---

## 3. Seeded Test Credentials

| Role | Email | Password | Phone | Status |
|---|---|---|---|---|
| **Super Admin** | `admin@serviqo.com` | `Admin@123` | `9000000001` | Active |
| **Technician** | `tech@serviqo.com` | `Tech@123` | `9000000002` | Active (`pending` verification) |
| **Customer** | `customer@serviqo.com` | `Customer@123` | `9000000003` | Active |
| **Suspended User** | `suspended@serviqo.com` | `Password@123` | `9000000004` | Suspended (login blocked) |
