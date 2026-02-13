-- =================================================================================
-- ADAPTIVE QUESTIONS BATCH: MATH (ADDITION)
-- Skill ID placeholder: 'b74172ec-421b-4901-b1a6-388d3db61f87'
-- Demonstrating progression from Complexity 10 -> 80
-- =================================================================================

INSERT INTO questions (
    micro_skill_id, type, parts, options, correct_answer_index, difficulty, marks, sub_topic, complexity
) VALUES 

-- LEVEL 1: VISUAL COUNTING (Complexity: 10)
-- Just count the objects. No "math symbols" yet.
(
    'b74172ec-421b-4901-b1a6-388d3db61f87', 
    'mcq', 
    '[{"type": "text", "content": "How many apples are there?"}, {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/415/415733.png"}]'::jsonb, 
    '["1", "2", "3"]'::jsonb, 
    0, 
    'easy', 
    1, 
    'visual_counting', 
    10
),

-- LEVEL 2: BASIC SYMBOLS (Complexity: 30)
-- Introduce the "+" sign with pictures.
(
    'b74172ec-421b-4901-b1a6-388d3db61f87', 
    'mcq', 
    '[
        {"type": "text", "content": "Add."}
    ]'::jsonb, 
    '["2", "3", "4"]'::jsonb, 
    0, 
    'easy', 
    1, 
    'simple_addition', 
    30
),

-- LEVEL 3: NUMBER LINE (Complexity: 50)
-- Abstracting away from "objects" to "positions".
(
    'b74172ec-421b-4901-b1a6-388d3db61f87', 
    'mcq', 
    '[{"type": "text", "content": "Start at 3. Jump forward 2 spaces. Where are you?"}]'::jsonb, 
    '["4", "5", "6"]'::jsonb, 
    1, 
    'medium', 
    1, 
    'number_line', 
    50
),

-- LEVEL 4: MISSING ADDEND (Complexity: 70)
-- Algebra thinking. "3 + ? = 5"
(
    'b74172ec-421b-4901-b1a6-388d3db61f87', 
    'fillInTheBlank', 
    '[{"type": "text", "content": "3 + "}, {"type": "input", "id": "ans"}, {"type": "text", "content": " = 5"}]'::jsonb, 
    '[]'::jsonb, 
    -1, 
    'medium', 
    1, 
    'missing_addend', 
    70
),

-- LEVEL 5: WORD PROBLEM (Complexity: 90)
-- Reading + Math + multi-step logic.
(
    'b74172ec-421b-4901-b1a6-388d3db61f87', 
    'mcq', 
    '[{"type": "text", "content": "Sam has 2 cats. He adopts 1 more. Then 1 cat runs away. How many cats does Sam have now?"}]'::jsonb, 
    '["2", "3", "4"]'::jsonb, 
    0, 
    'hard', 
    1, 
    'multi_step_word_problem', 
    90
);
