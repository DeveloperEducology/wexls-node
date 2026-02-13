-- ====================================================================
-- ADDING SENTENCE-STYLE FILL-IN-THE-BLANK QUESTIONS
-- ====================================================================

INSERT INTO questions (micro_skill_id, type, parts, correct_answer_text, solution, difficulty) VALUES 
(
    '99999999-9999-9999-9999-999999999999', -- Reusing "Sort Vowel Sounds" ID for demo visibility
    'fillInTheBlank',
    
    -- We use a single "sequence" part to wrap the text and inputs so they flow inline like a sentence.
    '[
      {
        "type": "sequence", 
        "children": [
          {"type": "text", "content": "To count from 400 to 700 by hundreds, you would say 400, "},
          {"type": "input", "id": "b1"},
          {"type": "text", "content": ", "},
          {"type": "input", "id": "b2"},
          {"type": "text", "content": ", and finally 700."}
        ]
      }
    ]'::jsonb,

    '{"b1": "500", "b2": "600"}',
    'Add 100 to each number: 400 + 100 = 500, and 500 + 100 = 600.',
    'medium'
),
(
    '99999999-9999-9999-9999-999999999999',
    'fillInTheBlank',
    '[
      {
        "type": "sequence", 
        "children": [
            {"type": "text", "content": "The number before 500 is "},
            {"type": "input", "id": "b1"},
            {"type": "text", "content": " and the number after 500 is "},
            {"type": "input", "id": "b2"},
            {"type": "text", "content": " when counting by ones."}
        ]
      }
    ]'::jsonb,
    '{"b1": "499", "b2": "501"}',
    'Subtract 1 to find the number before (499) and add 1 to find the number after (501).',
    'medium'
),
(
    '99999999-9999-9999-9999-999999999999',
    'fillInTheBlank',
    '[
      {
        "type": "sequence", 
        "children": [
            {"type": "text", "content": "If you have 300 apples and buy 100 more, you have "},
            {"type": "input", "id": "b1"},
            {"type": "text", "content": " apples. If you buy another 100, you will have "},
            {"type": "input", "id": "b2"},
            {"type": "text", "content": " apples in total."}
        ]
      }
    ]'::jsonb,
    '{"b1": "400", "b2": "500"}',
    'This is skip-counting by 100: 300, 400, 500.',
    'medium'
);
