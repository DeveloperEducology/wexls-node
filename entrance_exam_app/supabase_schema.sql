-- Enable UUID extension if not enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Create Subjects Table
CREATE TABLE IF NOT EXISTS subjects (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    icon_name TEXT DEFAULT 'book',
    color_hex TEXT DEFAULT '0xFF6C63FF',
    question_count INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Create Units Table
CREATE TABLE IF NOT EXISTS units (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    subject_id UUID REFERENCES subjects(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    order_index INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Create Micro Skills Table (Topics)
CREATE TABLE IF NOT EXISTS micro_skills (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    unit_id UUID REFERENCES units(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    order_index INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Link Questions to Micro Skills
-- NOTE: If your questions table doesn't exist yet, create it first.
-- Assuming 'questions' table exists from previous setup.
ALTER TABLE questions ADD COLUMN IF NOT EXISTS micro_skill_id UUID REFERENCES micro_skills(id) ON DELETE SET NULL;


-- ==========================================
-- SEED DATA (Navodaya Class 6 Structure)
-- ==========================================

-- Insert Subjects
INSERT INTO subjects (name, icon_name, color_hex, question_count) VALUES
('Mental Ability', 'psychology', '0xFF5E35B1', 120),
('Arithmetic', 'calculate', '0xFFE53935', 80),
('Language', 'language', '0xFF43A047', 50),
('Physics', 'science', '0xFF6C63FF', 100),
('Math', 'functions', '0xFFFF6584', 150)
ON CONFLICT (name) DO NOTHING;

-- Function to get Subject ID by Name (Helper for inserts)
-- You can run these blocks manually or use the IDs directly if using Supabase Dashboard.
-- I will use DO blocks for robust insertion in SQL editor.

DO $$
DECLARE
    sub_ma_id UUID;
    sub_ar_id UUID;
    sub_ln_id UUID;
    
    u_omo_id UUID;
    u_fm_id UUID;
    
    u_ns_id UUID;
    
    u_cp_id UUID;
BEGIN
    -- Get Subject IDs
    SELECT id INTO sub_ma_id FROM subjects WHERE name = 'Mental Ability';
    SELECT id INTO sub_ar_id FROM subjects WHERE name = 'Arithmetic';
    SELECT id INTO sub_ln_id FROM subjects WHERE name = 'Language';

    -- Units for Mental Ability
    INSERT INTO units (subject_id, title, description, order_index) VALUES 
    (sub_ma_id, 'Odd Man Out', 'Identify the figure that is different from others.', 1) RETURNING id INTO u_omo_id;
    
    INSERT INTO units (subject_id, title, description, order_index) VALUES 
    (sub_ma_id, 'Figure Matching', 'Find the exact match to the problem figure.', 2) RETURNING id INTO u_fm_id;

    -- Micro Skills for Odd Man Out
    INSERT INTO micro_skills (unit_id, title, order_index) VALUES 
    (u_omo_id, 'Figure Classification', 1),
    (u_omo_id, 'Pattern Spotting', 2);
    
    -- Micro Skills for Figure Matching
    INSERT INTO micro_skills (unit_id, title, order_index) VALUES 
    (u_fm_id, 'Exact Match', 1);


    -- Units for Arithmetic
    INSERT INTO units (subject_id, title, description, order_index) VALUES 
    (sub_ar_id, 'Number System', 'Understanding numbers and operations.', 1) RETURNING id INTO u_ns_id;
    
    -- Micro Skills for Number System
    INSERT INTO micro_skills (unit_id, title, order_index) VALUES 
    (u_ns_id, 'Types of Numbers', 1),
    (u_ns_id, 'Place Value', 2);


    -- Units for Language
    INSERT INTO units (subject_id, title, description, order_index) VALUES 
    (sub_ln_id, 'Comprehension Passage', 'Reading phrases and understanding context.', 1) RETURNING id INTO u_cp_id;
    
    -- Micro Skills for Language
    INSERT INTO micro_skills (unit_id, title, order_index) VALUES 
    (u_cp_id, 'Passage Reading 1', 1),
    (u_cp_id, 'Passage Reading 2', 2);

END $$;
