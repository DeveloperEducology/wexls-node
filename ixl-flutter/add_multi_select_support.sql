-- Add columns to support multi-select MCQs
ALTER TABLE questions 
ADD COLUMN IF NOT EXISTS is_multi_select BOOLEAN DEFAULT FALSE;

ALTER TABLE questions 
ADD COLUMN IF NOT EXISTS correct_answer_indices JSONB;

-- Example Insert for Multi-Select Question
-- Identify Odd Numbers
INSERT INTO questions (
    micro_skill_id, 
    type, 
    parts, 
    options, 
    is_multi_select, 
    correct_answer_indices, 
    difficulty, 
    solution
) VALUES (
    '06720519-ca11-4377-ad98-0dfd150e56f5', -- Replace with actual Skill ID
    'mcq',
    '[
        {"type": "text", "content": "Select all the odd numbers."}
    ]'::jsonb,
    '[
        "1", 
        "2", 
        "3", 
        "4", 
        "5", 
        "6"
    ]'::jsonb,
    TRUE,
    '[0, 2, 4]'::jsonb, -- Indices for 1, 3, 5
    'easy',
    'Odd numbers are not divisible by 2. The odd numbers here are 1, 3, and 5.'
);
