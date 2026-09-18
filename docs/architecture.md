# Serviqo — Architecture

## Overview

Serviqo uses a three-tier architecture:

1. **Mobile Client** (Flutter) — Customer & Technician app
2. **REST API** (Laravel 11) — Business logic and data
3. **Admin Panel** (React + TypeScript) — Platform management

## System Architecture Diagram

`
┌─────────────────────────────────────────────────────────────┐
│                    CLIENT LAYER                              │
│  ┌──────────────────────┐    ┌──────────────────────────┐   │
│  │   Flutter Mobile App │    │   React Admin Panel      │   │
│  │  (Customer+Technician│    │   (Super Admin only)     │   │
│  │   Riverpod + Dio     │    │   Vite + TS + Tailwind   │   │
│  └──────────┬───────────┘    └───────────┬──────────────┘   │
└─────────────┼──────────────────────────────────────────────┘
              │ HTTPS / REST API (Bearer Token)
              ▼
┌─────────────────────────────────────────────────────────────┐
│                    API LAYER (Port 8080)                      │
│   Laravel 11 + PHP 8.2 + Laravel Sanctum                     │
│   ┌──────────────────────────────────────────────────────┐  │
│   │ Routes → Middleware → FormRequest → Controller       │  │
│   │   → Policy → Service → Model → ApiResource          │  │
│   └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────┐
│                    DATA LAYER (Port 5432)                     │
│   PostgreSQL 16 (Docker)                                     │
│   UUID primary keys | DECIMAL(12,2) for money               │
│   Soft deletes | DB transactions for race conditions         │
└─────────────────────────────────────────────────────────────┘
`

## Backend Architecture

See implementation_plan.md for full detail.

### Layer Responsibilities

| Layer | Responsibility |
|---|---|
| Routes | URL → Controller mapping, grouped by role |
| Middleware | Auth, CheckRole, throttle |
| FormRequest | Input validation (one class per action) |
| Controller | HTTP parsing, delegate to Service |
| Policy | Authorization checks |
| Service | ALL business logic |
| Model | Eloquent ORM, relationships |
| ApiResource | Controlled JSON output |
| Enum | Status constants (no magic strings) |

## Flutter Architecture

Clean Architecture with three layers:

`
Presentation (UI/Widgets/Riverpod)
    ↕
Domain (UseCases, Entities, Repository interfaces)
    ↕
Data (Repository implementations, API datasources, JSON models)
`

## Port Allocation

| Service | Port | Notes |
|---|---|---|
| Laravel API | 8080 | (8000 used by existing brewos project) |
| PostgreSQL | 5432 | Docker container |
| React Admin | 5174 | (5173 used by existing brewos project) |
| pgAdmin (optional) | 5050 | Docker, profile=tools |

## Security Architecture

- Bearer token authentication (Laravel Sanctum)
- Role enforcement via CheckRole middleware (server-side only)
- FormRequest validation on all inputs
- Policy authorization on all resources
- No secrets in Git (all via .env)
- Money stored as DECIMAL(12,2) — never FLOAT
