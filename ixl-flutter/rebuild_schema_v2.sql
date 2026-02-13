-- =================================================================
-- REBUILDING SCHEMA V2: STRICT HIERARCHY WITH MICRO SKILLS AND DEMO DATA
-- =================================================================

DROP TABLE IF EXISTS public.micro_skills CASCADE;
DROP TABLE IF EXISTS public.units CASCADE;
DROP TABLE IF EXISTS public.subjects CASCADE;
DROP TABLE IF EXISTS public.grades CASCADE;

-- 1. GRADES TABLE
CREATE TABLE public.grades (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,  -- e.g. "Class 1"
  sort_order INTEGER DEFAULT 0,
  color_hex TEXT, 
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. SUBJECTS TABLE (Linked to Grade)
CREATE TABLE public.subjects (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  grade_id UUID REFERENCES public.grades(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,         -- e.g. "Math"
  slug TEXT NOT NULL,         -- e.g. "math"
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. UNITS TABLE (Linked to Subject)
CREATE TABLE public.units (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  subject_id UUID REFERENCES public.subjects(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,         -- e.g. "Number Sense"
  code TEXT,                  -- e.g. "NS-01"
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. MICRO SKILLS TABLE (Linked to Unit)
-- Needed because app expects 'micro_skills' relation
CREATE TABLE public.micro_skills (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  unit_id UUID REFERENCES public.units(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,         -- e.g. "Count to 10"
  code TEXT,                  -- e.g. "A.1" 
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.grades ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.units ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.micro_skills ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read grades" ON public.grades FOR SELECT USING (true);
CREATE POLICY "Allow public read subjects" ON public.subjects FOR SELECT USING (true);
CREATE POLICY "Allow public read units" ON public.units FOR SELECT USING (true);
CREATE POLICY "Allow public read micro_skills" ON public.micro_skills FOR SELECT USING (true);


-- =================================================================
-- SEED DATA (4 Classes with Demo Content)
-- =================================================================
DO $$
DECLARE
    g_1_id uuid; g_2_id uuid; g_3_id uuid; g_4_id uuid;
    
    -- Subject IDs for Class 2
    s_math_id uuid; s_eng_id uuid; s_sci_id uuid;
    
    -- Unit IDs for Class 2 Math
    u_count_id uuid; u_add_id uuid;
BEGIN
    -- 1. Create Grades
    INSERT INTO public.grades (name, sort_order, color_hex) VALUES ('Class 1', 1, '#4CAF50') RETURNING id INTO g_1_id;
    INSERT INTO public.grades (name, sort_order, color_hex) VALUES ('Class 2', 2, '#2196F3') RETURNING id INTO g_2_id;
    INSERT INTO public.grades (name, sort_order, color_hex) VALUES ('Class 3', 3, '#FF9800') RETURNING id INTO g_3_id;
    INSERT INTO public.grades (name, sort_order, color_hex) VALUES ('Class 4', 4, '#9C27B0') RETURNING id INTO g_4_id;

    -- 2. Create Subjects for EACH Grade
    -- (We will focus fully populating Class 2 as requested, but add placeholder subjects for others so UI isn't empty)
    
    -- Class 1 placeholders
    INSERT INTO public.subjects (grade_id, name, slug) VALUES (g_1_id, 'Math', 'math');
    INSERT INTO public.subjects (grade_id, name, slug) VALUES (g_1_id, 'English', 'english');
    
    -- CLASS 2: Math, English, Science (with Units & Skills)
    INSERT INTO public.subjects (grade_id, name, slug) VALUES (g_2_id, 'Math', 'math') RETURNING id INTO s_math_id;
    INSERT INTO public.subjects (grade_id, name, slug) VALUES (g_2_id, 'English', 'english') RETURNING id INTO s_eng_id;
    INSERT INTO public.subjects (grade_id, name, slug) VALUES (g_2_id, 'Science', 'science') RETURNING id INTO s_sci_id;
    
    -- Class 3 & 4 placeholders
    INSERT INTO public.subjects (grade_id, name, slug) VALUES (g_3_id, 'Math', 'math');
    INSERT INTO public.subjects (grade_id, name, slug) VALUES (g_4_id, 'Math', 'math');

    -- 3. Create UNITS for Class 2 Math
    INSERT INTO public.units (subject_id, name, sort_order, code) VALUES (s_math_id, 'Number Sense', 1, 'NS-01') RETURNING id INTO u_count_id;
    INSERT INTO public.units (subject_id, name, sort_order, code) VALUES (s_math_id, 'Addition', 2, 'ADD-01') RETURNING id INTO u_add_id;
    
    -- 4. Create MICRO SKILLS for Class 2 Math
    -- Unit: Number Sense
    INSERT INTO public.micro_skills (unit_id, name, code, sort_order) VALUES (u_count_id, 'Count forward and backward', 'A.1', 1);
    INSERT INTO public.micro_skills (unit_id, name, code, sort_order) VALUES (u_count_id, 'Skip-counting by 2s', 'A.2', 2);
    
    -- Unit: Addition
    INSERT INTO public.micro_skills (unit_id, name, code, sort_order) VALUES (u_add_id, 'Add one-digit numbers', 'B.1', 1);
    INSERT INTO public.micro_skills (unit_id, name, code, sort_order) VALUES (u_add_id, 'Add doubles', 'B.2', 2);

END $$;
