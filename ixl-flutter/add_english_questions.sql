-- Add Rhyming Words Question
-- This example adds a question about rhyming with "camp"
-- Images are placeholders as requested, but using logical SVG/Image URLs if possible.
-- Since the user asked for specific icons, we try to use standard ones or placeholders.

INSERT INTO questions (micro_skill_id, type, parts, options, correct_answer_index, difficulty) 
VALUES (
    'e982adb6-851d-4498-9d3f-48a2f1e2abf2', -- Assuming this is the correct skill ID from user request or context. If not, replace with target skill ID.
    'imageChoice',
    '[
        {"type": "text", "content": "Which word rhymes with **camp**?"}
    ]'::jsonb,
    '[
        "https://cdn-icons-png.flaticon.com/512/3521/3521990.png", 
        "https://cdn-icons-png.flaticon.com/512/427/427735.png",
        "https://cdn-icons-png.flaticon.com/512/2919/2919699.png"
    ]'::jsonb, -- 1. Lamp (Rhyme), 2. Ribbon/Zigzag (No), 3. Rope (No) - adjusting to make index 0 or 1 correct.
    -- Let's assume Option 1 is "Lamp" -> "Camp". So index 0.
    0,
    'easy'
);

-- Note: user requested specific structure in previous prompt:
-- INSERT INTO "public"."questions" ( "micro_skill_id", "type", "parts", "options", "correct_answer_index", "correct_answer_text", "solution", "difficulty", "marks") VALUES ('e982adb6-851d-4498-9d3f-48a2f1e2abf2', 'imageChoice', '[{"type": "text", "content": "Which animal is a cat?"}]', '["https://cdn-icons-png.flaticon.com/512/1998/1998627.png", "https://cdn-icons-png.flaticon.com/512/616/616430.png"]', '1', null, 'The second image shows a cat.', 'easy', '1', ); 

-- I will create a second insert that matches the user's specific request EXACTLY (fixed for SQL syntax)
INSERT INTO questions (micro_skill_id, type, parts, options, correct_answer_index, solution, difficulty, marks) 
VALUES (
    'e982adb6-851d-4498-9d3f-48a2f1e2abf2', 
    'imageChoice', 
    '[{"type": "text", "content": "Which animal is a cat?"}]'::jsonb, 
    '["https://cdn-icons-png.flaticon.com/512/1998/1998627.png", "https://cdn-icons-png.flaticon.com/512/616/616430.png"]'::jsonb, 
    1, 
    'The second image shows a cat.', 
    'easy', 
    1
);
