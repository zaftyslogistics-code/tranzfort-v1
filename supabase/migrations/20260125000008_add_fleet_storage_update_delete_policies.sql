-- Add UPDATE and DELETE policies for fleet-documents storage bucket
-- Allows truck owners to update/delete their own fleet documents

-- Policy: Transporters can update their own truck documents
DROP POLICY IF EXISTS "Transporters can update fleet documents" ON storage.objects;
CREATE POLICY "Transporters can update fleet documents"
  ON storage.objects
  FOR UPDATE
  USING (
    bucket_id = 'fleet-documents'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Policy: Transporters can delete their own truck documents
DROP POLICY IF EXISTS "Transporters can delete fleet documents" ON storage.objects;
CREATE POLICY "Transporters can delete fleet documents"
  ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'fleet-documents'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

DO $$
BEGIN
  BEGIN
    COMMENT ON POLICY "Transporters can update fleet documents" ON storage.objects
      IS 'Allows truck owners to update their fleet document uploads';
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
  END;

  BEGIN
    COMMENT ON POLICY "Transporters can delete fleet documents" ON storage.objects
      IS 'Allows truck owners to delete their fleet document uploads';
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
  END;
END $$;
