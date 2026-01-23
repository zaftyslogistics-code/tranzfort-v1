-- Enforce unique chat per (load, supplier, trucker)
-- Note: load_id can be NULL; uniqueness is enforced only when load_id is present.

CREATE UNIQUE INDEX IF NOT EXISTS idx_chats_unique_per_load_participants
ON public.chats (load_id, supplier_id, trucker_id)
WHERE load_id IS NOT NULL;
