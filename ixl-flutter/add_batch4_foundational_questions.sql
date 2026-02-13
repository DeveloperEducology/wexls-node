-- =================================================================================
-- BATCH 4: FOUNDATIONAL ADAPTIVE QUESTIONS (ADDITION)
-- Skill ID: a392e3cc-14fb-4135-a8a2-f88218b819d9
-- 20 Questions focusing on LOWER COMPLEXITY (5-30) to fix the "Cold Start" gap.
-- =================================================================================

INSERT INTO questions (
    micro_skill_id, type, parts, options, correct_answer_index, correct_answer_text, solution, difficulty, marks, sub_topic, complexity
) VALUES 

-- [COMPLEXITY 5-10] PURE COUNTING (Very Easy)
-- 1. Count One
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 'mcq', 
    '[{"type": "text", "content": "How many suns?"}, {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/869/869869.png", "width": 50}]'::jsonb, 
    '["1", "2"]'::jsonb, 0, null, 'There is 1 sun.', 'easy', 1, 'visual_counting', 5
),
-- 2. Count Two
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 'mcq', 
    '[{"type": "text", "content": "Count the ducks."}, {"type": "sequence", "children": [{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/3069/3069172.png", "width": 40},{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/3069/3069172.png", "width": 40}]}]'::jsonb, 
    '["1", "2", "3"]'::jsonb, 1, null, 'One, Two. There are 2 ducks.', 'easy', 1, 'visual_counting', 5
),
-- 3. Count Three
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 'mcq', 
    '[{"type": "text", "content": "How many flowers?"}, {"type": "sequence", "children": [{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/346/346167.png", "width": 40},{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/346/346167.png", "width": 40},{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/346/346167.png", "width": 40}]}]'::jsonb, 
    '["2", "3", "4"]'::jsonb, 1, null, '1, 2, 3 flowers.', 'easy', 1, 'visual_counting', 10
),
-- 4. Count Four
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 'mcq', 
    '[{"type": "text", "content": "How many cars?"}, {"type": "sequence", "children": [{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/741/741407.png", "width": 40},{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/741/741407.png", "width": 40},{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/741/741407.png", "width": 40},{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/741/741407.png", "width": 40}]}]'::jsonb, 
    '["3", "4", "5"]'::jsonb, 1, null, 'Count them: 1, 2, 3, 4.', 'easy', 1, 'visual_counting', 10
),


-- [COMPLEXITY 15-20] VISUAL ADDITION ("And one more")
-- 5. 1 + 1 (Fingers)
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 'mcq', 
    '[{"type": "text", "content": "1 finger + 1 finger = ?"}, {"type": "sequence", "children": [{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/57/57523.png", "width": 30},{"type": "text", "content": "+"},{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/57/57523.png", "width": 30}]}]'::jsonb, 
    '["1", "2"]'::jsonb, 1, null, '1 plus 1 is 2.', 'easy', 1, 'visual_addition', 15
),
-- 6. 2 + 1 (Cookies)
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 'mcq', 
    '[{"type": "text", "content": "2 cookies + 1 cookie = ?"}]'::jsonb, 
    '["2", "3", "4"]'::jsonb, 1, null, '2... and one more is 3.', 'easy', 1, 'visual_addition', 15
),
-- 7. 3 + 1 (Groups)
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 'mcq', 
    '[{"type": "text", "content": "What is 3 + 1?"}, {"type": "sequence", "children": [{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/415/415733.png", "width": 30},{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/415/415733.png", "width": 30},{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/415/415733.png", "width": 30},{"type": "text", "content": "+"},{"type":"image", "imageUrl":"https://cdn-icons-png.flaticon.com/512/415/415733.png", "width": 30}]}]'::jsonb, 
    '["3", "4", "5"]'::jsonb, 1, null, 'Count all apples: 1, 2, 3, 4.', 'easy', 1, 'visual_addition', 20
),
-- 8. 2 + 2 (Visual)
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 'mcq', 
    '[{"type": "text", "content": "Add 2 dots and 2 dots."}]'::jsonb, 
    '["2", "3", "4"]'::jsonb, 2, null, '2 + 2 = 4.', 'easy', 1, 'visual_addition', 20
),


-- [COMPLEXITY 25-30] INTRO TO SYMBOLS (No pictures)
-- 9. 1 + 1 (Text)
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 'mcq', 
    '[{"type": "math", "content": "1 + 1 = ?"}]'::jsonb, 
    '["1", "2"]'::jsonb, 1, null, '1 plus 1 is 2.', 'easy', 1, 'simple_addition', 25
),
-- 10. 1 + 2 (Text)
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 'mcq', 
    '[{"type": "math", "content": "1 + 2 = ?"}]'::jsonb, 
    '["2", "3", "4"]'::jsonb, 1, null, '1 + 2 = 3.', 'easy', 1, 'simple_addition', 25
),
-- 11. 2 + 1 (Text)
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 'mcq', 
    '[{"type": "math", "content": "2 + 1 = ?"}]'::jsonb, 
    '["1", "2", "3"]'::jsonb, 2, null, '2 + 1 = 3.', 'easy', 1, 'simple_addition', 25
),
-- 12. 3 + 0 (Zero concept)
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 'mcq', 
    '[{"type": "math", "content": "3 + 0 = ?"}]'::jsonb, 
    '["0", "3", "30"]'::jsonb, 1, null, 'Adding zero changes nothing.', 'easy', 1, 'simple_addition', 25
),
-- 13. 2 + 3 (Basic)
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 'mcq', 
    '[{"type": "math", "content": "2 + 3 = ?"}]'::jsonb, 
    '["4", "5", "6"]'::jsonb, 1, null, '2 plus 3 makes 5.', 'easy', 1, 'simple_addition', 30
),
-- 14. 4 + 1 (Basic)
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 'mcq', 
    '[{"type": "math", "content": "4 + 1 = ?"}]'::jsonb, 
    '["4", "5", "14"]'::jsonb, 1, null, 'Count up one from 4 to get 5.', 'easy', 1, 'simple_addition', 30
),
-- 15. 5 + 1 (Basic)
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 'mcq', 
    '[{"type": "math", "content": "5 + 1 = ?"}]'::jsonb, 
    '["5", "6", "51"]'::jsonb, 1, null, '5 + 1 = 6.', 'easy', 1, 'simple_addition', 30
),


-- [COMPLEXITY 35-40] NUMBER LINE / STEPS
-- 16. Jump 1
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 'mcq', 
    '[{"type": "text", "content": "Start at 2. Jump 2 forward. Where do you land?"}]'::jsonb, 
    '["3", "4", "5"]'::jsonb, 1, null, '2 + 2 = 4.', 'easy', 1, 'number_line', 35
),
-- 17. Jump 2
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 'mcq', 
    '[{"type": "text", "content": "Start at 6. Add 1. What number is it?"}]'::jsonb, 
    '["5", "6", "7"]'::jsonb, 2, null, '6 + 1 = 7.', 'easy', 1, 'number_line', 35
),
-- 18. Pattern 1
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 'mcq', 
    '[{"type": "text", "content": "1, 2, 3, 4, ... what comes next?"}]'::jsonb, 
    '["5", "6"]'::jsonb, 0, null, 'Adding 1 each time. 4 + 1 = 5.', 'easy', 1, 'pattern_counting', 40
),
-- 19. Fill Blank Easy
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 'textInput', 
    '[{"type": "text", "content": "Fill:"}, {"type": "math", "content": "1 + \\_ = 2"}]'::jsonb, 
    '[]'::jsonb, -1, '1', '1 + 1 = 2.', 'easy', 1, 'missing_addend', 40
),
-- 20. Fill Blank Easy
(
    'a392e3cc-14fb-4135-a8a2-f88218b819d9', 'textInput', 
    '[{"type": "text", "content": "Fill:"}, {"type": "math", "content": "3 + \\_ = 5"}]'::jsonb, 
    '[]'::jsonb, -1, '2', '3 + 2 = 5.', 'easy', 1, 'missing_addend', 40
);
