/*
 CLARITY ON SCHEMA:
 
 1. GRADES table:
    - id: UUID
    - name: 'Class 1', 'Class 2'
    
 2. SUBJECTS table:
    - id: UUID
    - name: 'Math', 'English'
    - slug: 'math', 'english'
    (Global subjects list. Math is Math, whether for Class 1 or Class 10)
    
 3. UNITS table (The "Content Link"):
    - id: UUID
    - grade_id: UUID (Refers to Grade)
    - subject_id: UUID (Refers to Subject)
    - name: 'Geometry', 'Algebra'
    - code: 'CLASS1-MATH-01'
    
 PROBLEM: 
 You want "Subjects for Class 1". In relational DBs, we don't create specific "Class 1 Math" in the SUBJECTS table.
 Instead, we verify "Class 1" has "Math" by checking if there are UNITS for that combination.
 
 However, if you want to strictly control which subjects appear for which grade WITHOUT adding units first,
 we can create a mapping table `grade_subjects` or just stick to the rule: 
 "A subject exists for a grade if at least one unit exists."
 
 The script below Ensures correct seeding of this logic.
*/

-- 1. CLEANUP (Optional - be careful running this in production)
-- DELETE FROM public.units; 
-- DELETE FROM public.subjects;

-- 2. ENSURE GLOBAL SUBJECTS
INSERT INTO public.subjects (name, slug)
SELECT 'Math', 'math' WHERE NOT EXISTS (SELECT 1 FROM public.subjects WHERE slug = 'math');

INSERT INTO public.subjects (name, slug)
SELECT 'English', 'english' WHERE NOT EXISTS (SELECT 1 FROM public.subjects WHERE slug = 'english');

INSERT INTO public.subjects (name, slug)
SELECT 'Science', 'science' WHERE NOT EXISTS (SELECT 1 FROM public.subjects WHERE slug = 'science');

INSERT INTO public.subjects (name, slug)
SELECT 'Hindi', 'hindi' WHERE NOT EXISTS (SELECT 1 FROM public.subjects WHERE slug = 'hindi');

INSERT INTO public.subjects (name, slug)
SELECT 'Social Studies', 'social-studies' WHERE NOT EXISTS (SELECT 1 FROM public.subjects WHERE slug = 'social-studies');


-- 3. LINK SUBJECTS TO GRADES via UNITS
-- We create a dummy "Curriculum Overview" unit for every Grade-Subject pair.
DO $$
DECLARE
    g_rec RECORD;
    s_rec RECORD;
    unit_code text;
    exists_check boolean;
BEGIN
    -- For every grade in the system
    FOR g_rec IN SELECT * FROM public.grades LOOP
        
        -- For every subject in the system
        FOR s_rec IN SELECT * FROM public.subjects LOOP
            
            -- Deterministic Code: e.g. CLASS1-MATH-INTRO
            unit_code := upper(replace(g_rec.name, ' ', '')) || '-' || upper(s_rec.slug) || '-INTRO';
            
            -- Check existence
            SELECT EXISTS(SELECT 1 FROM public.units WHERE code = unit_code) INTO exists_check;
            
            IF NOT exists_check THEN
                RAISE NOTICE 'Linking % to %', g_rec.name, s_rec.name;
                
                INSERT INTO public.units (grade_id, subject_id, name, sort_order, code)
                VALUES (g_rec.id, s_rec.id, 'Curriculum Overview', 1, unit_code);
            END IF;
            
        END LOOP;
    END LOOP;
END $$;
