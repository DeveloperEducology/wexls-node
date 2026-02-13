-- ==========================================
-- SEED DATA: SUBJECTS, UNITS, MICRO SKILLS
-- Use this script to populate the syllabus structure.
-- ==========================================

DO $$
DECLARE
    -- Subject IDs
    sub_ma_id UUID;
    sub_ar_id UUID;
    sub_ln_id UUID;

    -- Mental Ability Unit IDs
    u_omo_id UUID;
    u_fm_id UUID;
    u_pc_id UUID;
    u_fsc_id UUID;
    u_anl_id UUID;
    u_gfc_id UUID;
    u_mi_id UUID;
    u_php_id UUID;
    u_sv_id UUID;
    u_ef_id UUID;

    -- Arithmetic Unit IDs
    u_ns_id UUID;
    u_fund_id UUID;
    u_frac_id UUID;
    u_lcm_id UUID;
    u_dec_id UUID;
    u_app_id UUID;
    u_meas_id UUID;
    u_dist_id UUID;
    u_si_id UUID;
    u_prof_id UUID;
    u_area_id UUID;

    -- Language Unit IDs
    u_pass_id UUID;

BEGIN
    -- 1. Insert Subjects
    -- We use ON CONFLICT to avoid duplicates if they already exist
    INSERT INTO subjects (name, icon_name, color_hex, question_count) VALUES
    ('Mental Ability', 'psychology', '0xFF5E35B1', 100),
    ('Arithmetic', 'calculate', '0xFFE53935', 100),
    ('Language', 'language', '0xFF43A047', 100)
    ON CONFLICT (name) DO UPDATE SET question_count = EXCLUDED.question_count;

    -- Retrieve IDs
    SELECT id INTO sub_ma_id FROM subjects WHERE name = 'Mental Ability';
    SELECT id INTO sub_ar_id FROM subjects WHERE name = 'Arithmetic';
    SELECT id INTO sub_ln_id FROM subjects WHERE name = 'Language';


    -- ====================================================
    -- 2. Mental Ability Units (10 Sections of JNVST)
    -- ====================================================
    
    -- Unit 1: Odd Man Out
    INSERT INTO units (subject_id, title, description, order_index) 
    VALUES (sub_ma_id, 'Odd Man Out', 'Identify the figure that is different from the others.', 1)
    RETURNING id INTO u_omo_id;
    
    INSERT INTO micro_skills (unit_id, title, order_index) VALUES
    (u_omo_id, 'Figure Classification', 1),
    (u_omo_id, 'Pattern Consistency', 2);

    -- Unit 2: Figure Matching
    INSERT INTO units (subject_id, title, description, order_index) 
    VALUES (sub_ma_id, 'Figure Matching', 'Find the figure identical to the problem figure.', 2)
    RETURNING id INTO u_fm_id;
    
    INSERT INTO micro_skills (unit_id, title, order_index) VALUES
    (u_fm_id, 'Exact Match', 1),
    (u_fm_id, 'Visual Discrimination', 2);

    -- Unit 3: Pattern Completion
    INSERT INTO units (subject_id, title, description, order_index) 
    VALUES (sub_ma_id, 'Pattern Completion', 'Complete the missing part of the figure.', 3)
    RETURNING id INTO u_pc_id;
    
    INSERT INTO micro_skills (unit_id, title, order_index) VALUES
    (u_pc_id, 'Completing the Square', 1),
    (u_pc_id, 'Completing the Circle', 2);

    -- Unit 4: Figure Series Completion
    INSERT INTO units (subject_id, title, description, order_index) 
    VALUES (sub_ma_id, 'Figure Series Completion', 'Find the next figure in the series.', 4)
    RETURNING id INTO u_fsc_id;
    
    INSERT INTO micro_skills (unit_id, title, order_index) VALUES
    (u_fsc_id, 'Rotation Series', 1),
    (u_fsc_id, 'Addition/Deletion of Elements', 2);

    -- Unit 5: Analogy
    INSERT INTO units (subject_id, title, description, order_index) 
    VALUES (sub_ma_id, 'Analogy', 'Find the relationship between figures.', 5)
    RETURNING id INTO u_anl_id;

    INSERT INTO micro_skills (unit_id, title, order_index) VALUES
    (u_anl_id, 'Relationship Identification', 1),
    (u_anl_id, 'Shape & Rotation Analogy', 2);

    -- Unit 6: Geometric Figure Completion
    INSERT INTO units (subject_id, title, description, order_index) 
    VALUES (sub_ma_id, 'Geometric Figure Completion', 'Complete the triangle, square, or circle.', 6)
    RETURNING id INTO u_gfc_id;

    INSERT INTO micro_skills (unit_id, title, order_index) VALUES
    (u_gfc_id, 'Triangle Completion', 1),
    (u_gfc_id, 'Square Construction', 2);

    -- Unit 7: Mirror Imaging
    INSERT INTO units (subject_id, title, description, order_index) 
    VALUES (sub_ma_id, 'Mirror Imaging', 'Identify the mirror reflection of the figure.', 7)
    RETURNING id INTO u_mi_id;

    INSERT INTO micro_skills (unit_id, title, order_index) VALUES
    (u_mi_id, 'Lateral Inversion', 1),
    (u_mi_id, 'Alphabets & Numbers', 2);

    -- Unit 8: Punched Hold Pattern
    INSERT INTO units (subject_id, title, description, order_index) 
    VALUES (sub_ma_id, 'Punched Hold Pattern', 'Paper folding and punching patterns.', 8)
    RETURNING id INTO u_php_id;

    INSERT INTO micro_skills (unit_id, title, order_index) VALUES
    (u_php_id, 'Unfolding Patterns', 1),
    (u_php_id, 'Symmetry Cutting', 2);

    -- Unit 9: Space Visualization
    INSERT INTO units (subject_id, title, description, order_index) 
    VALUES (sub_ma_id, 'Space Visualization', 'Form a shape from cut-out pieces.', 9)
    RETURNING id INTO u_sv_id;

    INSERT INTO micro_skills (unit_id, title, order_index) VALUES
    (u_sv_id, 'Shape Construction', 1),
    (u_sv_id, 'Puzzle Piece Fitting', 2);

    -- Unit 10: Embedded Figure
    INSERT INTO units (subject_id, title, description, order_index) 
    VALUES (sub_ma_id, 'Embedded Figure', 'Find the hidden figure.', 10)
    RETURNING id INTO u_ef_id;

    INSERT INTO micro_skills (unit_id, title, order_index) VALUES
    (u_ef_id, 'Hidden Shapes', 1),
    (u_ef_id, 'Complex Embeddings', 2);


    -- ====================================================
    -- 3. Arithmetic Units
    -- ====================================================
    
    INSERT INTO units (subject_id, title, description, order_index) 
    VALUES (sub_ar_id, 'Number System', 'Numbers, place value, and operations.', 1)
    RETURNING id INTO u_ns_id;
    
    INSERT INTO micro_skills (unit_id, title, order_index) VALUES
    (u_ns_id, 'Types of Numbers', 1),
    (u_ns_id, 'Place Value & Face Value', 2),
    (u_ns_id, 'Rounding Off', 3);

    INSERT INTO units (subject_id, title, description, order_index) 
    VALUES (sub_ar_id, 'Fundamental Operations', 'Addition, subtraction, multiplication, division.', 2)
    RETURNING id INTO u_fund_id;
    
    INSERT INTO micro_skills (unit_id, title, order_index) VALUES
    (u_fund_id, 'Fractions', 1),
    (u_fund_id, 'Simplification (BODMAS)', 2);

    INSERT INTO units (subject_id, title, description, order_index) 
    VALUES (sub_ar_id, 'LCM and HCF', 'Factors and multiples.', 3)
    RETURNING id INTO u_lcm_id;
    
    INSERT INTO micro_skills (unit_id, title, order_index) VALUES
    (u_lcm_id, 'Finding Factors', 1),
    (u_lcm_id, 'Word Problems on LCM/HCF', 2);
    
    INSERT INTO units (subject_id, title, description, order_index) 
    VALUES (sub_ar_id, 'Decimals', 'Decimal numbers and operations.', 4)
    RETURNING id INTO u_dec_id;
    
    INSERT INTO micro_skills (unit_id, title, order_index) VALUES
    (u_dec_id, 'Conversion Fraction to Decimal', 1),
    (u_dec_id, 'Operations on Decimals', 2);


    -- ====================================================
    -- 4. Language Units
    -- ====================================================

    INSERT INTO units (subject_id, title, description, order_index) 
    VALUES (sub_ln_id, 'Comprehension Passage', 'Reading passages and answering questions.', 1)
    RETURNING id INTO u_pass_id;

    INSERT INTO micro_skills (unit_id, title, order_index) VALUES
    (u_pass_id, 'Passage Reading 1', 1),
    (u_pass_id, 'Passage Reading 2', 2),
    (u_pass_id, 'Passage Reading 3', 3),
    (u_pass_id, 'Vocabulary & Synonyms', 4);

END $$;
