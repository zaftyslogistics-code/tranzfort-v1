# Scope & Requirements (v0.02)

## Roles
- Supplier
- Trucker
- Admin

## Functional Requirements (MVP v0.02)
- Authentication: email/password + session management.
- Role onboarding: supplier/trucker role selection and profile completion.
- Supplier: post load, manage loads, view responses.
- Trucker: feed of loads, express interest/contact, chat.
- Verification: user verification request + admin review workflow.
- Chat: supplier <-> trucker messaging.
- Admin: dashboard metrics, verify users, manage critical entities.

## Non-Functional Requirements
- Performance: defined in `10-performance-startup.md`.
- Security: defined in `11-security-rls.md`.
- Reliability: clear error states, retry strategies, offline-tolerant UX for read paths.
- Maintainability: architecture boundaries + naming conventions.

## Acceptance Criteria
- Each feature must have:
  - defined UX flow
  - API contract
  - error states
  - test coverage expectations
