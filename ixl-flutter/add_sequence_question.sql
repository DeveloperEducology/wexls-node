-- ====================================================================
-- ADDING FILL-IN-THE-BLANK SEQUENCE QUESTION
-- ====================================================================

INSERT INTO questions (micro_skill_id, type, parts, correct_answer_text, solution, difficulty) VALUES 
(
    '99999999-9999-9999-9999-999999999999', -- Reusing "Sort Vowel Sounds" skill for demo
    'fillInTheBlank',
    
    -- Question Parts
    '[
      {"type": "text", "content": "Type the missing numbers in the sequence."},
      {
        "type": "sequence", 
        "children": [
           {"type": "text", "content": "100, 200, 300, "},
           {"type": "input", "id": "b1"},
           {"type": "text", "content": ", "},
           {"type": "input", "id": "b2"},
           {"type": "text", "content": ", 600, "},
           {"type": "input", "id": "b3"}
        ]
      }
    ]'::jsonb,

    -- Correct Answer (JSON)
    '{"b1": "400", "b2": "500", "b3": "700"}',

    'Count by 100s. 300 + 100 = 400. 400 + 100 = 500.',
    'medium'
);
