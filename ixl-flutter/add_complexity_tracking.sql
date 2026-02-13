-- Add 'target_complexity' to practice_sessions or create a progress tracking table
-- Currently we are inserting into 'practice_sessions' which acts as a log.
-- We will add the column there for now.

ALTER TABLE practice_sessions 
ADD COLUMN IF NOT EXISTS target_complexity INTEGER DEFAULT 10;

-- Optional: Create a view or a separate table for 'current_skill_status' if needed later.
-- For now, fetching the *latest* session for a skill will give us the resume point.
