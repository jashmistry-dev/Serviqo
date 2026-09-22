# Serviqo — Database Schema Architecture

## Overview

Serviqo utilizes PostgreSQL 16 as its relational persistence engine. The schema is built for a verified local service marketplace connecting Customers, Technicians, and Super Admins.

- **Engine**: PostgreSQL 16 (via Docker container `serviqo_postgres`)
- **Primary Keys**: Universally Unique Identifiers (UUID v4) on all domain models
- **Financial Precision**: `DECIMAL(12,2)` on all monetary fields (zero floating-point arithmetic)
- **Soft Deletes**: Enabled on core domain tables (`users`, `customers`, `technicians`, `service_categories`, `service_requests`)
- **Concurrency & Race Conditions**: Enforces atomic locking on technician acceptance via database transactions, row-level `SELECT FOR UPDATE`, and optimistic `lock_version` integer counters.

---

## Entity Relationship Overview

```
                      ┌───────────────┐
                      │     users     │ (UUID PK)
                      └──┬─────────┬──┘
         ┌───────────────┘         └────────────────┐
         ▼ 1:1                                      ▼ 1:1
   ┌───────────┐                              ┌─────────────┐
   │ customers │                              │ technicians │
   └─────┬─────┘                              └──────┬──────┘
         │                                    ┌──────┴───────────────────────────┐
         │ 1:N                                ▼ 1:N         ▼ 1:N                ▼ 1:N
         │                             ┌─────────────┐ ┌──────────────┐ ┌──────────────────────┐
         │                             │ technician_ │ │ technician_  │ │      technician_     │
         │                             │verifications│ │ services     │ │    availabilities    │
         │                             └─────────────┘ └──────────────┘ └──────────────────────┘
         ▼ 1:N                                                ▲
┌──────────────────┐                                          │ (skills)
│ service_requests ├──────────────────────────────────────────┘
└─┬────┬────┬──┬─┬─┘
  │    │    │  │ └────────────────────────────┐
  │    │    │  └───────────────┐              │
  ▼1:N │1:N │1:N               ▼1:N           ▼1:1 (BR-006)
┌──────┴──┐ │  ┌────────────┐ ┌────────────┐ ┌─────────┐
│ request_│ │  │ quotations │ │  payments  │ │ reviews │
│technici-│ │  └───┬────────┘ └────────────┘ └─────────┘
│an_assign│ │      ▼ 1:N
│ ments   │ │  ┌────────────┐
└─────────┘ │  │ quotation_ │
            │  │   items    │
            ▼  └────────────┘
┌──────────────┐
│service_visits│
└──────────────┘
```

---

## Core Domain Tables & Relationships

### 1. Identity & Profiles
- **`users`**: Base identity (Customer, Technician, Admin). Role enum: `customer`, `technician`, `admin`.
- **`customers`**: Customer profile, addresses, city reference, geo-coordinates.
- **`technicians`**: Technician profile, base visiting charge, verification status (`pending`, `under_review`, `verified`, `rejected`, `suspended`), rating metrics, location.
- **`technician_verifications`**: Document submissions, review timestamps, rejection reasons, reviewer audit.
- **`cities`**: Operational service areas and active pincodes.

### 2. Services & Skills
- **`service_categories`**: Master service types (Plumbing, Electrical, Appliance, AC, Carpentry, Painting). Holds platform visiting charge bounds (`min_visiting_charge`, `max_visiting_charge`).
- **`technician_services`**: Many-to-many link between technicians and categories they are qualified for. Unique on `(technician_id, service_category_id)`.
- **`technician_availabilities`**: Weekly schedule matrix (`day_of_week`, `start_time`, `end_time`).

### 3. Service Lifecycle & Concurrency
- **`service_requests`**: Problem requests initiated by customer (NOT a direct booking).
  - Statuses: `draft`, `requested`, `broadcasted`, `accepted`, `visiting`, `inspection_completed`, `quotation_sent`, `quotation_accepted`, `quotation_rejected`, `additional_approval_pending`, `in_progress`, `completed`, `cancelled`, `disputed`.
  - `assigned_technician_id`: `NULL` until first technician successfully accepts.
  - `visiting_charge_locked`: Fixed visiting charge locked at broadcast/acceptance.
  - `lock_version`: Optimistic concurrency version counter.
- **`request_technician_assignments`**: Tracks each technician the request was broadcast to.
  - Status: `pending`, `viewed`, `accepted`, `rejected`, `expired`, `lost_race`.
  - Unique constraint: `(service_request_id, technician_id)`.
- **`service_visits`**: Inspection visits.
  - `visiting_charge`: Decoupled from service repair charges. Remains payable even if quotation is subsequently rejected (BR-002).
  - `visiting_charge_paid`: Boolean flag.

### 4. Quotations & Additional Work
- **`quotations`**: Versioned repair estimates prepared post-visit (BR-005: immutable).
  - Financial breakdown: `subtotal_amount`, `discount_amount`, `visiting_charge_included`, `total_amount`.
  - Status: `draft`, `sent`, `accepted`, `rejected`, `superseded`.
- **`quotation_items`**: Line items for labor, parts, and materials (`quantity`, `unit_price`, `total_price`).
- **`additional_charges`**: Unexpected extra work identified during repair.
  - Requires explicit customer authorization (`status`: `pending_approval`, `approved`, `rejected`).

### 5. Financial Ledger & Platform Monetization
- **`payments`**: Transaction records.
  - Methods: `upi`, `cash` (Phase 1).
  - Types: `visiting_charge`, `service_full`, `service_balance`, `additional_charge`, `subscription`.
  - Status: `pending`, `paid`, `failed`, `refunded`, `disputed`.
- **`platform_fees`**: Commission deduction per completed service (BR-007).
  - Tracks `base_amount`, `fee_percentage`, `fee_amount`, `gst_amount`, `total_platform_fee`.
  - Unique constraint on `service_request_id`.
- **`technician_subscriptions`**: Platform subscription plans for technicians (`starts_at`, `expires_at`).

### 6. Trust, Safety & Quality
- **`reviews`**: Customer ratings (1-5) and feedback.
  - **Strict Unique Constraint**: `UNIQUE (service_request_id)`. Exactly one rating allowed per completed service request (BR-006).
- **`complaints`**: Dispute tickets with evidence files (`complaint_type`, `status`, `resolution_notes`).
- **`audit_logs`**: Immutable audit log for financial events, status transitions, and administrative reviews.
- **`system_settings`**: Global platform key-value configurations.
- **`personal_access_tokens`**: Laravel Sanctum API authentication with polymorphic UUID support (`tokenable_id` UUID).