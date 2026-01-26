# Admin Chat Systems (v0.02) — Support Chat vs Super Load Negotiation

## Goal
Admin must have two distinct chat systems:
1) **Support Chat**: platform customer support (users contacting support agents).
2) **Super Load Negotiation Chat**: admin negotiating deals for Super Loads (admin acting as supplier).

These are not the same product and must remain isolated in:
- Navigation
- Permissions
- Data model
- UI/UX
- Audit logging

---

## 1) Admin Support Chat (Customer Support)

### 1.1 Purpose
Enable Support Agents to:
- Receive and respond to user requests
- Track conversation context
- Escalate to super admin if required

### 1.2 Who uses it
- **User**: initiates support request
- **Support Agent**: primary responder
- **Super Admin**: escalation + oversight

### 1.3 Routes (Admin App)
- Support Inbox (NEW) `/admin/support/inbox`
- Support Thread (NEW) `/admin/support/tickets/:ticketId`
- Support User Profile Quick View (optional) `/admin/support/users/:userId` (or reuse admin user detail)

### 1.4 Routes (User App)
- Support Center (NEW) `/support`
- Create Support Request (NEW) `/support/new`
- My Support Threads (NEW) `/support/tickets`
- Support Thread (NEW) `/support/tickets/:ticketId`

### 1.5 Data Model (recommended)
Create separate tables so it cannot collide with marketplace chat:
- `support_tickets`
  - `id`, `created_by_user_id`, `assigned_admin_id`, `status` (open/pending/closed)
  - `category`, `priority`, `created_at`, `updated_at`
- `support_messages`
  - `id`, `ticket_id`, `sender_user_id` (nullable), `sender_admin_id` (nullable)
  - `content`, `created_at`, `is_read`

RLS:
- User can read/write only their own ticket/messages
- Assigned admin can read/write
- Super admin can read/write

### 1.6 UX Requirements
- Inbox supports: filters (open/closed), search (user id/phone), assignment
- Thread supports: internal notes (admin-only), canned replies, SLA timer (optional)
- Every admin reply is audit logged

---

## 2) Admin Super Load Negotiation Chat

### 2.1 Purpose
Enable super admin to negotiate a Super Load with truckers:
- Chat scoped to a specific load
- Drive Offer → Deal → RC actions

### 2.2 Who uses it
- **Trucker**: chats for a Super Load
- **Super Admin**: responds and finalizes deal

### 2.3 Route strategy (required)
Do NOT reuse the generic user `/chat` route in Admin app.

Routes (Admin App)
- Super Load Chats List (NEW) `/admin/super-loads/:loadId/chats`
- Super Load Chat Thread (NEW) `/admin/super-chat/:chatId`

Routes (User App)
- Existing chat list + chat thread is fine (`/chat-list`, `/chat`) as long as the chat belongs to the load.

### 2.4 Data Model Options

#### Option A (fast): reuse existing marketplace chat tables
- Keep using `chats` and `chat_messages`
- Add a `chat_context` field or infer context from load:
  - `load_id` already exists (good)
  - Admin is supplier because `supplier_id = posted_by_admin_id` for Super Loads

Pros:
- Minimal backend work
- Reuses realtime streams

Cons:
- Harder to enforce that only super admins can reply on Super Load chats
- Harder to keep “support chat” completely separate

#### Option B (cleanest): separate tables for super load negotiation
- `super_load_chats`
- `super_load_messages`

Pros:
- Strong isolation and simplest permissioning

Cons:
- More code + more realtime subscriptions

### 2.5 Permission Rules (non-negotiable)
- Only `super_admin` can send messages in **Super Load Negotiation Chat**.
- Truckers can only participate if they are party to the chat.
- Admin must not be able to message arbitrary users outside a load context.

### 2.6 UX Requirements
- Chat header shows:
  - `SUPER LOAD` badge
  - from/to route
  - status
- Deal panel inside chat:
  - show truck card
  - request/approve/revoke RC
- Primary CTAs:
  - `Make Offer` (trucker)
  - `Accept Offer` / `Counter` (admin)

---

## 3) Summary Decision
- **Support Chat**: separate tables and routes.
- **Super Load Negotiation Chat**: separate routes and strict permissions; data model can be Option A or B.

## Open Decision (you must confirm)
- Super Load negotiation storage:
  - **A** reuse existing `chats/chat_messages`
  - **B** create dedicated `super_load_chats/super_load_messages`
