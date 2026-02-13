-- ====================================================================
-- ADD SUPPORT FOR 'imageChoice'
-- ====================================================================

-- Update constraint
ALTER TABLE questions DROP CONSTRAINT IF EXISTS questions_type_check;
ALTER TABLE questions ADD CONSTRAINT questions_type_check 
CHECK (type IN ('mcq', 'textInput', 'sorting', 'dragAndDrop', 'fillInTheBlank', 'fourPicsOneWord', 'imageChoice'));

-- 1. COFFEE QUESTION (Standard MCQ but styled nicely as requested)
-- Note: User wants "a solid" or "a liquid".
INSERT INTO questions (micro_skill_id, type, parts, options, correct_answer_index, solution, difficulty) VALUES 
(
    '99999999-9999-9999-9999-999999999999', 
    'mcq', -- Using MCQ as the options are text boxes
    '[
      {"type": "text", "content": "Is coffee a solid or a liquid?"},
      {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/751/751621.png", "height": 180}
    ]'::jsonb,
    ARRAY['a solid', 'a liquid'],
    1, -- Index 1 is 'a liquid'
    'Coffee flows and takes the shape of its cup. It is a liquid.',
    'easy'
);

-- 2. COMMUNICATE QUESTION (Image Choice)
INSERT INTO questions (micro_skill_id, type, parts, options, correct_answer_index, solution, difficulty) VALUES 
(
    '99999999-9999-9999-9999-999999999999', 
    'imageChoice', -- New Type
    '[
      {"type": "text", "content": "When we communicate, we send messages."},
      {"type": "text", "content": "Which picture shows a way to communicate \"hello\"?"}
    ]'::jsonb,
    ARRAY[
       'https://img.freepik.com/free-photo/upset-little-girl-showing-thumb-down-gesture_171337-12497.jpg', -- Thumbs down (Sad/Bad)
       'https://img.freepik.com/free-photo/asian-boy-waving-hand-greeting_53876-14636.jpg'             -- Waving (Hello)
    ],
    1, -- The waving boy
    'Waving your hand is a way to say hello without words.',
    'easy'
);
