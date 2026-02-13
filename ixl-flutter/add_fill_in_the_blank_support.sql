-- ====================================================================
-- ADDING FILL-IN-THE-BLANK SUPPORT
-- ====================================================================

-- 1. DROP Constraint to allow 'fillInTheBlank' type
ALTER TABLE questions DROP CONSTRAINT IF EXISTS questions_type_check;
ALTER TABLE questions ADD CONSTRAINT questions_type_check CHECK (type IN ('mcq', 'textInput', 'sorting', 'dragAndDrop', 'fillInTheBlank'));

-- 2. Verify column usage
-- fillInTheBlank questions rely on:
--  - 'parts' (JSONB) for the sequence structure with inline inputs
--  - 'correct_answer_text' (TEXT/JSON) for the key-value map of correct answers (e.g. '{"b1": "400"}')
-- No new columns needed.
