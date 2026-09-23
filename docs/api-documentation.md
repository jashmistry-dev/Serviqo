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

---

### 1.4 Current User Profile
- **URL**: `GET /auth/me`
- **Access**: Authenticated (`auth:sanctum`)
- **Headers**: `Authorization: Bearer <token>`

---

### 1.5 Logout
- **URL**: `POST /auth/logout`
- **Access**: Authenticated (`auth:sanctum`)

---

## 2. Service Discovery & Customer Foundation (Phase 4)

### 2.1 List Service Categories
- **URL**: `GET /categories`
- **Access**: Public
- **Description**: Retrieves all active marketplace categories ordered by `sort_order`.

---

### 2.2 Category Detail
- **URL**: `GET /categories/{slugOrId}`
- **Access**: Public

---

### 2.3 List Operating Cities
- **URL**: `GET /cities`
- **Access**: Public

---

### 2.4 Get Customer Profile
- **URL**: `GET /customer/profile`
- **Access**: Authenticated Customer (`auth:sanctum`, `role:customer`)

---

### 2.5 Update Customer Profile
- **URL**: `PUT /customer/profile`
- **Access**: Authenticated Customer (`auth:sanctum`, `role:customer`)

---

## 3. Technician Management & Admin Verification (Phase 5)

### 3.1 Get Technician Profile
- **URL**: `GET /technician/profile`
- **Access**: Authenticated Technician (`role:technician`)
- **Description**: Returns technician profile with services, verifications, city, and statistics.

---

### 3.2 Update Technician Profile & Rates
- **URL**: `PUT /technician/profile`
- **Access**: Authenticated Technician (`role:technician`)
- **Parameters**: `name`, `phone`, `bio`, `experience_years`, `visiting_charge`, `city_id`, `address`, `pincode`.

---

### 3.3 Toggle Duty Availability
- **URL**: `POST /technician/availability`
- **Access**: Authenticated Technician (`role:technician`)
- **Body**: `{"is_available": true}`
- **Business Rule Guard**: Only verified technicians (`verification_status == 'verified'`) can toggle availability online. Unverified or suspended technicians receive `422 Unprocessable Entity`.

---

### 3.4 Upload Verification Document
- **URL**: `POST /technician/verifications`
- **Access**: Authenticated Technician (`role:technician`)
- **Content-Type**: `multipart/form-data`
- **Body**: `document_type` (`government_id`, `police_clearance`, `certification`, `address_proof`), `document_number`, `document` (PDF/Image file up to 5MB).
- **Effect**: Stores document, automatically sets status to `under_review`.

---

### 3.5 Admin: View Verification Queue
- **URL**: `GET /admin/verifications`
- **Access**: Authenticated Super Admin (`role:admin`)
- **Query Params**: `status` (`pending`, `under_review`, `verified`, `rejected`, `suspended`, `all`), `search`.

---

### 3.6 Admin: Review Technician Application
- **URL**: `POST /admin/verifications/{technicianId}/review`
- **Access**: Authenticated Super Admin (`role:admin`)
- **Body**:
```json
{
  "action": "approve", // or "reject", "suspend"
  "reason": "Clear government Aadhaar and trade license verified."
}
```
- **Audit Rule**: Writes an immutable audit record to `audit_logs` table containing `admin.id`, `event`, `old_values`, `new_values`, and client metadata.

---

## 4. Seeded Test Credentials

| Role | Email | Password | Phone | Status |
|---|---|---|---|---|
| **Super Admin** | `admin@serviqo.com` | `Admin@123` | `9000000001` | Active |
| **Technician** | `tech@serviqo.com` | `Tech@123` | `9000000002` | Active (`pending` verification) |
| **Customer** | `customer@serviqo.com` | `Customer@123` | `9000000003` | Active |
| **Suspended User** | `suspended@serviqo.com` | `Password@123` | `9000000004` | Suspended (login blocked) |
