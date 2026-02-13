-- ====================================================================
-- ADDING MORE QUESTIONS TO EXISTING SKILLS
-- ====================================================================

-- 1. ADDITIONS FOR SKILL A.1 (Counting Objects) ID: 55555555-5555-5555-5555-555555555551
INSERT INTO questions (micro_skill_id, type, parts, options, correct_answer_index, solution, difficulty) VALUES 
-- Q1: Count Apples
(
    '55555555-5555-5555-5555-555555555551',
    'mcq',
    '[
        {"type": "text", "content": "How many apples do you see?"},
        {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/415/415733.png", "height": 80},
        {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/415/415733.png", "height": 80}
    ]'::jsonb,
    '["1", "2", "3", "4"]'::jsonb,
    1, -- Answer: 2
    'Count the apples: One, Two.',
    'easy'
),
-- Q2: Count Stars
(
    '55555555-5555-5555-5555-555555555551',
    'mcq',
    '[
        {"type": "text", "content": "Count the stars."},
        {"type": "text", "content": "⭐ ⭐ ⭐ ⭐"} 
    ]'::jsonb,
    '["3", "4", "5", "6"]'::jsonb,
    1, -- Answer: 4
    'There are four stars in the row.',
    'easy'
);


-- 2. ADDITIONS FOR SKILL A.2 (Skip-Counting) ID: 55555555-5555-5555-5555-555555555552
INSERT INTO questions (micro_skill_id, type, parts, correct_answer_text, solution, difficulty) VALUES 
-- Q1: Skip by 2s
(
    '55555555-5555-5555-5555-555555555552',
    'textInput',
    '[
        {"type": "text", "content": "Skip-counting by 2s."},
        {"type": "math", "content": "2, 4, 6, \\_"} 
    ]'::jsonb,
    '8',
    'Add 2 to the last number: 6 + 2 = 8.',
    'easy'
),
-- Q2: Skip by 10s
(
    '55555555-5555-5555-5555-555555555552',
    'textInput',
    '[
        {"type": "text", "content": "Skip-counting by 10s."},
        {"type": "math", "content": "10, 20, 30, \\_"} 
    ]'::jsonb,
    '40',
    'Count by tens: 10, 20, 30, and then 40.',
    'easy'
);


-- 3. ADDITIONS FOR SKILL A.3 (Comparison) ID: 55555555-5555-5555-5555-555555555553
INSERT INTO questions (micro_skill_id, type, parts, options, correct_answer_index, solution, difficulty) VALUES 
-- Q1: Smaller Number
(
    '55555555-5555-5555-5555-555555555553',
    'mcq',
    '[{"type": "text", "content": "Which number is smaller?"}]'::jsonb,
    '["9", "15", "20", "8"]'::jsonb,
    3, -- Answer: 8
    '8 is the smallest single digit number here.',
    'easy'
),
-- Q2: Greatest Number
(
    '55555555-5555-5555-5555-555555555553',
    'mcq',
    '[{"type": "text", "content": "Which number is the greatest?"}]'::jsonb,
    '["50", "12", "99", "34"]'::jsonb,
    2, -- Answer: 99
    '99 has the most tens (9 tens).',
    'medium'
);
