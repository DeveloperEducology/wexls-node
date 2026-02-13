-- Add 'skill_name' to practice_sessions for better reporting
ALTER TABLE practice_sessions 
ADD COLUMN IF NOT EXISTS skill_name TEXT;
