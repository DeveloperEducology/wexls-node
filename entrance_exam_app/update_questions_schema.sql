-- ==========================================
-- UPDATE SCHEMA: QUESTIONS TABLE
-- Run this script to ensure your 'questions' table has all necessary columns.
-- ==========================================

-- 1. Add correct_option_index if missing
ALTER TABLE questions 
ADD COLUMN IF NOT EXISTS correct_option_index INT DEFAULT 0;

-- 2. Add explanation if missing
ALTER TABLE questions 
ADD COLUMN IF NOT EXISTS explanation TEXT DEFAULT '';

-- 3. Add layout (grid/list) if missing
ALTER TABLE questions 
ADD COLUMN IF NOT EXISTS layout TEXT DEFAULT 'list';

-- 4. Add marks if missing
ALTER TABLE questions 
ADD COLUMN IF NOT EXISTS marks INT DEFAULT 1;

-- 5. Add difficulty_level if missing
ALTER TABLE questions 
ADD COLUMN IF NOT EXISTS difficulty_level TEXT DEFAULT 'medium';

-- 6. Ensure parts and options are JSONB or JSON
-- If they assume they are text in my script but are jsonb in DB, postgres handles string literals for json usually fine.
-- But let's make sure the columns exist.
ALTER TABLE questions 
ADD COLUMN IF NOT EXISTS parts JSONB DEFAULT '[]'::jsonb;

ALTER TABLE questions 
ADD COLUMN IF NOT EXISTS options JSONB DEFAULT '[]'::jsonb;

-- 7. Ensure micro_skill_id exists (foreign key)
ALTER TABLE questions 
ADD COLUMN IF NOT EXISTS micro_skill_id UUID REFERENCES micro_skills(id) ON DELETE SET NULL;
