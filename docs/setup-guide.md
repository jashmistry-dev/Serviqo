# Serviqo — Setup Guide

## Prerequisites

| Tool | Version | Notes |
|---|---|---|
| PHP | 8.2+ | Via XAMPP at C:\xampp\php |
| Composer | 2.x | Via C:\xampp\php\composer.bat |
| Node.js | 22 LTS | Install from https://nodejs.org |
| Flutter | stable | Install from https://flutter.dev |
| Docker Desktop | Latest | https://docker.com/products/docker-desktop |
| Git | 2.x | https://git-scm.com |

## Required PHP Extensions

All must be enabled (no semicolon) in C:\xampp\php\php.ini:
- pdo_pgsql
- pgsql
- zip
- mbstring
- openssl
- curl
- bcmath
- fileinfo
- tokenizer

## Port Allocation

| Service | Port | Notes |
|---|---|---|
| Laravel API | 8080 | Port 8000 in use by other project |
| PostgreSQL | 5432 | Docker container |
| React Admin | 5174 | Port 5173 in use by other project |

## Step 1: Start Database

```powershell
cd C:\Users\dhoom\Documents\Serviqo\docker

# First time only — create local env file
cp .env.example .env
# Edit .env if you need different credentials

# Start PostgreSQL container
docker compose up -d

# Verify it is healthy
docker ps --filter "name=serviqo_postgres"
# Expected: Status shows "Up ... (healthy)"
```

## Step 2: Start Backend API

```powershell
cd C:\Users\dhoom\Documents\Serviqo\backend

# First time only
cp .env.example .env
# Edit .env — ensure DB_PASSWORD matches docker/.env POSTGRES_PASSWORD
php artisan key:generate

# Run framework migrations (users, cache, jobs tables)
php artisan migrate

# Start development server
php artisan serve --port=8080
```

Key .env values:
```
APP_URL=http://localhost:8080
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=serviqo
DB_USERNAME=serviqo_user
DB_PASSWORD=serviqo_dev_password
```

## Step 3: Start Admin Panel

```powershell
cd C:\Users\dhoom\Documents\Serviqo\admin
npm install
npm run dev
# Access: http://localhost:5174
```

## Step 4: Run Flutter App

```powershell
cd C:\Users\dhoom\Documents\Serviqo\mobile
flutter pub get
flutter run
```

Configure API base URL in mobile/lib/core/constants/api_constants.dart:
```dart
// For Android emulator (accesses host via 10.0.2.2)
static const String baseUrl = 'http://10.0.2.2:8080/api';

// For physical Android device on same WiFi — use your machine's LAN IP
// static const String baseUrl = 'http://192.168.x.x:8080/api';
```

## Step 5: Run Backend Tests

```powershell
cd C:\Users\dhoom\Documents\Serviqo\backend
php artisan test
```

## Troubleshooting

### "php not recognized"
Add C:\xampp\php to Windows User PATH, then restart terminal.

### pdo_pgsql extension not found
Ensure extension=pdo_pgsql (no semicolon) in C:\xampp\php\php.ini

### PostgreSQL connection refused
Run: docker ps — confirm serviqo_postgres is Up and healthy.
If not running: cd docker && docker compose up -d

### Port 8080 conflicts
Change --port=8080 to a free port and update Flutter apiConstants.dart

### Docker Desktop not starting
Launch from: C:\Users\dhoom\AppData\Local\Programs\DockerDesktop\Docker Desktop.exe
