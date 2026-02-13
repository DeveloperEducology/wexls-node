-- ====================================================================
-- MORE IMAGE-BASED QUESTIONS
-- ====================================================================

-- 1. COUNT THE CARS (Simple counting)
INSERT INTO questions (micro_skill_id, type, parts, correct_answer_text, solution, difficulty) VALUES 
(
    '99999999-9999-9999-9999-999999999999', 
    'fillInTheBlank',
    '[
      {"type": "text", "content": "How many cars are there?"},
      
      {
        "type": "sequence",
        "children": [
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/3202/3202926.png", "height": 80},
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/3202/3202926.png", "height": 80},
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/3202/3202926.png", "height": 80},
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/3202/3202926.png", "height": 80}
        ]
      },
      
      {"type": "input", "id": "ans"}
    ]'::jsonb,
    '{"ans": "4"}',
    'Count the cars: 1, 2, 3, 4.',
    'easy'
);

-- 2. VISUAL ADDITION (Cats)
INSERT INTO questions (micro_skill_id, type, parts, correct_answer_text, solution, difficulty) VALUES 
(
    '99999999-9999-9999-9999-999999999999', 
    'fillInTheBlank',
    '[
      {"type": "text", "content": "Add the cats together."},
      
      {
        "type": "sequence",
        "children": [
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/616/616430.png", "height": 70},
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/616/616430.png", "height": 70},
           
           {"type": "text", "content": " + "},
           
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/616/616430.png", "height": 70},
           
           {"type": "text", "content": " = "},
           
           {"type": "input", "id": "sum"}
        ]
      }
    ]'::jsonb,
    '{"sum": "3"}',
    '2 cats plus 1 cat equals 3 cats.',
    'easy'
);
