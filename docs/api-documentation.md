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

#### Error Responses
- `401 Unauthorized`: Invalid credentials.
- `403 Forbidden`: Account is suspended/inactive, or role does not match `expected_role`.
- `422 Unprocessable Entity`: Validation errors.

---

### 1.4 Current User Profile
- **URL**: `GET /auth/me`
- **Access**: Authenticated (`auth:sanctum`)
- **Headers**: `Authorization: Bearer <token>`
- **Description**: Returns authenticated user with linked role-specific profile (`customer` or `technician`).

#### Response (`200 OK`)
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "...",
      "name": "Serviqo Super Admin",
      "email": "admin@serviqo.com",
      "role": "admin",
      "status": "active"
    }
  }
}
```

---

### 1.5 Logout
- **URL**: `POST /auth/logout`
- **Access**: Authenticated (`auth:sanctum`)
- **Description**: Revokes the current access token used for authentication.

#### Response (`200 OK`)
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

## 2. Seeded Test Credentials

| Role | Email | Password | Phone | Status |
|---|---|---|---|---|
| **Super Admin** | `admin@serviqo.com` | `Admin@123` | `9000000001` | Active |
| **Technician** | `tech@serviqo.com` | `Tech@123` | `9000000002` | Active (`pending` verification) |
| **Customer** | `customer@serviqo.com` | `Customer@123` | `9000000003` | Active |
| **Suspended User** | `suspended@serviqo.com` | `Password@123` | `9000000004` | Suspended (login blocked) |
