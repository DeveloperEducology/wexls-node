-- Add Adaptive Learning Columns to questions table
-- 1. sub_topic: To track granular concepts within a micro-skill (e.g., 'visual_counting' within 'Addition')
-- 2. complexity: A fine-grained difficulty score (0-100) for smoother progression than just easy/medium/hard

ALTER TABLE questions 
ADD COLUMN IF NOT EXISTS sub_topic TEXT,
ADD COLUMN IF NOT EXISTS complexity INTEGER DEFAULT 10;

-- Optional: Create an index on sub_topic for faster filtering if you have many questions
CREATE INDEX IF NOT EXISTS idx_questions_sub_topic ON questions(sub_topic);
