-- Secure notification creation via RPCs (SECURITY DEFINER)
-- Avoids broad INSERT policies on public.notifications.

-- Notify other participant(s) when a chat message is sent
CREATE OR REPLACE FUNCTION public.notify_chat_message(
  p_chat_id uuid,
  p_message_preview text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_chat record;
  v_sender uuid;
  v_recipient uuid;
BEGIN
  v_sender := auth.uid();
  IF v_sender IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT id, load_id, supplier_id, trucker_id
  INTO v_chat
  FROM public.chats
  WHERE id = p_chat_id;

  IF v_chat.id IS NULL THEN
    RAISE EXCEPTION 'Chat not found';
  END IF;

  IF v_sender <> v_chat.supplier_id AND v_sender <> v_chat.trucker_id THEN
    RAISE EXCEPTION 'Not authorized for this chat';
  END IF;

  v_recipient := CASE
    WHEN v_sender = v_chat.supplier_id THEN v_chat.trucker_id
    ELSE v_chat.supplier_id
  END;

  INSERT INTO public.notifications (
    user_id,
    notification_type,
    title,
    message,
    related_entity_type,
    related_entity_id
  ) VALUES (
    v_recipient,
    'chat_message',
    'New message',
    COALESCE(p_message_preview, ''),
    'chat',
    v_chat.id
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.notify_chat_message(uuid, text) TO authenticated;

-- Notify supplier when an offer is created (trucker action)
CREATE OR REPLACE FUNCTION public.notify_offer_created(
  p_offer_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_offer record;
  v_sender uuid;
BEGIN
  v_sender := auth.uid();
  IF v_sender IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT id, load_id, supplier_id, trucker_id
  INTO v_offer
  FROM public.load_offers
  WHERE id = p_offer_id;

  IF v_offer.id IS NULL THEN
    RAISE EXCEPTION 'Offer not found';
  END IF;

  IF v_sender <> v_offer.trucker_id THEN
    RAISE EXCEPTION 'Not authorized to notify for this offer';
  END IF;

  INSERT INTO public.notifications (
    user_id,
    notification_type,
    title,
    message,
    related_entity_type,
    related_entity_id
  ) VALUES (
    v_offer.supplier_id,
    'offer_received',
    'New offer received',
    'A trucker has sent you an offer.',
    'offer',
    v_offer.id
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.notify_offer_created(uuid) TO authenticated;

-- Notify trucker when an offer is accepted (supplier action)
CREATE OR REPLACE FUNCTION public.notify_offer_accepted(
  p_offer_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_offer record;
  v_sender uuid;
BEGIN
  v_sender := auth.uid();
  IF v_sender IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT id, load_id, supplier_id, trucker_id
  INTO v_offer
  FROM public.load_offers
  WHERE id = p_offer_id;

  IF v_offer.id IS NULL THEN
    RAISE EXCEPTION 'Offer not found';
  END IF;

  IF v_sender <> v_offer.supplier_id THEN
    RAISE EXCEPTION 'Not authorized to notify for this offer';
  END IF;

  INSERT INTO public.notifications (
    user_id,
    notification_type,
    title,
    message,
    related_entity_type,
    related_entity_id
  ) VALUES (
    v_offer.trucker_id,
    'offer_accepted',
    'Offer accepted',
    'Your offer was accepted.',
    'offer',
    v_offer.id
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.notify_offer_accepted(uuid) TO authenticated;

-- Notify trucker when RC is requested (supplier action)
CREATE OR REPLACE FUNCTION public.notify_rc_requested(
  p_deal_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_deal record;
  v_sender uuid;
BEGIN
  v_sender := auth.uid();
  IF v_sender IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT id, load_id, supplier_id, trucker_id
  INTO v_deal
  FROM public.deal_truck_shares
  WHERE id = p_deal_id;

  IF v_deal.id IS NULL THEN
    RAISE EXCEPTION 'Deal not found';
  END IF;

  IF v_sender <> v_deal.supplier_id THEN
    RAISE EXCEPTION 'Not authorized to notify for this deal';
  END IF;

  INSERT INTO public.notifications (
    user_id,
    notification_type,
    title,
    message,
    related_entity_type,
    related_entity_id
  ) VALUES (
    v_deal.trucker_id,
    'rc_requested',
    'RC requested',
    'Supplier requested your RC. You can approve in chat.',
    'deal',
    v_deal.id
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.notify_rc_requested(uuid) TO authenticated;

-- Notify supplier when RC is approved (trucker action)
CREATE OR REPLACE FUNCTION public.notify_rc_approved(
  p_deal_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_deal record;
  v_sender uuid;
BEGIN
  v_sender := auth.uid();
  IF v_sender IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT id, load_id, supplier_id, trucker_id
  INTO v_deal
  FROM public.deal_truck_shares
  WHERE id = p_deal_id;

  IF v_deal.id IS NULL THEN
    RAISE EXCEPTION 'Deal not found';
  END IF;

  IF v_sender <> v_deal.trucker_id THEN
    RAISE EXCEPTION 'Not authorized to notify for this deal';
  END IF;

  INSERT INTO public.notifications (
    user_id,
    notification_type,
    title,
    message,
    related_entity_type,
    related_entity_id
  ) VALUES (
    v_deal.supplier_id,
    'rc_approved',
    'RC approved',
    'Trucker approved RC sharing. You can view it in chat.',
    'deal',
    v_deal.id
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.notify_rc_approved(uuid) TO authenticated;
