-- ====================================================================
-- ADDING COUNTING CHOCOLATES (IMAGE ARRAY) QUESTION
-- ====================================================================

INSERT INTO questions (micro_skill_id, type, parts, correct_answer_text, solution, difficulty) VALUES 
(
    '99999999-9999-9999-9999-999999999999',  -- Reusing "Sort Vowel Sounds" ID for demo
    'fillInTheBlank',
    
    -- Question Parts:
    -- 1. Instruction
    -- 2. Sequence (Array) of 3 Images
    -- 3. Question Text
    -- 4. Input
    '[
      {"type": "text", "content": "Count the chocolates by 10s."},
      
      {
        "type": "sequence",
        "children": [
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/2553/2553691.png", "height": 100},
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/2553/2553691.png", "height": 100},
           {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/2553/2553691.png", "height": 100}
        ]
      },
      
      {"type": "text", "content": "How many chocolates are there?"},
      {"type": "input", "id": "answer_1"}
    ]'::jsonb,

    -- Correct Answer
    '{"answer_1": "30"}',

    -- Solution
    'There are 3 boxes. Each box has 10 chocolates. 10, 20, 30.',
    'medium'
);

-- ====================================================================
-- ADDING SVG ARRAY EXAMPLE
-- ====================================================================
INSERT INTO questions (micro_skill_id, type, parts, correct_answer_text, solution, difficulty) VALUES 
(
    '99999999-9999-9999-9999-999999999999', 
    'fillInTheBlank',
    '[
      {"type": "text", "content": "Count the stars."},
      
      {
        "type": "sequence",
        "children": [
           {"type": "svg", "content": "<svg viewBox=\"0 0 100 100\" xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M50 15 L63 38 L90 41 L70 59 L75 85 L50 73 L25 85 L30 59 L10 41 L37 38 Z\" fill=\"gold\" stroke=\"orange\"/></svg>", "height": 80},
           {"type": "svg", "content": "<svg viewBox=\"0 0 100 100\" xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M50 15 L63 38 L90 41 L70 59 L75 85 L50 73 L25 85 L30 59 L10 41 L37 38 Z\" fill=\"gold\" stroke=\"orange\"/></svg>", "height": 80},
           {"type": "svg", "content": "<svg viewBox=\"0 0 100 100\" xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M50 15 L63 38 L90 41 L70 59 L75 85 L50 73 L25 85 L30 59 L10 41 L37 38 Z\" fill=\"gold\" stroke=\"orange\"/></svg>", "height": 80},
           {"type": "svg", "content": "<svg viewBox=\"0 0 100 100\" xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M50 15 L63 38 L90 41 L70 59 L75 85 L50 73 L25 85 L30 59 L10 41 L37 38 Z\" fill=\"gold\" stroke=\"orange\"/></svg>", "height": 80},
           {"type": "svg", "content": "<svg viewBox=\"0 0 100 100\" xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M50 15 L63 38 L90 41 L70 59 L75 85 L50 73 L25 85 L30 59 L10 41 L37 38 Z\" fill=\"gold\" stroke=\"orange\"/></svg>", "height": 80}
        ]
      },
      
      {"type": "input", "id": "ans"}
    ]'::jsonb,
    '{"ans": "5"}',
    'Count the stars one by one. There are 5 stars.',
    'easy'
);
