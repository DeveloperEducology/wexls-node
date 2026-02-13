-- ====================================================================
-- ADDING SORTING SKILL (TYPE: sorting)
-- ====================================================================

-- 1. DROP Constraint to allow 'sorting' type
ALTER TABLE questions DROP CONSTRAINT IF EXISTS questions_type_check;
ALTER TABLE questions ADD CONSTRAINT questions_type_check CHECK (type IN ('mcq', 'textInput', 'sorting'));

-- 2. Add "B. Sorting" Unit to Class II Maths
-- We need IDs. We'll reuse the static UUIDs for Grade(Class II) and Subject(Maths).
-- Grade Class II: '33333333-3333-3333-3333-333333333334'
-- Subject Maths: '11111111-1111-1111-1111-111111111111'

-- Unit ID: 66666666-6666-6666-6666-666666666666
INSERT INTO units (id, grade_id, subject_id, name, code, sort_order) VALUES
(
 '66666666-6666-6666-6666-666666666666', 
 '33333333-3333-3333-3333-333333333334', 
 '11111111-1111-1111-1111-111111111111', 
 'Ordering and sorting', 
 'B', 
 2
);

-- 3. Add Micro Skill "B.1 Order numbers"
-- Skill ID: 77777777-7777-7777-7777-777777777777
INSERT INTO micro_skills (id, unit_id, name, code, sort_order) VALUES
('77777777-7777-7777-7777-777777777777', '66666666-6666-6666-6666-666666666666', 'Order numbers up to 20', 'B.1', 1);

-- 4. Add Sorting Questions
-- Note: 'options' contains the CORRECT ORDER. The app shuffles them.
INSERT INTO questions (micro_skill_id, type, parts, options, solution, difficulty) VALUES 
-- Q1: Sort 1, 2, 3
(
    '77777777-7777-7777-7777-777777777777',
    'sorting',
    '[{"type": "text", "content": "Put these numbers in order from smallest to largest."}]'::jsonb,
    '["1", "2", "3"]'::jsonb, -- Correct Order
    '1 is the smallest, then 2, then 3.',
    'easy'
),
-- Q2: Sort 5, 10, 15
(
    '77777777-7777-7777-7777-777777777777',
    'sorting',
    '[{"type": "text", "content": "Order from smallest to greatest."}]'::jsonb,
    '["5", "10", "15"]'::jsonb,
    'Count by fives: 5, 10, 15.',
    'easy'
),
-- Q3: Sort Random
(
    '77777777-7777-7777-7777-777777777777',
    'sorting',
    '[{"type": "text", "content": "Sort from lowest to highest."}]'::jsonb,
    '["4", "8", "12", "16"]'::jsonb,
    '4 is lowest. 16 is highest.',
    'medium'
);
