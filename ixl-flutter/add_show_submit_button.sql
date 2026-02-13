-- Add show_submit_button column to questions table
ALTER TABLE "public"."questions" ADD COLUMN IF NOT EXISTS "show_submit_button" boolean DEFAULT false;
