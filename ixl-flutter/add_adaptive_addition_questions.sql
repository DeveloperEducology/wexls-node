-- =================================================================================
-- ADAPTIVE QUESTIONS BATCH: ADDITION (Micro Skill: a392e3cc-14fb-4135-a8a2-f88218b819d9)
-- 10 Questions ranging from Complexity 5 to 95
-- PROGRESSION: Counting -> Simple Sums -> Number Line -> Vertical Math -> Word Problems
-- =================================================================================

INSERT INTO questions (
    micro_skill_id, type, parts, options, correct_answer_index, correct_answer_text, solution, difficulty, marks, sub_topic, complexity
) VALUES 

-- [05] VISUAL: Count Objects (Shapes)
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "text", "content": "How many stars are there?"}, {"type": "sequence", "children": [{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/1828/1828884.png", "width": 40},{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/1828/1828884.png", "width": 40}]}]'::jsonb, 
    '["1", "2", "3"]'::jsonb, 
    1, -- 2
    null,
    'Count them: One, Two. There are 2 stars.',
    'easy', 
    1, 
    'visual_counting', 
    5
),

-- [15] VISUAL: Add Two Groups (Images)
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "text", "content": "Add the apples."}, {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/415/415733.png", "width": 40}, {"type": "text", "content": "+"}, {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/415/415733.png", "width": 40}, {"type": "text", "content": "="}]'::jsonb, 
    '["1", "2", "3"]'::jsonb, 
    1, -- 1 + 1 = 2
    null,
    '1 apple plus 1 apple equals 2 apples.',
    'easy', 
    1, 
    'visual_addition', 
    15
),

-- [25] SYMBOLIC: Basic Single Digit (Direct)
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "math", "content": "2 + 3 = ?"}]'::jsonb, 
    '["4", "5", "6"]'::jsonb, 
    1, -- 5
    null,
    'Start at 2. Count up 3 more: 3, 4, 5.',
    'easy', 
    1, 
    'single_digit_addition', 
    25
),

-- [35] CONCEPT: Number Line (Visual Aid)
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "text", "content": "Start at 4 on the number line. Jump forward 2 steps. What number do you land on?"}]'::jsonb, 
    '["5", "6", "7"]'::jsonb, 
    1, -- 6
    null,
    '4 + 2 = 6.',
    'easy', 
    1, 
    'number_line', 
    35
),

-- [45] SYMBOLIC: Missing Addend (Lower range)
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'textInput', 
    '[{"type": "text", "content": "Fill in the missing number:"}, {"type": "math", "content": "5 + \\_ = 8"}]'::jsonb, 
    '[]'::jsonb, 
    -1, 
    '3',
    'Think: What number added to 5 makes 8? 5 + 3 = 8.',
    'medium', 
    1, 
    'missing_addend', 
    45
),

-- [55] SYMBOLIC: Adding Zero/Identities
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "math", "content": "7 + 0 = ?"}]'::jsonb, 
    '["0", "7", "70"]'::jsonb, 
    1, -- 7
    null,
    'Adding zero to a number does not change it.',
    'medium', 
    1, 
    'addition_properties', 
    55
),

-- [65] SYMBOLIC: Doubles (Strategy)
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "math", "content": "6 + 6 = ?"}]'::jsonb, 
    '["10", "12", "14"]'::jsonb, 
    1, -- 12
    null,
    'This is a doubles fact. 6 plus 6 equals 12.',
    'medium', 
    1, 
    'doubles_facts', 
    65
),

-- [75] SYMBOLIC: Vertical Addition (Format)
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'textInput', 
    '[{"type": "text", "content": "Add:"}, {"type": "math", "content": "\\begin{matrix} & 8 \\\\ + & 4 \\\\ \\hline & ? \\end{matrix}"}]'::jsonb, 
    '[]'::jsonb, 
    -1, 
    '12', -- Correct text
    '8 + 4 = 12.',
    'medium', 
    1, 
    'vertical_addition', 
    75
),

-- [85] WORD PROBLEM: Simple (Scenario)
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "text", "content": "Tom has 5 toy cars. He buys 4 more. How many cars does he have in total?"}]'::jsonb, 
    '["8", "9", "10"]'::jsonb, 
    1, -- 9
    null,
    '5 cars + 4 cars = 9 cars.',
    'hard', 
    1, 
    'word_problem_simple', 
    85
),

-- [95] WORD PROBLEM: Logic/Multi-step (Challenge)
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "text", "content": "A bus has 3 people. At the first stop, 2 people get on. At the second stop, 2 more get on. How many people are on the bus now?"}]'::jsonb, 
    '["5", "6", "7"]'::jsonb, 
    2, -- 7
    null,
    'Start: 3. First stop: 3 + 2 = 5. Second stop: 5 + 2 = 7.',
    'hard', 
    1, 
    'word_problem_complex', 
    95
);
