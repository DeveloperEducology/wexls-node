-- =================================================================================
-- MORE ADAPTIVE QUESTIONS: ADDITION (Micro Skill: a392e3cc-14fb-4135-a8a2-f88218b819d9)
-- 15 Additional Questions filling gaps in Complexity 5 to 95
-- Focus: More practice at each level to prevent rapid repetition
-- =================================================================================

INSERT INTO questions (
    micro_skill_id, type, parts, options, correct_answer_index, correct_answer_text, solution, difficulty, marks, sub_topic, complexity
) VALUES 

-- [10] VISUAL: Count Objects (Fruits)
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "text", "content": "How many bananas?"}, {"type": "sequence", "children": [{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/2909/2909761.png", "width": 40},{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/2909/2909761.png", "width": 40},{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/2909/2909761.png", "width": 40}]}]'::jsonb, 
    '["2", "3", "4"]'::jsonb, 
    1, -- 3
    null,
    'Count: One, Two, Three. Total 3 bananas.',
    'easy', 
    1, 
    'visual_counting', 
    10
),

-- [15] VISUAL: Add Groups (Cats)
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "text", "content": "Add the cats."}, {"type": "sequence", "children": [{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/616/616408.png", "width": 40},{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/616/616408.png", "width": 40}]}, {"type": "text", "content": "+"}, {"type": "image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/616/616408.png", "width": 40}, {"type": "text", "content": "="}]'::jsonb, 
    '["2", "3", "4"]'::jsonb, 
    1, -- 3
    null,
    '2 cats plus 1 cat makes 3 cats.',
    'easy', 
    1, 
    'visual_addition', 
    15
),

-- [20] VISUAL: Add Groups (Balls)
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "text", "content": "Count all balls."}, {"type": "sequence", "children": [{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/352/352165.png", "width": 30},{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/352/352165.png", "width": 30}]}, {"type": "text", "content": "+"}, {"type": "sequence", "children": [{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/352/352165.png", "width": 30},{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/352/352165.png", "width": 30}]}]'::jsonb, 
    '["2", "4", "6"]'::jsonb, 
    1, -- 4
    null,
    '2 balls plus 2 balls equals 4 balls.',
    'easy', 
    1, 
    'visual_addition', 
    20
),


-- [30] SYMBOLIC: Basic (Direct)
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "math", "content": "1 + 4 = ?"}]'::jsonb, 
    '["4", "5", "6"]'::jsonb, 
    1, -- 5
    null,
    'One plus four is five.',
    'easy', 
    1, 
    'single_digit_addition', 
    30
),

-- [30] SYMBOLIC: Basic (Direct)
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "math", "content": "3 + 3 = ?"}]'::jsonb, 
    '["5", "6", "9"]'::jsonb, 
    1, -- 6
    null,
    '3 plus 3 is 6.',
    'easy', 
    1, 
    'single_digit_addition', 
    30
),

-- [40] CONCEPT: Number Line
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "text", "content": "Start at 5. Jump 1 step forward. Where are you?"}]'::jsonb, 
    '["5", "6", "7"]'::jsonb, 
    1, -- 6
    null,
    '5 + 1 = 6.',
    'easy', 
    1, 
    'number_line', 
    40
),

-- [50] SYMBOLIC: Missing Addend
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'textInput', 
    '[{"type": "text", "content": "Fill the box:"}, {"type": "math", "content": "2 + \\_ = 5"}]'::jsonb, 
    '[]'::jsonb, 
    -1, 
    '3',
    '3 is the missing number because 2 + 3 = 5.',
    'medium', 
    1, 
    'missing_addend', 
    50
),

-- [50] SYMBOLIC: Missing Addend
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'textInput', 
    '[{"type": "text", "content": "Fill:"}, {"type": "math", "content": "\\_ + 4 = 10"}]'::jsonb, 
    '[]'::jsonb, 
    -1, 
    '6',
    '6 + 4 equals 10.',
    'medium', 
    1, 
    'missing_addend', 
    50
),

-- [60] SYMBOLIC: Adding 10s
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "math", "content": "10 + 5 = ?"}]'::jsonb, 
    '["15", "50", "105"]'::jsonb, 
    0, -- 15
    null,
    '1 ten and 5 ones makes 15.',
    'medium', 
    1, 
    'place_value_addition', 
    60
),

-- [70] SYMBOLIC: Doubles + 1
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "math", "content": "6 + 7 = ?"}]'::jsonb, 
    '["12", "13", "14"]'::jsonb, 
    1, -- 13
    null,
    'Use doubles: 6 + 6 = 12, so 6 + 7 is one more, which is 13.',
    'medium', 
    1, 
    'mental_math_strategy', 
    70
),

-- [80] SYMBOLIC: Vertical
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'textInput', 
    '[{"type": "text", "content": "Solve:"}, {"type": "math", "content": "\\begin{matrix} & 12 \\\\ + & 3 \\\\ \\hline & ? \\end{matrix}"}]'::jsonb, 
    '[]'::jsonb, 
    -1, 
    '15',
    '12 + 3 = 15.',
    'medium', 
    1, 
    'vertical_addition', 
    80
),

-- [80] SYMBOLIC: Vertical
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'textInput', 
    '[{"type": "text", "content": "Solve:"}, {"type": "math", "content": "\\begin{matrix} & 15 \\\\ + & 4 \\\\ \\hline & ? \\end{matrix}"}]'::jsonb, 
    '[]'::jsonb, 
    -1, 
    '19',
    '15 + 4 = 19.',
    'medium', 
    1, 
    'vertical_addition', 
    80
),

-- [90] WORD PROBLEM
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "text", "content": "There are 4 birds on a tree. 3 more fly in. How many birds are there now?"}]'::jsonb, 
    '["6", "7", "8"]'::jsonb, 
    1, -- 7
    null,
    '4 + 3 = 7 birds.',
    'hard', 
    1, 
    'word_problem_simple', 
    90
),

-- [95] WORD PROBLEM (Comparison)
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "text", "content": "Ana has 8 stickers. Ben has 2 more stickers than Ana. How many stickers does Ben have?"}]'::jsonb, 
    '["8", "9", "10"]'::jsonb, 
    2, -- 10
    null,
    'Ben has 2 MORE than 8. 8 + 2 = 10.',
    'hard', 
    1, 
    'word_problem_compare', 
    95
),

-- [100] MASTERY: Logic
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 
    'mcq', 
    '[{"type": "text", "content": "Find the odd one out."}]'::jsonb, 
    '[{"text": "2 + 3"}, {"text": "4 + 1"}, {"text": "2 + 2"}]'::jsonb, 
    2, -- 2+2=4. Others are 5.
    null,
    '2+3=5. 4+1=5. But 2+2=4. So 2+2 is the odd one.',
    'hard', 
    1, 
    'math_logic', 
    100
);
