# Serviqo — Architecture

## Overview

Serviqo uses a three-tier architecture:

1. **Mobile Client** (Flutter) — Customer & Technician app
2. **REST API** (Laravel 12 + Sanctum 4.3) — Business logic and data
3. **Admin Panel** (React 19 + TypeScript + Vite + Tailwind CSS) — Platform management

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    CLIENT LAYER                             │
│  ┌──────────────────────┐    ┌──────────────────────────┐   │
│  │   Flutter Mobile App │    │   React Admin Panel      │   │
│  │  (Customer+Technician│    │   (Super Admin only)     │   │
│  │   Riverpod + Dio     │    │   Vite + TS + Tailwind   │   │
│  └──────────┬───────────┘    └───────────┬──────────────┘   │
└─────────────┼──────────────────────────────────────────────┘
              │ HTTPS / REST API (Bearer Token)
              ▼
┌─────────────────────────────────────────────────────────────┐
│                    API LAYER (Port 8080)                    │
│   Laravel 12.69.2 + PHP 8.2 + Laravel Sanctum 4.3.3         │
│   ┌──────────────────────────────────────────────────────┐  │
│   │ Routes → Middleware → FormRequest → Controller       │  │
│   │   → Policy → Service → Model → ApiResource          │  │
│   └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────┐
│                    DATA LAYER (Port 5432)                   │
│   PostgreSQL 16 (Docker)                                    │
│   UUID primary keys | DECIMAL(12,2) for money               │
│   Soft deletes | DB transactions for race conditions        │
└─────────────────────────────────────────────────────────────┘
```

## Backend Architecture

### Layer Responsibilities

| Layer | Responsibility |
|---|---|
| Routes | URL → Controller mapping, grouped by role (`routes/api.php`) |
| Middleware | Auth (`auth:sanctum`), `CheckRole` (`role:admin`, `role:customer,technician`), account active checks |
| FormRequest | Input validation (`RegisterCustomerRequest`, `RegisterTechnicianRequest`, `LoginRequest`) |
| Controller | HTTP parsing, response normalization (`AuthController`) |
| Policy | Authorization checks (customer, technician, admin) |
| Model | Eloquent ORM, UUIDs, HasApiTokens, relationships (`User`, `Customer`, `Technician`, etc.) |
| Seeder | Realistic demo data initialization (`DatabaseSeeder`) |

---

## Authentication & Authorization Architecture (Phase 3 Verified)

### 1. Token Mechanism & Storage
- **Protocol**: Laravel Sanctum Personal Access Tokens (Bearer tokens).
- **Mobile Client**: Stored securely via `FlutterSecureStorage` (`token_storage.dart`). Intercepted by `DioClient` to inject `Authorization: Bearer <token>` into outgoing requests.
- **Admin Panel**: Stored in browser `localStorage` (`serviqo_admin_token`) with session validation on startup.

### 2. Role Isolation & Middleware Enforcement
- **Roles**: Exactly 3 roles: `customer`, `technician`, `admin`.
- **Role Guard**: `CheckRole` middleware checks token owner's `role` and confirms `status === 'active'`. Suspended or inactive users receive `403 Forbidden`.
- **Portal Separation**: Admin login endpoint validates `expected_role: 'admin'`, preventing customer or technician credentials from accessing the admin console.

### 3. Mobile Client Architecture
- **State Management**: Flutter Riverpod (`StateNotifierProvider`).
- **Network Layer**: Dio with request/response interceptors and error normalization.
- **Navigation**: `GoRouter` with auth state gating and splash navigation.
- **Role Dashboards**:
  - `CustomerDashboardScreen`: Real category browsing, active account badge, request trigger.
  - `TechnicianDashboardScreen`: Verification status badge, duty availability toggle, visiting charge display.

### 4. Admin Panel Architecture
- **Framework**: React 19 + TypeScript + Vite + Tailwind CSS v4.
- **State**: `AuthContext` with automatic token verification against `GET /api/auth/me`.
- **Protected Layout**: `AdminShell` layout with responsive navigation, system health status, and super admin badge.
