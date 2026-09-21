# Serviqo — Verified Local Service Marketplace

Serviqo is a local service marketplace connecting **Customers**, **Technicians**, and a **Super Admin**.

## Project Structure

```
Serviqo/
├── backend/      # Laravel 12 REST API (PHP 8.2 + Sanctum)
├── mobile/       # Flutter App — Customer & Technician (Dart + Riverpod)
├── admin/        # React + TypeScript + Tailwind CSS Admin Panel (Vite)
├── docker/       # Docker Compose — PostgreSQL 16 (development)
└── docs/         # Architecture, API, setup documentation
```

## Tech Stack

| Layer | Technology | Version |
|---|---|---|
| Mobile App | Flutter + Dart + Riverpod | Flutter stable |
| Backend API | Laravel + PHP + Sanctum | Laravel 12.69.2 / PHP 8.2 |
| Database | PostgreSQL (via Docker) | 16-alpine |
| Admin Panel | React + TypeScript + Tailwind CSS + Vite | Node 22 LTS |

## Port Allocation (Development)

| Service | Port | Notes |
|---|---|---|
| Laravel API | **8080** | (8000 used by other local project) |
| PostgreSQL | **5432** | Docker container |
| React Admin | **5174** | (5173 used by other local project) |

## Quick Start

### Prerequisites
- PHP 8.2+ with extensions: pdo_pgsql, pgsql, zip, mbstring, openssl, curl
- Composer 2.x
- Node.js 22 LTS + npm
- Flutter stable channel
- Docker Desktop (for PostgreSQL)

### 1. Start Database
```powershell
cd docker
# Copy env template (first time only)
cp .env.example .env
# Start PostgreSQL
docker compose up -d
```

### 2. Start Backend API
```powershell
cd backend
# Copy env template (first time only)
cp .env.example .env
# Edit .env with your local values if needed
php artisan key:generate
php artisan migrate
php artisan serve --port=8080
```

### 3. Start Admin Panel
```powershell
cd admin
npm install
npm run dev
# Runs on http://localhost:5174
```

### 4. Run Flutter App
```powershell
cd mobile
flutter pub get
flutter run
# Ensure physical device connected or emulator running
```

### 5. Run Backend Tests
```powershell
cd backend
php artisan test
```

## Documentation

- [Architecture](docs/architecture.md)
- [Business Rules](docs/business-rules.md)
- [API Documentation](docs/api-documentation.md)
- [Database Schema](docs/database-schema.md)
- [Setup Guide](docs/setup-guide.md)

## Development Status

> Phase 1 — Step 1 (Foundation) complete

## Note

This is an academic project built to real-world production development standards.
