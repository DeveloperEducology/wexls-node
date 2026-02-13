-- =================================================================================
-- BATCH 3: ADAPTIVE QUESTIONS (ADDITION)
-- Skill ID: a392e3cc-14fb-4135-a8a2-f88218b819d9
-- 20 Questions filling in gaps for Complexity 5-100
-- =================================================================================

INSERT INTO questions (
    micro_skill_id, type, parts, options, correct_answer_index, correct_answer_text, solution, difficulty, marks, sub_topic, complexity
) VALUES 

-- [10] VISUAL: Count Fingers
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "text", "content": "How many fingers?"}, {"type": "sequence", "children": [{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/57/57523.png", "width": 40},{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/57/57523.png", "width": 40},{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/57/57523.png", "width": 40},{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/57/57523.png", "width": 40},{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/57/57523.png", "width": 40}]}]'::jsonb, 
    '["4", "5", "6"]'::jsonb, 
    1, -- 5
    null,
    'Count the fingers: 1, 2, 3, 4, 5.',
    'easy', 
    1, 
    'visual_counting', 
    10
),

-- [20] VISUAL: Dice Addition
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'textInput', 
    '[{"type": "text", "content": "Ad the dots:"}, {"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/9326/9326889.png", "width": 40}, {"type": "text", "content": "+"}, {"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/9326/9326944.png", "width": 40}, {"type": "text", "content": "="}]'::jsonb, 
    '[]'::jsonb, 
    -1, 
    '5', -- 2 + 3 = 5
    '2 dots + 3 dots = 5 dots.',
    'easy', 
    1, 
    'visual_addition', 
    20
),

-- [25] SYMBOLIC: Plus One
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "math", "content": "7 + 1 = ?"}]'::jsonb, 
    '["7", "8", "9"]'::jsonb, 
    1, -- 8
    null,
    'Adding 1 means counting to the next number. After 7 comes 8.',
    'easy', 
    1, 
    'single_digit_addition', 
    25
),

-- [30] SYMBOLIC: Small Sums
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "math", "content": "2 + 2 = ?"}]'::jsonb, 
    '["2", "4", "22"]'::jsonb, 
    1, 
    null,
    '2 plus 2 is 4.',
    'easy', 
    1, 
    'single_digit_addition', 
    30
),

-- [35] CONCEPT: Commutative Property (Visual)
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "text", "content": "2 + 3 is the same as:"}]'::jsonb, 
    '[{"text": "3 + 2"}, {"text": "3 + 3"}, {"text": "2 + 1"}]'::jsonb, 
    0, 
    null,
    'Order does not matter in addition. 2+3 is the same as 3+2.',
    'easy', 
    1, 
    'addition_properties', 
    35
),

-- [40] SYMBOLIC: Fill Blank
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'textInput', 
    '[{"type": "text", "content": "Fill:"}, {"type": "math", "content": "4 + \\_ = 4"}]'::jsonb, 
    '[]'::jsonb, 
    -1, 
    '0',
    'Adding 0 makes no change.',
    'medium', 
    1, 
    'missing_addend', 
    40
),

-- [45] SYMBOLIC: Make 10
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "text", "content": "What makes 10?"}]'::jsonb, 
    '[{"text": "5 + 5"}, {"text": "5 + 4"}, {"text": "5 + 6"}]'::jsonb, 
    0, 
    null,
    '5 plus 5 equals 10.',
    'medium', 
    1, 
    'making_ten', 
    45
),

-- [50] SYMBOLIC: Add 3 Numbers
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'textInput', 
    '[{"type": "text", "content": "Add:"}, {"type": "math", "content": "2 + 2 + 1 = ?"}]'::jsonb, 
    '[]'::jsonb, 
    -1, 
    '5',
    '2+2 is 4. Then 4+1 is 5.',
    'medium', 
    1, 
    'three_number_addition', 
    50
),

-- [55] SYMBOLIC: Add 3 Numbers
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'textInput', 
    '[{"type": "text", "content": "Add:"}, {"type": "math", "content": "5 + 1 + 2 = ?"}]'::jsonb, 
    '[]'::jsonb, 
    -1, 
    '8',
    '5+1 is 6. 6+2 is 8.',
    'medium', 
    1, 
    'three_number_addition', 
    55
),

-- [60] SYMBOLIC: Doubles
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "math", "content": "4 + 4 = ?"}]'::jsonb, 
    '["6", "8", "10"]'::jsonb, 
    1, 
    null,
    'Double 4 is 8.',
    'medium', 
    1, 
    'doubles_facts', 
    60
),

-- [65] SYMBOLIC: Near Doubles
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "math", "content": "4 + 5 = ?"}]'::jsonb, 
    '["8", "9", "10"]'::jsonb, 
    1, 
    null,
    '4+4 is 8. So 4+5 is one more, 9.',
    'medium', 
    1, 
    'mental_math_strategy', 
    65
),

-- [70] SYMBOLIC: Vertical Tens
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'textInput', 
    '[{"type": "text", "content": "Solve:"}, {"type": "math", "content": "\\begin{matrix} & 10 \\\\ + & 10 \\\\ \\hline & ? \\end{matrix}"}]'::jsonb, 
    '[]'::jsonb, 
    -1, 
    '20',
    '10 plus 10 is 20.',
    'medium', 
    1, 
    'vertical_addition', 
    70
),

-- [75] SYMBOLIC: Crossing 10
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "math", "content": "8 + 3 = ?"}]'::jsonb, 
    '["10", "11", "12"]'::jsonb, 
    1, 
    null,
    '8+2 is 10. We have 1 more left. So 11.',
    'medium', 
    1, 
    'crossing_ten', 
    75
),

-- [80] WORD PROBLEM: Simple
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "text", "content": "There are 6 eggs in the fridge. Dad buys 6 more. How many eggs now?"}]'::jsonb, 
    '["66", "12", "10"]'::jsonb, 
    1, 
    null,
    '6 + 6 = 12.',
    'hard', 
    1, 
    'word_problem_simple', 
    80
),

-- [85] WORD PROBLEM: Money
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "text", "content": "You have 5 cents. You find 5 cents. How much do you have?"}]'::jsonb, 
    '["5 cents", "10 cents", "15 cents"]'::jsonb, 
    1, 
    null,
    '5 + 5 = 10 cents.',
    'hard', 
    1, 
    'word_problem_money', 
    85
),

-- [90] WORD PROBLEM: Three Steps
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "text", "content": "Red team scored 2 goals. Blue scored 1 goal. Green scored 3 goals. How many goals in total?"}]'::jsonb, 
    '["5", "6", "7"]'::jsonb, 
    1, 
    null,
    '2 + 1 = 3. Then 3 + 3 = 6.',
    'hard', 
    1, 
    'word_problem_complex', 
    90
),

-- [95] LOGIC: Balance
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'textInput', 
    '[{"type": "text", "content": "Balance the scale:"}, {"type": "math", "content": "5 + 5 = 8 + \\_"}]'::jsonb, 
    '[]'::jsonb, 
    -1, 
    '2',
    'Left side is 10. Right side needs to be 10. 8 + 2 = 10.',
    'hard', 
    1, 
    'algebraic_thinking', 
    95
),

-- [100] MASTERY: Challenge
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "text", "content": "I am a number. If you add 4 to me, I become 8. What number am I?"}]'::jsonb, 
    '["2", "4", "8"]'::jsonb, 
    1, 
    null,
    'If you add 4 to 4, you get 8. So I am 4.',
    'hard', 
    1, 
    'number_riddle', 
    100
),

-- [65] SYMBOLIC: 10 Frame
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "text", "content": "How many more to make 10?"}, {"type": "math", "content": "7 + \\_ = 10"}]'::jsonb, 
    '["2", "3", "4"]'::jsonb, 
    1, 
    null,
    '7 + 3 = 10.',
    'medium', 
    1, 
    'making_ten', 
    65
),

-- [75] SYMBOLIC: Teen Numbers
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "math", "content": "10 + 2 = ?"}]'::jsonb, 
    '["12", "20", "22"]'::jsonb, 
    0, 
    null,
    '10 and 2 makes 12.',
    'medium', 
    1, 
    'place_value_addition', 
    75
);
