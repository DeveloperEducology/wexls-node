-- ====================================================================
-- ADDING SINGLE-INPUT IMAGE QUESTION (CORRECTED)
-- ====================================================================

INSERT INTO questions (micro_skill_id, type, parts, correct_answer_text, solution, difficulty) VALUES 
(
    '99999999-9999-9999-9999-999999999999',  -- Reusing "Sort Vowel Sounds" ID for demo
    'fillInTheBlank',
    
    -- Question Parts: Instruction -> Image -> Single Input
    -- NOTE: 'imageUrl' is the correct key for images, NOT 'url'.
    '[
      {"type": "text", "content": "How many blocks are shown in the image below?"},
      {"type": "image", "imageUrl": "https://www.hand2mind.com/media/amasty/blog/cache/8/5/900/500/85220_H2-web.jpg"},
      {"type": "input", "id": "answer_1"}
    ]'::jsonb,

    -- Correct Answer
    '{"answer_1": "400"}',

    -- Solution
    'There are 4 blocks of one hundred. 4 * 100 = 400.',
    'easy'
);
