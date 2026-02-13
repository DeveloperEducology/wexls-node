-- ====================================================================
-- ADDING 4 PICS 1 WORD QUESTIONS
-- ====================================================================

-- 1. ZOO
INSERT INTO questions (micro_skill_id, type, parts, correct_answer_text, solution, difficulty) VALUES 
(
    '99999999-9999-9999-9999-999999999999', 
    'fourPicsOneWord',
    '[
      {"type": "text", "content": "Guess the word!"},
      {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/616/616554.png"},
      {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/616/616430.png"},
      {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/1998/1998610.png"},
      {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/235/235359.png"}
    ]'::jsonb,
    'ZOO',
    'Animals live in a zoo.',
    'easy'
);

-- 2. THINK
INSERT INTO questions (micro_skill_id, type, parts, correct_answer_text, solution, difficulty) VALUES 
(
    '99999999-9999-9999-9999-999999999999', 
    'fourPicsOneWord',
    '[
      {"type": "text", "content": "What is the action?"},
      {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/3135/3135715.png"},
      {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/1170/1170667.png"},
      {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/616/616490.png"},
      {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/2921/2921222.png"}
    ]'::jsonb,
    'THINK',
    'To use your mind is to think.',
    'medium'
);

-- 3. COLD (Snowman, Ice, Ice Cream, Winter scene)
INSERT INTO questions (micro_skill_id, type, parts, correct_answer_text, solution, difficulty) VALUES 
(
    '99999999-9999-9999-9999-999999999999', 
    'fourPicsOneWord',
    '[
      {"type": "text", "content": "Guess the word!"},
      {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/642/642000.png"},
      {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/2364/2364197.png"},
      {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/938/938063.png"},
      {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/2315/2315377.png"}
    ]'::jsonb,
    'COLD',
    'Ice and snow are cold.',
    'easy'
);
