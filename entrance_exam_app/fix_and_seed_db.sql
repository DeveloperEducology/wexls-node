-- ==========================================
-- FIX & SEED SCRIPT
-- Run this SINGLE script to fix your table schema AND insert sample data.
-- ==========================================

-- 1. FIX SCHEMA: Add missing columns and relax constraints
DO $$
BEGIN
    -- Add columns if they don't exist
    BEGIN
        ALTER TABLE questions ADD COLUMN correct_option_index INT DEFAULT 0;
    EXCEPTION WHEN duplicate_column THEN END;

    BEGIN
        ALTER TABLE questions ADD COLUMN explanation TEXT DEFAULT '';
    EXCEPTION WHEN duplicate_column THEN END;

    BEGIN
        ALTER TABLE questions ADD COLUMN layout TEXT DEFAULT 'list';
    EXCEPTION WHEN duplicate_column THEN END;

    BEGIN
        ALTER TABLE questions ADD COLUMN marks INT DEFAULT 1;
    EXCEPTION WHEN duplicate_column THEN END;

    BEGIN
        ALTER TABLE questions ADD COLUMN difficulty_level TEXT DEFAULT 'medium';
    EXCEPTION WHEN duplicate_column THEN END;

    BEGIN
        ALTER TABLE questions ADD COLUMN parts JSONB DEFAULT '[]'::jsonb;
    EXCEPTION WHEN duplicate_column THEN END;

    BEGIN
        ALTER TABLE questions ADD COLUMN options JSONB DEFAULT '[]'::jsonb;
    EXCEPTION WHEN duplicate_column THEN END;

    BEGIN
        ALTER TABLE questions ADD COLUMN micro_skill_id UUID REFERENCES micro_skills(id) ON DELETE SET NULL;
    EXCEPTION WHEN duplicate_column THEN END;

    -- Relax 'answer' constraint if it exists
    BEGIN
        ALTER TABLE questions ALTER COLUMN answer DROP NOT NULL;
    EXCEPTION WHEN undefined_column THEN 
        -- If column answer doesn't exist, we don't care
    END;
END $$;


-- 2. INSERT SAMPLE DATA
DO $$
DECLARE
    -- Subject: Mental Ability
    ms_odd_man_out UUID;
    ms_figure_matching UUID;
    
    -- Subject: Arithmetic
    ms_number_system UUID;
    ms_fractions UUID;

    -- Subject: Language
    ms_comprehension UUID;

BEGIN
    -- Get Micro Skill IDs
    
    -- Mental Ability (Try different variations of titles to match what might be in DB)
    SELECT id INTO ms_odd_man_out FROM micro_skills WHERE title = 'Figure Classification' LIMIT 1;
    SELECT id INTO ms_figure_matching FROM micro_skills WHERE title = 'Exact Match' LIMIT 1;
    
    -- Arithmetic
    SELECT id INTO ms_number_system FROM micro_skills WHERE title = 'Types of Numbers' LIMIT 1;
    SELECT id INTO ms_fractions FROM micro_skills WHERE title = 'Addition & Subtraction' LIMIT 1;

    -- Language
    SELECT id INTO ms_comprehension FROM micro_skills WHERE title = 'Passage Reading 1' LIMIT 1;


    -- Insert Mental Ability Questions
    IF ms_odd_man_out IS NOT NULL THEN
        INSERT INTO questions (micro_skill_id, parts, options, correct_option_index, explanation, layout, marks, difficulty_level)
        VALUES 
        (
            ms_odd_man_out,
            '[{"type": "text", "content": "Identify the figure that is different from the others."}]',
            '[
                "https://pub-463c5e524a144b19b1f98c36673af4d9.r2.dev/options/1768490093591_h1rtx.webp", 
                "https://pub-463c5e524a144b19b1f98c36673af4d9.r2.dev/options/1768490093591_f0d3p9.webp", 
                "https://pub-463c5e524a144b19b1f98c36673af4d9.r2.dev/options/1768490093590_mhffvw.webp", 
                "https://pub-463c5e524a144b19b1f98c36673af4d9.r2.dev/options/1768490093587_ufrrht.webp"
            ]',
            0,
            'Figure A is the only one rotated 90 degrees clockwise compared to others relative to the baseline.',
            'grid',
            1,
            'easy'
        );
    END IF;

    IF ms_figure_matching IS NOT NULL THEN
        INSERT INTO questions (micro_skill_id, parts, options, correct_option_index, explanation, layout, marks, difficulty_level)
        VALUES 
        (
            ms_figure_matching,
            '[{"type": "text", "content": "Which answer figure is the exact mirror image of the question figure?"}, {"type": "image", "content": "https://pub-463c5e524a144b19b1f98c36673af4d9.r2.dev/options/mirror_q1.webp"}]',
            '[
                "https://pub-463c5e524a144b19b1f98c36673af4d9.r2.dev/options/mirror_opt1.webp",
                "https://pub-463c5e524a144b19b1f98c36673af4d9.r2.dev/options/mirror_opt2.webp",
                "https://pub-463c5e524a144b19b1f98c36673af4d9.r2.dev/options/mirror_opt3.webp",
                "https://pub-463c5e524a144b19b1f98c36673af4d9.r2.dev/options/mirror_opt4.webp"
            ]',
            2,
            'In a mirror image, left becomes right and right becomes left.',
            'grid',
            1,
            'medium'
        );
    END IF;

    -- Insert Arithmetic Questions
    IF ms_number_system IS NOT NULL THEN
        INSERT INTO questions (micro_skill_id, parts, options, correct_option_index, explanation, layout, marks, difficulty_level)
        VALUES 
        (
            ms_number_system,
            '[{"type": "text", "content": "The difference between the place value of the digit 5 in the number 25,354 is:"}]',
            '["5000", "4950", "50", "4960"]',
            1,
            'Place values of 5 are 5000 and 50. Difference = 4950.',
            'list',
            1,
            'easy'
        ),
        (
            ms_number_system,
            '[{"type": "text", "content": "Simplify the expression:"}, {"type": "math", "content": "\\\\frac{3}{4} + \\\\frac{5}{6} \\\\times \\\\frac{1}{2}"}]',
            '["1 \\\\frac{1}{6}", "1 \\\\frac{5}{12}", "\\\\frac{7}{8}", "2"]',
            0,
            'Using BODMAS: 5/6 * 1/2 = 5/12. 3/4 + 5/12 = 14/12 = 7/6 = 1 1/6.',
            'list',
            2,
            'medium'
        );
    END IF;

    -- Insert Language Questions
    IF ms_comprehension IS NOT NULL THEN
        INSERT INTO questions (micro_skill_id, parts, options, correct_option_index, explanation, layout, marks, difficulty_level)
        VALUES 
        (
            ms_comprehension,
            '[
                {"type": "text", "content": "Read the passage below and answer the question:"},
                {"type": "text", "content": "Passage: The banyan tree becomes very large..."},
                {"type": "text", "content": "Question: Why is the banyan tree able to become very large?"}
            ]',
            '[
                "Because it has many leaves",
                "Because it is worshipped",
                "Because its roots form new trunks",
                "Because it needs a lot of water"
            ]',
            2,
            'The passage states that it spreads roots from branches which enter the ground to become new trunks.',
            'list',
            1,
            'easy'
        );
    END IF;

END $$;
