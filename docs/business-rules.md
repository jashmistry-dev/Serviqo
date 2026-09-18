# Serviqo — Business Rules

## Roles

- **Customer**: Uses the service marketplace
- **Technician**: Provides services
- **Super Admin**: Platform management

## Critical Business Rules

### BR-001: Multiple Technician Request
A customer may send one service request to multiple technicians.
The FIRST technician to successfully accept locks the request atomically.
Other pending requests become unavailable. Backend enforces this via DB transaction + SELECT FOR UPDATE.

### BR-002: Visiting Charge
Visiting charge is defined by technician (within platform limits).
Customer must see it BEFORE sending a request.
It is payable even if quotation is rejected after inspection.

### BR-003: First Acceptance Wins
Race condition scenario: Two technicians accept simultaneously.
Only ONE succeeds. Second receives a conflict error.
Implemented via database-level locking.

### BR-004: Financial Amounts
All money stored as DECIMAL(12,2). Never FLOAT.
Financial calculations centralized in FinancialCalculationService.
The system tracks: Visiting Charge, Service Charge, Discount, Additional Charges, Platform Fee, Final Amount.

### BR-005: Quotation Immutability
Approved quotations must not be silently modified.
Additional charges require separate explicit customer approval.

### BR-006: Rating Eligibility
Customer may only rate after service is marked COMPLETED.
One rating per service. Duplicate ratings prevented at DB level.

### BR-007: Platform Fee
Configurable by Super Admin. Centrally calculated. Applied on completed services.

### BR-008: Role Authorization
Roles are ONLY trusted from the server-side authenticated user record.
Never from client-provided data.

## Service State Machine

`
REQUESTED
  → PENDING_ACCEPTANCE (sent to technicians)
  → ACCEPTED (first technician accepts — locks)
  → VISITING (technician marks arrival)
  → INSPECTION_COMPLETED
  → QUOTATION_SENT
  → QUOTATION_ACCEPTED
  → QUOTATION_REJECTED → [cancelled or re-quoted]
  → ADDITIONAL_APPROVAL_PENDING (if extra work needed)
  → IN_PROGRESS
  → COMPLETED
  → CANCELLED (at valid points)
  → DISPUTED
`

Invalid transitions are rejected by the backend.

## Technician Verification States

`
PENDING → UNDER_REVIEW → VERIFIED
                       → REJECTED
VERIFIED → SUSPENDED → VERIFIED (restored)
`

Verification wording: "Verified based on submitted and reviewed information."
