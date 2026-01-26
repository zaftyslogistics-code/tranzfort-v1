# Testing & Quality Gates (v0.02)

## Objective
Make quality measurable so the client is confident and we get paid.

## Quality Gates (Definition of Done)
- No critical errors in logs for core flows.
- Performance targets met (`10-performance-startup.md`).
- Security checks: RLS checklist passed.
- UX: loading/empty/error states implemented.

## Test Types
- Unit tests: domain + data mapping.
- Widget tests: critical UI states.
- Integration tests: auth, post load, feed, chat, verification.

## Manual QA Checklist (per release)
- Install fresh
- Login/logout
- Supplier: post load
- Trucker: browse feed
- Chat send/receive
- Verification request + admin review

## RLS Testing
- Attempt to update restricted fields as normal user.
- Ensure admin-only fields are protected.
