# API Contracts (Supabase) (v0.02)

## Principles
- Client accesses data via RLS-protected tables/views.
- Any privileged admin operations should be via restricted RPC or server-side functions.

## Auth
- Sign in/out
- Session refresh

## Loads
- Create load
- Update own load
- List loads (feed)
- Load detail

## Chat
- List chats
- Send message
- Mark as read

## Verification
- Create request
- List pending (admin)
- Approve/deny (admin)

## Contract Format
For each endpoint/table access:
- Input fields
- Output fields
- Error cases
- RLS policy summary
