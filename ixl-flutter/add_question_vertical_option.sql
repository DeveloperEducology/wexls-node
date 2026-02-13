-- Add is_vertical column to questions table
ALTER TABLE "public"."questions" ADD COLUMN IF NOT EXISTS "is_vertical" boolean DEFAULT false;
