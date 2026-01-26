# Roles & Permissions (v0.02)

## Principle
Least privilege everywhere. App UI must not expose admin routes to user builds. Backend must enforce permissions with RLS.

## Supplier
- Can create and manage own loads.
- Can chat with truckers for own loads.

## Trucker
- Can view load feed.
- Can initiate chat where permitted.
- Can manage own fleet identity/profile.

## Admin
- Can view system-wide metrics.
- Can review/approve/deny verification.
- Can view high-level load activity.

## Account Strategy
- Single `users/profiles` source of truth with a `role` field, plus explicit admin allowlist/flag.
- Admin UI access requires both:
  - authenticated session
  - server-verified `is_admin = true`

## Enforcement
- UI gating: route guards.
- Server gating: RLS policies + restricted RPCs for admin actions.
