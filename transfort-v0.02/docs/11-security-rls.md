# Security & RLS (v0.02)

## Goals
- Prevent privilege escalation.
- Ensure users cannot update sensitive fields (e.g., verification status).
- Admin actions are auditable.

## RLS Baselines
- All tables: RLS enabled.
- User-owned tables: owner-only write.
- Public feed tables: read-only to authenticated users.

## Admin Controls
- Admin-only actions via restricted functions/RPC.
- Admin role verified server-side.

## Audit & Logging
- Track admin actions: who changed what and when.

## Deliverable
A reviewed policy set and a small RLS test checklist included in `12-testing-quality.md`.
