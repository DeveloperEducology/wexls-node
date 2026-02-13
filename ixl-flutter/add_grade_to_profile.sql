-- Add grade_id to profiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS grade_id UUID REFERENCES public.grades(id);

-- Update RLS if needed (Update policy already exists)
