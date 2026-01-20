-- Create chats + chat_messages tables
-- Ensure UUID extension is available (created in previous migration)

CREATE TABLE IF NOT EXISTS public.chats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  load_id UUID REFERENCES public.loads(id) ON DELETE SET NULL,
  trucker_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  supplier_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  status VARCHAR(20) DEFAULT 'active',
  last_message TEXT,
  last_message_at TIMESTAMP WITH TIME ZONE,
  unread_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chat_id UUID NOT NULL REFERENCES public.chats(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  message_text TEXT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_chats_load_id ON public.chats(load_id);
CREATE INDEX IF NOT EXISTS idx_chats_trucker_id ON public.chats(trucker_id);
CREATE INDEX IF NOT EXISTS idx_chats_supplier_id ON public.chats(supplier_id);
CREATE INDEX IF NOT EXISTS idx_chats_last_message_at ON public.chats(last_message_at);

CREATE INDEX IF NOT EXISTS idx_chat_messages_chat_id ON public.chat_messages(chat_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_sender_id ON public.chat_messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON public.chat_messages(created_at);

-- Trigger: updated_at on chats
DROP TRIGGER IF EXISTS update_chats_updated_at ON public.chats;
CREATE TRIGGER update_chats_updated_at
  BEFORE UPDATE ON public.chats
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Helper function: keep chats preview fields in sync
CREATE OR REPLACE FUNCTION public.update_chat_preview_on_new_message()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.chats
  SET last_message = NEW.message_text,
      last_message_at = NEW.created_at,
      updated_at = NOW()
  WHERE id = NEW.chat_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS update_chat_preview_on_new_message_trigger ON public.chat_messages;
CREATE TRIGGER update_chat_preview_on_new_message_trigger
  AFTER INSERT ON public.chat_messages
  FOR EACH ROW
  EXECUTE FUNCTION public.update_chat_preview_on_new_message();

-- Enable Row Level Security
ALTER TABLE public.chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- RLS policies: chats
DROP POLICY IF EXISTS "Chat participants can view chats" ON public.chats;
CREATE POLICY "Chat participants can view chats"
  ON public.chats
  FOR SELECT
  USING (auth.uid() = trucker_id OR auth.uid() = supplier_id);

DROP POLICY IF EXISTS "Chat participants can create chats" ON public.chats;
CREATE POLICY "Chat participants can create chats"
  ON public.chats
  FOR INSERT
  WITH CHECK (auth.uid() = trucker_id OR auth.uid() = supplier_id);

DROP POLICY IF EXISTS "Chat participants can update chats" ON public.chats;
CREATE POLICY "Chat participants can update chats"
  ON public.chats
  FOR UPDATE
  USING (auth.uid() = trucker_id OR auth.uid() = supplier_id)
  WITH CHECK (auth.uid() = trucker_id OR auth.uid() = supplier_id);

-- RLS policies: chat_messages
DROP POLICY IF EXISTS "Chat participants can view messages" ON public.chat_messages;
CREATE POLICY "Chat participants can view messages"
  ON public.chat_messages
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM public.chats c
      WHERE c.id = chat_id
        AND (auth.uid() = c.trucker_id OR auth.uid() = c.supplier_id)
    )
  );

DROP POLICY IF EXISTS "Chat participants can send messages" ON public.chat_messages;
CREATE POLICY "Chat participants can send messages"
  ON public.chat_messages
  FOR INSERT
  WITH CHECK (
    sender_id = auth.uid()
    AND EXISTS (
      SELECT 1
      FROM public.chats c
      WHERE c.id = chat_id
        AND (auth.uid() = c.trucker_id OR auth.uid() = c.supplier_id)
    )
  );

DROP POLICY IF EXISTS "Chat participants can update messages" ON public.chat_messages;
CREATE POLICY "Chat participants can update messages"
  ON public.chat_messages
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1
      FROM public.chats c
      WHERE c.id = chat_id
        AND (auth.uid() = c.trucker_id OR auth.uid() = c.supplier_id)
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.chats c
      WHERE c.id = chat_id
        AND (auth.uid() = c.trucker_id OR auth.uid() = c.supplier_id)
    )
  );

GRANT ALL ON public.chats TO authenticated;
GRANT ALL ON public.chat_messages TO authenticated;
