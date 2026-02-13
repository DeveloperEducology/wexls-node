-- ====================================================================
-- ADDING 5 MORE VISUAL MATH QUESTIONS
-- ====================================================================

-- 1. ADDITION: APPLES (2 + 3 = 5)
INSERT INTO questions (micro_skill_id, type, parts, correct_answer_text, solution, difficulty) VALUES 
(
    '99999999-9999-9999-9999-999999999999', 
    'fillInTheBlank',
    '[
      {"type": "text", "content": "Add the apples."},
      {
        "type": "sequence",
        "children": [
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/415/415733.png", "height": 60},
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/415/415733.png", "height": 60},
           
           {"type": "text", "content": " + "},
           
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/415/415733.png", "height": 60},
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/415/415733.png", "height": 60},
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/415/415733.png", "height": 60},
           
           {"type": "text", "content": " = "},
           {"type": "input", "id": "ans"}
        ]
      }
    ]'::jsonb,
    '{"ans": "5"}',
    '2 apples + 3 apples = 5 apples.',
    'easy'
);

-- 2. COUNTING: BIRDS (Count 6)
INSERT INTO questions (micro_skill_id, type, parts, correct_answer_text, solution, difficulty) VALUES 
(
    '99999999-9999-9999-9999-999999999999', 
    'fillInTheBlank',
    '[
      {"type": "text", "content": "Count the birds."},
      {
        "type": "sequence",
        "children": [
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/3069/3069172.png", "height": 70},
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/3069/3069172.png", "height": 70},
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/3069/3069172.png", "height": 70},
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/3069/3069172.png", "height": 70},
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/3069/3069172.png", "height": 70},
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/3069/3069172.png", "height": 70}
        ]
      },
      {"type": "input", "id": "ans"}
    ]'::jsonb,
    '{"ans": "6"}',
    'There are 6 birds.',
    'easy'
);

-- 3. SUBTRACTION: CARS (4 - 1 = 3)
INSERT INTO questions (micro_skill_id, type, parts, correct_answer_text, solution, difficulty) VALUES 
(
    '99999999-9999-9999-9999-999999999999', 
    'fillInTheBlank',
    '[
      {"type": "text", "content": "Subtract."},
      {
        "type": "sequence",
        "children": [
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/3202/3202926.png", "height": 60},
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/3202/3202926.png", "height": 60},
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/3202/3202926.png", "height": 60},
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/3202/3202926.png", "height": 60},
           
           {"type": "text", "content": " - "},
           
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/3202/3202926.png", "height": 60},
           
           {"type": "text", "content": " = "},
           {"type": "input", "id": "ans"}
        ]
      }
    ]'::jsonb,
    '{"ans": "3"}',
    '4 cars - 1 car = 3 cars.',
    'medium'
);

-- 4. MULTIPLICATION / GROUPS: Pairs of Cherries (3 pairs)
INSERT INTO questions (micro_skill_id, type, parts, correct_answer_text, solution, difficulty) VALUES 
(
    '99999999-9999-9999-9999-999999999999', 
    'fillInTheBlank',
    '[
      {"type": "text", "content": "How many cherries are there? (Count by 2s)"},
      {
        "type": "sequence",
        "children": [
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/1135/1135545.png", "height": 70},
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/1135/1135545.png", "height": 70},
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/1135/1135545.png", "height": 70}
        ]
      },
      {"type": "input", "id": "ans"}
    ]'::jsonb,
    '{"ans": "6"}',
    '2 + 2 + 2 = 6 cherries.',
    'medium'
);

-- 5. SVG COUNTING: Triangles (Count 4)
INSERT INTO questions (micro_skill_id, type, parts, correct_answer_text, solution, difficulty) VALUES 
(
    '99999999-9999-9999-9999-999999999999', 
    'fillInTheBlank',
    '[
      {"type": "text", "content": "How many triangles?"},
      {
        "type": "sequence",
        "children": [
           {"type": "svg", "content": "<svg viewBox=\"0 0 100 100\" xmlns=\"http://www.w3.org/2000/svg\"><polygon points=\"50,15 90,85 10,85\" fill=\"#00BCD4\"/></svg>", "height": 70},
           {"type": "svg", "content": "<svg viewBox=\"0 0 100 100\" xmlns=\"http://www.w3.org/2000/svg\"><polygon points=\"50,15 90,85 10,85\" fill=\"#00BCD4\"/></svg>", "height": 70},
           {"type": "svg", "content": "<svg viewBox=\"0 0 100 100\" xmlns=\"http://www.w3.org/2000/svg\"><polygon points=\"50,15 90,85 10,85\" fill=\"#00BCD4\"/></svg>", "height": 70},
           {"type": "svg", "content": "<svg viewBox=\"0 0 100 100\" xmlns=\"http://www.w3.org/2000/svg\"><polygon points=\"50,15 90,85 10,85\" fill=\"#00BCD4\"/></svg>", "height": 70}
        ]
      },
      {"type": "input", "id": "ans"}
    ]'::jsonb,
    '{"ans": "4"}',
    'There are 4 blue triangles.',
    'easy'
);
