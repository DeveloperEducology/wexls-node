-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- DROP EXISTING TABLES AND TYPES TO START FRESH
DROP TABLE IF EXISTS questions CASCADE;
DROP TABLE IF EXISTS micro_skills CASCADE;
DROP TABLE IF EXISTS units CASCADE;
DROP TABLE IF EXISTS subjects CASCADE;
DROP TABLE IF EXISTS grades CASCADE;

-- 1. GRADES TABLE
CREATE TABLE grades (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,       -- e.g., 'Class II'
    slug TEXT NOT NULL,       -- e.g., 'class-ii'
    sort_order INTEGER NOT NULL,
    color_hex TEXT            -- e.g., '#00A52E'
);

-- 2. SUBJECTS TABLE
CREATE TABLE subjects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,       -- e.g., 'Maths'
    slug TEXT NOT NULL,       -- e.g., 'maths'
    icon TEXT                 -- Optional icon name
);

-- 3. UNITS TABLE (e.g. "A. Counting")
-- Links a Grade and a Subject together
CREATE TABLE units (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    grade_id UUID REFERENCES grades(id) ON DELETE CASCADE,
    subject_id UUID REFERENCES subjects(id) ON DELETE CASCADE,
    name TEXT NOT NULL,       -- e.g., 'Counting and number patterns'
    code TEXT NOT NULL,       -- e.g., 'A'
    sort_order INTEGER NOT NULL
);

-- 4. MICRO SKILLS TABLE (e.g. "A.1 Skip-counting")
CREATE TABLE micro_skills (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    unit_id UUID REFERENCES units(id) ON DELETE CASCADE,
    name TEXT NOT NULL,       -- e.g., 'Skip-counting'
    code TEXT NOT NULL,       -- e.g., 'A.1'
    description TEXT,
    sort_order INTEGER NOT NULL
);

-- 5. QUESTIONS TABLE
-- Linked to a specific Micro Skill
CREATE TABLE questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    micro_skill_id UUID REFERENCES micro_skills(id) ON DELETE SET NULL,
    
    type TEXT NOT NULL CHECK (type IN ('mcq', 'textInput')),
    
    -- Content
    parts JSONB NOT NULL DEFAULT '[]'::jsonb, 
    
    -- Interaction
    options JSONB DEFAULT '[]'::jsonb, 
    correct_answer_index INTEGER DEFAULT -1,
    correct_answer_text TEXT,
    
    -- Meta
    solution TEXT,
    difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')),
    marks INTEGER DEFAULT 1,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS POLICIES
ALTER TABLE grades ENABLE ROW LEVEL SECURITY;
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE units ENABLE ROW LEVEL SECURITY;
ALTER TABLE micro_skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public Read Grades" ON grades FOR SELECT USING (true);
CREATE POLICY "Public Read Subjects" ON subjects FOR SELECT USING (true);
CREATE POLICY "Public Read Units" ON units FOR SELECT USING (true);
CREATE POLICY "Public Read Skills" ON micro_skills FOR SELECT USING (true);
CREATE POLICY "Public Read Questions" ON questions FOR SELECT USING (true);


-- SEED DATA =========================================================

-- Insert Subjects (Using static UUIDs for linking)
INSERT INTO subjects (id, name, slug) VALUES 
('11111111-1111-1111-1111-111111111111', 'Maths', 'maths'),
('22222222-2222-2222-2222-222222222222', 'English', 'english');

-- Insert Grades
INSERT INTO grades (id, name, slug, sort_order, color_hex) VALUES 
('33333333-3333-3333-3333-333333333331', 'LKG', 'lkg', 1, '#E91E63'),
('33333333-3333-3333-3333-333333333332', 'UKG', 'ukg', 2, '#9C27B0'),
('33333333-3333-3333-3333-333333333333', 'Class I', 'class-i', 3, '#2196F3'),
('33333333-3333-3333-3333-333333333334', 'Class II', 'class-ii', 4, '#009688');

-- Insert Units for Class II Maths
-- Link Grade (Class II) + Subject (Maths)
INSERT INTO units (id, grade_id, subject_id, name, code, sort_order) VALUES
('44444444-4444-4444-4444-444444444444', 
 '33333333-3333-3333-3333-333333333334', -- Class II
 '11111111-1111-1111-1111-111111111111', -- Maths
 'Counting and number patterns', 'A', 1);

-- Insert Micro Skills for Unit A
INSERT INTO micro_skills (id, unit_id, name, code, sort_order) VALUES
('55555555-5555-5555-5555-555555555551', '44444444-4444-4444-4444-444444444444', 'Counting objects', 'A.1', 1),
('55555555-5555-5555-5555-555555555552', '44444444-4444-4444-4444-444444444444', 'Skip-counting', 'A.2', 2),
('55555555-5555-5555-5555-555555555553', '44444444-4444-4444-4444-444444444444', 'Comparison', 'A.3', 3);


-- Insert Questions linked to Micro Skills

-- 1. Counting Birds (Linked to A.1)
INSERT INTO questions (micro_skill_id, type, parts, options, correct_answer_index, solution, difficulty)
VALUES (
    '55555555-5555-5555-5555-555555555551', -- A.1
    'mcq', 
    '[
        {"type": "text", "content": "Count the birds by 1s."}, 
        {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/3069/3069172.png", "height": 100},
        {"type": "text", "content": "How many birds are there?"}
    ]'::jsonb,
    '["3", "4", "5", "6"]'::jsonb,
    2,
    'Count them one by one: 1, 2, 3, 4, 5.',
    'easy'
);

-- 2. Skip Counting (Linked to A.2)
INSERT INTO questions (micro_skill_id, type, parts, correct_answer_text, solution, difficulty)
VALUES (
    '55555555-5555-5555-5555-555555555552', -- A.2
    'textInput',
    '[
        {"type": "text", "content": "Skip-counting by 5s."},
        {"type": "math", "content": "5, 10, \\_, 20"} 
    ]'::jsonb,
    '15',
    'We are adding 5 each time. 10 + 5 = 15.',
    'medium'
);

-- 3. Comparison (Linked to A.3)
INSERT INTO questions (micro_skill_id, type, parts, options, correct_answer_index, solution, difficulty)
VALUES (
    '55555555-5555-5555-5555-555555555553', -- A.3
    'mcq',
    '[{"type": "text", "content": "Which number is greater?"}]'::jsonb,
    '["12", "45", "8", "21"]'::jsonb,
    1,
    'Compare the tens place. 4 tens is more than 1 or 2 tens.',
    'medium'
);
