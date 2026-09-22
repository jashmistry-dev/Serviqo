# Serviqo — Data Dictionary

This document details every table, column, data type, constraint, and description in the Serviqo PostgreSQL 16 database.

---

## 1. users
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | UUID | No | PK | Unique user identifier |
| `name` | VARCHAR(255) | No | - | Full name |
| `email` | VARCHAR(255) | No | UNIQUE | Primary email address |
| `phone` | VARCHAR(20) | Yes | UNIQUE | Phone number for OTP/SMS |
| `password` | VARCHAR(255) | No | - | Bcrypt/Argon2 hashed password |
| `role` | VARCHAR(20) | No | `'customer'` | `customer`, `technician`, `admin` |
| `is_active` | BOOLEAN | No | `true` | Account active flag |
| `email_verified_at` | TIMESTAMP | Yes | NULL | Email verification timestamp |
| `phone_verified_at` | TIMESTAMP | Yes | NULL | Phone verification timestamp |
| `avatar_url` | VARCHAR(255) | Yes | NULL | Profile image path |
| `remember_token` | VARCHAR(100) | Yes | NULL | Remember token |
| `created_at` | TIMESTAMP | Yes | NULL | Record creation timestamp |
| `updated_at` | TIMESTAMP | Yes | NULL | Record modification timestamp |
| `deleted_at` | TIMESTAMP | Yes | NULL | Soft delete timestamp |

---

## 2. customers
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | UUID | No | PK | Customer record identifier |
| `user_id` | UUID | No | FK UNIQUE | Refers to `users.id` (CASCADE) |
| `alternate_phone` | VARCHAR(20) | Yes | NULL | Backup contact number |
| `address_line1` | VARCHAR(255) | Yes | NULL | Street address / flat / building |
| `address_line2` | VARCHAR(255) | Yes | NULL | Area / landmark |
| `city_id` | UUID | Yes | FK | Refers to `cities.id` (SET NULL) |
| `pincode` | VARCHAR(10) | Yes | NULL | Postal code |
| `latitude` | NUMERIC(10,7) | Yes | NULL | Geolocation latitude |
| `longitude` | NUMERIC(10,7) | Yes | NULL | Geolocation longitude |
| `created_at`, `updated_at`, `deleted_at` | TIMESTAMP | Yes | NULL | Standard audit timestamps |

---

## 3. technicians
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | UUID | No | PK | Technician record identifier |
| `user_id` | UUID | No | FK UNIQUE | Refers to `users.id` (CASCADE) |
| `bio` | TEXT | Yes | NULL | Professional biography |
| `experience_years` | INTEGER | No | `0` | Years of trade experience |
| `visiting_charge` | NUMERIC(12,2) | No | `0.00` | Standard visiting fee (BR-002) |
| `verification_status` | VARCHAR(32) | No | `'pending'` | `pending`, `under_review`, `verified`, `rejected`, `suspended` |
| `verification_notes` | TEXT | Yes | NULL | Admin verification commentary |
| `verified_at` | TIMESTAMP | Yes | NULL | Verification approval date |
| `verified_by` | UUID | Yes | FK | Admin user who verified (SET NULL) |
| `is_available` | BOOLEAN | No | `false` | Quick duty toggle for requests |
| `subscription_tier` | VARCHAR(32) | No | `'free'` | `free`, `basic`, `pro` |
| `subscription_expires_at` | TIMESTAMP | Yes | NULL | Subscription expiration date |
| `rating_avg` | NUMERIC(3,2) | No | `0.00` | Calculated aggregate rating (1.00-5.00) |
| `rating_count` | INTEGER | No | `0` | Total verified ratings count |
| `city_id` | UUID | Yes | FK | Operating base city |
| `address` | TEXT | Yes | NULL | Operating office / residential address |
| `pincode` | VARCHAR(10) | Yes | NULL | Operating base pincode |
| `latitude`, `longitude` | NUMERIC(10,7) | Yes | NULL | Base geolocation |
| `created_at`, `updated_at`, `deleted_at` | TIMESTAMP | Yes | NULL | Standard audit timestamps |

---

## 4. technician_verifications
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | UUID | No | PK | Verification attempt identifier |
| `technician_id` | UUID | No | FK | Refers to `technicians.id` (CASCADE) |
| `document_type` | VARCHAR(50) | No | - | `government_id`, `police_clearance`, `certification`, `address_proof` |
| `document_number` | VARCHAR(100) | Yes | NULL | Identification number on document |
| `file_path` | VARCHAR(255) | No | - | Storage path of uploaded document |
| `status` | VARCHAR(32) | No | `'pending'` | `pending`, `approved`, `rejected` |
| `rejection_reason` | TEXT | Yes | NULL | Feedback why rejected |
| `reviewed_by` | UUID | Yes | FK | Reviewing admin user (SET NULL) |
| `reviewed_at` | TIMESTAMP | Yes | NULL | Timestamp of review |

---

## 5. cities
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | UUID | No | PK | City record identifier |
| `name` | VARCHAR(100) | No | - | City name (e.g. Mumbai, Surat) |
| `state` | VARCHAR(100) | No | - | State name |
| `is_active` | BOOLEAN | No | `true` | Platform active status in city |
| `pincodes` | JSONB | Yes | NULL | Array of serviced pincodes |

---

## 6. service_categories
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | UUID | No | PK | Category identifier |
| `name` | VARCHAR(100) | No | UNIQUE | Category title (e.g. Plumbing) |
| `slug` | VARCHAR(100) | No | UNIQUE | URL slug (`plumbing`) |
| `description` | TEXT | Yes | NULL | Category summary |
| `icon_url`, `image_url` | VARCHAR(255) | Yes | NULL | Visual asset URLs |
| `min_visiting_charge` | NUMERIC(12,2) | No | `0.00` | Platform price floor |
| `max_visiting_charge` | NUMERIC(12,2) | Yes | NULL | Platform price ceiling |
| `is_active` | BOOLEAN | No | `true` | Display status |
| `sort_order` | INTEGER | No | `0` | Ordering index |

---

## 7. technician_services
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | UUID | No | PK | Skill mapping identifier |
| `technician_id` | UUID | No | FK | Refers to `technicians.id` (CASCADE) |
| `service_category_id` | UUID | No | FK | Refers to `service_categories.id` (CASCADE) |
| `custom_visiting_charge` | NUMERIC(12,2) | Yes | NULL | Override visiting charge for this skill |
| `experience_years` | INTEGER | No | `0` | Years in this specific trade |
| `is_active` | BOOLEAN | No | `true` | Skill active status |
*(Unique composite constraint on `technician_id, service_category_id`)*

---

## 8. technician_availabilities
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | UUID | No | PK | Availability schedule slot |
| `technician_id` | UUID | No | FK | Refers to `technicians.id` (CASCADE) |
| `day_of_week` | SMALLINT | No | - | `0` (Sunday) through `6` (Saturday) |
| `start_time`, `end_time` | TIME | No | - | Working hours slot |
| `is_active` | BOOLEAN | No | `true` | Active status |

---

## 9. service_requests
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | UUID | No | PK | Unique service request identifier |
| `tracking_number` | VARCHAR(32) | No | UNIQUE | Public tracking reference (`REQ-XXXX`) |
| `customer_id` | UUID | No | FK | Customer creator (RESTRICT) |
| `service_category_id` | UUID | No | FK | Target category (RESTRICT) |
| `title` | VARCHAR(255) | No | - | Problem headline |
| `description` | TEXT | No | - | Detailed description |
| `images` | JSONB | Yes | NULL | Photos of issue |
| `preferred_date` | DATE | No | - | Requested service date |
| `preferred_time_slot` | VARCHAR(32) | No | - | `morning`, `afternoon`, `evening` |
| `address_line` | TEXT | No | - | Complete service location |
| `city_id` | UUID | Yes | FK | Operating city |
| `pincode` | VARCHAR(10) | No | - | Postal pincode |
| `status` | VARCHAR(32) | No | `'requested'` | Request lifecycle state |
| `assigned_technician_id`| UUID | Yes | FK | Technician who won acceptance (SET NULL) |
| `accepted_at` | TIMESTAMP | Yes | NULL | Timestamp first technician accepted |
| `cancelled_at` | TIMESTAMP | Yes | NULL | Cancellation timestamp |
| `cancelled_by` | UUID | Yes | FK | User who cancelled (SET NULL) |
| `cancellation_reason` | TEXT | Yes | NULL | Reason text |
| `completed_at` | TIMESTAMP | Yes | NULL | Completion timestamp |
| `visiting_charge_locked`| NUMERIC(12,2)| No | `0.00` | Agreed visiting charge locked |
| `lock_version` | INTEGER | No | `0` | Concurrency lock counter |

---

## 10. request_technician_assignments
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | UUID | No | PK | Broadcast mapping identifier |
| `service_request_id` | UUID | No | FK | Refers to `service_requests.id` (CASCADE) |
| `technician_id` | UUID | No | FK | Candidate technician (CASCADE) |
| `status` | VARCHAR(32) | No | `'pending'` | `pending`, `viewed`, `accepted`, `rejected`, `expired`, `lost_race` |
| `visiting_charge_offered`| NUMERIC(12,2)| No | `0.00` | Visiting charge at time of broadcast |
| `responded_at` | TIMESTAMP | Yes | NULL | When technician acted |
| `rejection_reason` | TEXT | Yes | NULL | Technician decline reason |
*(Unique composite on `service_request_id, technician_id`)*

---

## 11. service_visits
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | UUID | No | PK | Visit identifier |
| `service_request_id` | UUID | No | FK | Refers to `service_requests.id` (CASCADE) |
| `technician_id` | UUID | No | FK | Assigned technician (RESTRICT) |
| `visit_status` | VARCHAR(32) | No | `'scheduled'`| `scheduled`, `on_the_way`, `arrived`, `inspection_in_progress`, `completed`, `cancelled` |
| `scheduled_at` | TIMESTAMP | No | - | Scheduled appointment timestamp |
| `arrived_at` | TIMESTAMP | Yes | NULL | Physical arrival timestamp |
| `completed_at` | TIMESTAMP | Yes | NULL | Inspection completion timestamp |
| `visiting_charge` | NUMERIC(12,2) | No | `0.00` | Payable fee (BR-002) |
| `visiting_charge_paid`| BOOLEAN | No | `false` | Whether visiting charge settled |
| `inspection_notes` | TEXT | Yes | NULL | Findings after diagnosing issue |
| `inspection_images` | JSONB | Yes | NULL | Photos taken during diagnosis |

---

## 12. quotations & quotation_items
| Table | Column | Type | Constraints | Description |
|---|---|---|---|---|
| `quotations` | `id` | UUID | PK | Quotation identifier |
| | `quotation_number` | VARCHAR(32) | UNIQUE | Quote reference (`QUO-XXXX`) |
| | `service_request_id`| UUID | FK (CASCADE) | Refers to `service_requests.id` |
| | `technician_id` | UUID | FK (RESTRICT)| Refers to `technicians.id` |
| | `version` | INTEGER | Default `1` | Quotation revision number |
| | `status` | VARCHAR(32) | Default `'draft'` | `draft`, `sent`, `accepted`, `rejected`, `superseded` |
| | `subtotal_amount` | NUMERIC(12,2) | Default `0.00`| Total before discount |
| | `discount_amount` | NUMERIC(12,2) | Default `0.00`| Discount provided by technician |
| | `visiting_charge_included` | NUMERIC(12,2)| Default `0.00`| Visiting charge component |
| | `total_amount` | NUMERIC(12,2) | Default `0.00`| Final quotation total |
| `quotation_items` | `id` | UUID | PK | Line item identifier |
| | `quotation_id` | UUID | FK (CASCADE) | Refers to `quotations.id` |
| | `item_type` | VARCHAR(32) | Default `'labor'` | `labor`, `part`, `inspection`, `other` |
| | `description` | VARCHAR(255) | NOT NULL | Item details |
| | `quantity` | NUMERIC(8,2) | Default `1.00`| Units / hours |
| | `unit_price` | NUMERIC(12,2) | Default `0.00`| Unit cost |
| | `total_price` | NUMERIC(12,2) | Default `0.00`| `quantity * unit_price` |

---

## 13. additional_charges
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | UUID | No | PK | Additional charge identifier |
| `service_request_id` | UUID | No | FK | Refers to `service_requests.id` (CASCADE) |
| `quotation_id` | UUID | Yes | FK | Optional related quotation (SET NULL) |
| `technician_id` | UUID | No | FK | Submitting technician (RESTRICT) |
| `title` | VARCHAR(255) | No | - | Scope of unforeseen work |
| `description` | TEXT | No | - | Reason why required |
| `amount` | NUMERIC(12,2) | No | - | Extra cost requested |
| `status` | VARCHAR(32) | No | `'pending_approval'` | `pending_approval`, `approved`, `rejected` |
| `rejection_reason` | TEXT | Yes | NULL | Customer reason if declined |
| `evidence_images` | JSONB | Yes | NULL | Photos supporting extra work |

---

## 14. payments
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | UUID | No | PK | Payment transaction identifier |
| `transaction_reference` | VARCHAR(40) | No | UNIQUE | Transaction code (`PAY-XXXX`) |
| `service_request_id` | UUID | Yes | FK | Associated request (CASCADE) |
| `payer_user_id` | UUID | No | FK | Customer user (RESTRICT) |
| `payee_user_id` | UUID | No | FK | Technician / Platform user (RESTRICT) |
| `payment_type` | VARCHAR(32) | No | - | `visiting_charge`, `service_full`, `service_balance`, `additional_charge`, `subscription` |
| `payment_method` | VARCHAR(16) | No | `'upi'` | `upi`, `cash` |
| `amount` | NUMERIC(12,2) | No | - | Amount transacted |
| `status` | VARCHAR(32) | No | `'pending'` | `pending`, `paid`, `failed`, `refunded`, `disputed` |
| `paid_at` | TIMESTAMP | Yes | NULL | Successful payment timestamp |
| `upi_transaction_id` | VARCHAR(100) | Yes | NULL | Bank / UPI reference number |
| `cash_collected_by` | UUID | Yes | FK | User confirming cash receipt (SET NULL) |
| `cash_confirmed_at` | TIMESTAMP | Yes | NULL | Cash receipt confirmation timestamp |
| `gateway_response` | JSONB | Yes | NULL | Raw gateway response |

---

## 15. platform_fees
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | UUID | No | PK | Commission identifier |
| `service_request_id` | UUID | No | FK UNIQUE | Refers to `service_requests.id` (CASCADE) |
| `technician_id` | UUID | No | FK | Refers to `technicians.id` (RESTRICT) |
| `payment_id` | UUID | Yes | FK | Linked settlement payment (SET NULL) |
| `base_amount` | NUMERIC(12,2) | No | - | Service amount subject to fee |
| `fee_percentage` | NUMERIC(5,2) | No | `10.00` | Platform take rate |
| `fee_amount` | NUMERIC(12,2) | No | - | Calculated platform commission |
| `gst_amount` | NUMERIC(12,2) | No | `0.00` | Tax component on commission |
| `total_platform_fee` | NUMERIC(12,2) | No | - | `fee_amount + gst_amount` |
| `status` | VARCHAR(32) | No | `'pending'` | `pending`, `deducted`, `waived`, `settled` |
| `settled_at` | TIMESTAMP | Yes | NULL | Settlement timestamp |

---

## 16. technician_subscriptions
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | UUID | No | PK | Subscription record identifier |
| `technician_id` | UUID | No | FK | Refers to `technicians.id` (CASCADE) |
| `plan_name` | VARCHAR(32) | No | - | `free_starter`, `pro_monthly`, `pro_annual` |
| `status` | VARCHAR(32) | No | `'active'` | `active`, `expired`, `cancelled`, `grace_period` |
| `amount_paid` | NUMERIC(12,2) | No | `0.00` | Price paid |
| `payment_id` | UUID | Yes | FK | Associated transaction (SET NULL) |
| `starts_at` | TIMESTAMP | No | - | Active period start |
| `expires_at` | TIMESTAMP | No | - | Active period end |

---

## 17. reviews
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | UUID | No | PK | Review identifier |
| `service_request_id` | UUID | No | FK UNIQUE | One rating per completed service (BR-006) |
| `customer_id` | UUID | No | FK | Reviewer (RESTRICT) |
| `technician_id` | UUID | No | FK | Technician rated (CASCADE) |
| `rating` | SMALLINT | No | - | Star rating (1 to 5) |
| `review_text` | TEXT | Yes | NULL | Customer commentary |
| `technician_reply` | TEXT | Yes | NULL | Technician public response |
| `technician_replied_at`| TIMESTAMP | Yes | NULL | Reply timestamp |
| `is_public` | BOOLEAN | No | `true` | Public visibility flag |

---

## 18. complaints
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | UUID | No | PK | Complaint ticket identifier |
| `ticket_number` | VARCHAR(32) | No | UNIQUE | Public ticket reference (`CMP-XXXX`) |
| `service_request_id` | UUID | No | FK | Associated service request (CASCADE) |
| `raised_by_user_id` | UUID | No | FK | Initiating party (RESTRICT) |
| `against_user_id` | UUID | No | FK | Defending party (RESTRICT) |
| `complaint_type` | VARCHAR(32) | No | - | `service_quality`, `billing_issue`, `no_show`, `behavior`, `damage`, `other` |
| `description` | TEXT | No | - | Detailed grievance |
| `evidence_files` | JSONB | Yes | NULL | Supporting media |
| `status` | VARCHAR(32) | No | `'opened'` | `opened`, `under_investigation`, `resolved`, `escalated`, `dismissed` |
| `resolution_notes` | TEXT | Yes | NULL | Admin resolution outcome |
| `resolved_by` | UUID | Yes | FK | Admin user (SET NULL) |
| `resolved_at` | TIMESTAMP | Yes | NULL | Resolution timestamp |

---

## 19. audit_logs
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | UUID | No | PK | Audit log entry identifier |
| `user_id` | UUID | Yes | FK | Actor user (SET NULL) |
| `auditable_type` | VARCHAR(255)| No | - | Target Model class name |
| `auditable_id` | UUID | No | - | Target record UUID |
| `event` | VARCHAR(64) | No | - | Action name (e.g. `accepted`, `status_changed`) |
| `old_values` | JSONB | Yes | NULL | Snapshot of fields before change |
| `new_values` | JSONB | Yes | NULL | Snapshot of fields after change |
| `ip_address` | VARCHAR(45) | Yes | NULL | Client IP address |
| `user_agent` | TEXT | Yes | NULL | Client device user agent |
| `created_at` | TIMESTAMP | No | CURRENT | Immutable logging timestamp |

---

## 20. system_settings
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | UUID | No | PK | Setting identifier |
| `key` | VARCHAR(64) | No | UNIQUE | Configuration key (e.g. `platform_commission_pct`) |
| `value` | TEXT | No | - | Setting value |
| `type` | VARCHAR(16) | No | `'string'` | `string`, `number`, `boolean`, `json` |
| `description` | VARCHAR(255)| Yes | NULL | Admin explanation |
| `updated_by` | UUID | Yes | FK | Last editor admin user (SET NULL) |

---

## 21. personal_access_tokens (Sanctum)
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | BIGINT | No | PK | Token primary key |
| `tokenable_type` | VARCHAR(255)| No | - | Polymorphic model class (`App\Models\User`) |
| `tokenable_id` | UUID | No | - | Polymorphic user UUID |
| `name` | VARCHAR(255)| No | - | Token name |
| `token` | VARCHAR(64) | No | UNIQUE | SHA-256 hashed bearer token |
| `abilities` | TEXT | Yes | NULL | Token abilities JSON |
| `last_used_at` | TIMESTAMP | Yes | NULL | Last API request timestamp |
| `expires_at` | TIMESTAMP | Yes | NULL | Expiration timestamp |