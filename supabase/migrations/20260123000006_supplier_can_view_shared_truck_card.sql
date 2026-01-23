-- Allow suppliers to view shared truck card details once a truck is selected for a deal

DROP POLICY IF EXISTS "Suppliers can view selected deal trucks" ON public.trucks;
CREATE POLICY "Suppliers can view selected deal trucks"
  ON public.trucks
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM public.deal_truck_shares d
      WHERE d.supplier_id = auth.uid()
        AND d.truck_id = public.trucks.id
    )
  );
