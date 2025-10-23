-- Migration: Add admin policy for invoices table
-- Allows admin users to view all invoices in the Finance Management page

-- Drop existing policy if it exists (for idempotency)
DROP POLICY IF EXISTS "Admins can view all invoices" ON public.invoices;

-- Create policy allowing admins to SELECT all invoices
CREATE POLICY "Admins can view all invoices" 
ON public.invoices
FOR SELECT 
USING (public.is_admin(auth.uid()));

-- Grant SELECT permission to authenticated users (RLS will handle the actual filtering)
GRANT SELECT ON public.invoices TO authenticated;

