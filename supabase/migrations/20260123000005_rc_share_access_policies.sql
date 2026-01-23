-- Allow suppliers to access RC documents only after trucker approval

-- 1) Allow suppliers to SELECT truck rows for shared deals (approved only)
DROP POLICY IF EXISTS "Suppliers can view shared trucks" ON public.trucks;
CREATE POLICY "Suppliers can view shared trucks"
  ON public.trucks
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM public.deal_truck_shares d
      WHERE d.supplier_id = auth.uid()
        AND d.truck_id = public.trucks.id
        AND d.rc_share_status = 'approved'
    )
  );

-- 2) Allow suppliers to SELECT fleet-documents storage objects for approved shares
DROP POLICY IF EXISTS "Suppliers can view shared fleet documents" ON storage.objects;
CREATE POLICY "Suppliers can view shared fleet documents"
  ON storage.objects
  FOR SELECT
  USING (
    bucket_id = 'fleet-documents'
    AND EXISTS (
      SELECT 1
      FROM public.deal_truck_shares d
      WHERE d.supplier_id = auth.uid()
        AND d.rc_share_status = 'approved'
        AND d.truck_id::text = (storage.foldername(name))[2]
    )
  );
