-- 1. Ensure Subjects Exist with Slugs
INSERT INTO public.subjects (name, slug)
SELECT 'Math', 'math' WHERE NOT EXISTS (SELECT 1 FROM public.subjects WHERE name = 'Math');

INSERT INTO public.subjects (name, slug)
SELECT 'English', 'english' WHERE NOT EXISTS (SELECT 1 FROM public.subjects WHERE name = 'English');

INSERT INTO public.subjects (name, slug)
SELECT 'Science', 'science' WHERE NOT EXISTS (SELECT 1 FROM public.subjects WHERE name = 'Science');

INSERT INTO public.subjects (name, slug)
SELECT 'Social Studies', 'social-studies' WHERE NOT EXISTS (SELECT 1 FROM public.subjects WHERE name = 'Social Studies');

INSERT INTO public.subjects (name, slug)
SELECT 'Hindi', 'hindi' WHERE NOT EXISTS (SELECT 1 FROM public.subjects WHERE name = 'Hindi');

INSERT INTO public.subjects (name, slug)
SELECT 'Computer Science', 'computer-science' WHERE NOT EXISTS (SELECT 1 FROM public.subjects WHERE name = 'Computer Science');

INSERT INTO public.subjects (name, slug)
SELECT 'General Knowledge', 'general-knowledge' WHERE NOT EXISTS (SELECT 1 FROM public.subjects WHERE name = 'General Knowledge');


-- 2. Populate Units for Grades LKG - Class 5
DO $$
DECLARE
    g_id uuid;
    s_id uuid;
    g_name text;
    s_name text;
    -- Expanding list of subjects to include new additions
    all_subjects text[] := ARRAY['Math', 'English', 'Science', 'Social Studies', 'Hindi', 'Computer Science', 'General Knowledge'];
    
    -- Defining which subjects belong to which grades specifically if needed, but for now we apply broadly.
    -- Or we can just seed all for all to ensure visibility.
    target_grades text[] := ARRAY['LKG', 'UKG', 'Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'];
    
    unit_exists boolean;
    unit_code text;
    s_slug text;
BEGIN
    FOREACH g_name IN ARRAY target_grades
    LOOP
        SELECT id INTO g_id FROM public.grades WHERE name = g_name LIMIT 1;
        
        IF g_id IS NOT NULL THEN
            FOREACH s_name IN ARRAY all_subjects
            LOOP
                SELECT id, slug INTO s_id, s_slug FROM public.subjects WHERE name = s_name LIMIT 1;
                
                IF s_id IS NOT NULL THEN
                    RAISE NOTICE 'Seeding: % - %', g_name, s_name;
                    
                    -- Check if unit exists to avoid duplicates
                    SELECT EXISTS(SELECT 1 FROM public.units WHERE grade_id = g_id AND subject_id = s_id AND name = 'Overview') INTO unit_exists;
                    
                    IF NOT unit_exists THEN
                        -- Generate a simple code like "LKG-MATH-01" or "CLASS1-ENG-01"
                        -- Removing spaces from grade name and upper casing
                        unit_code := upper(replace(g_name, ' ', '')) || '-' || upper(s_slug) || '-01';
                        
                        INSERT INTO public.units (grade_id, subject_id, name, sort_order, code)
                        VALUES (g_id, s_id, 'Overview', 1, unit_code);
                    END IF;
                ELSE 
                    RAISE NOTICE 'Subject % not found.', s_name;
                END IF;
            END LOOP;
        ELSE 
            RAISE NOTICE 'Grade % not found.', g_name;
        END IF;
    END LOOP;
END $$;
