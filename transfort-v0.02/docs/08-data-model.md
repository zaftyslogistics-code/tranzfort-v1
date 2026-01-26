# Data Model (v0.02)

## Strategy Decision (Pending)
Document the choice in this file:
- Option A: reuse existing Supabase tables and migrate
- Option B: reset schema and recreate clean tables

## Core Entities
- User/Profile
- SupplierProfile
- TruckerProfile
- Load
- Chat
- Message
- VerificationRequest

## Invariants
- Role is immutable after onboarding (or strictly audited if changed).
- Verification state changes must be admin-controlled.

## Diagram
- ERD: `diagrams/data-model-erd.mmd`
