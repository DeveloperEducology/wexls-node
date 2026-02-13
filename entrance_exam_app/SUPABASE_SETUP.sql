-- Run this in your Supabase SQL Editor to add the missing column for storing multiple categories

ALTER TABLE profiles 
ADD COLUMN exam_categories text[] DEFAULT '{}';

-- OR if you prefer JSONB to store more details
-- ALTER TABLE profiles ADD COLUMN exam_categories jsonb DEFAULT '[]';
