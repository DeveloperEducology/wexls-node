-- ====================================================================
-- ADDING DRAG & DROP SKILL (TYPE: dragAndDrop) & JSONB columns
-- ====================================================================

-- 1. DROP Constraint to allow 'dragAndDrop' type
ALTER TABLE questions DROP CONSTRAINT IF EXISTS questions_type_check;
ALTER TABLE questions ADD CONSTRAINT questions_type_check CHECK (type IN ('mcq', 'textInput', 'sorting', 'dragAndDrop'));

-- 2. NOTE: We are storing drag groups and items in generic JSONB. 
-- In Dart model we parse them from "drag_groups" and "drag_items".
-- BUT Supabase table structure (step 399) only has: parts, options.
-- We can add new columns OR store them in 'parts' or a 'meta' column. 
-- Let's ADD explicit columns for cleanliness to the table as 'jsonb'.

ALTER TABLE questions ADD COLUMN IF NOT EXISTS drag_groups JSONB DEFAULT '[]'::jsonb;
ALTER TABLE questions ADD COLUMN IF NOT EXISTS drag_items JSONB DEFAULT '[]'::jsonb;

-- 3. Add "C. Drag and Drop" Unit to Class II Maths
-- Grade Class II: '33333333-3333-3333-3333-333333333334'
-- Subject Maths: '11111111-1111-1111-1111-111111111111'

-- Unit ID: 88888888-8888-8888-8888-888888888888
INSERT INTO units (id, grade_id, subject_id, name, code, sort_order) VALUES
(
 '88888888-8888-8888-8888-888888888888', 
 '33333333-3333-3333-3333-333333333334', 
 '11111111-1111-1111-1111-111111111111', 
 'Drag and Drop Activity', 
 'C', 
 3
);

-- 4. Add Micro Skill "C.1 Sort Vowel Sounds"
-- Skill ID: 99999999-9999-9999-9999-999999999999
INSERT INTO micro_skills (id, unit_id, name, code, sort_order) VALUES
('99999999-9999-9999-9999-999999999999', '88888888-8888-8888-8888-888888888888', 'Sort Vowel Sounds', 'C.1', 1);

-- 5. Add Drag & Drop Questions

-- Q1: Short 'o' vs Long 'o' (Based on user image)
INSERT INTO questions (micro_skill_id, type, parts, drag_groups, drag_items, solution, difficulty) VALUES 
(
    '99999999-9999-9999-9999-999999999999',
    'dragAndDrop',
    '[{"type": "text", "content": "Sort the words by their vowel sounds."}]'::jsonb,
    -- Groups
    '[
      {"id": "g1", "label": "Short o"},
      {"id": "g2", "label": "Long o"}
    ]'::jsonb,
    -- Items (Target must match Group ID)
    '[
      {"id": "i1", "content": "https://cdn-icons-png.flaticon.com/512/826/826955.png", "type": "image", "target_group_id": "g2"}, 
      {"id": "i2", "content": "https://cdn-icons-png.flaticon.com/512/3069/3069172.png", "type": "image", "target_group_id": "g2"}, 
      {"id": "i3", "content": "https://cdn-icons-png.flaticon.com/512/616/616490.png", "type": "image", "target_group_id": "g2"}  
    ]'::jsonb, 
    -- Let's update items to match "Short O" (Pot, Box) vs "Long O" (Bone, Rose)
    -- Using text for simplicity first, or placeholder images
    'Long "o" sounds like the letter name (Go, No). Short "o" sounds like "ah" (Hot, Pot).',
    'easy'
);

-- UPDATE Q1 with better items
UPDATE questions SET drag_items = '[
    {"id": "i1", "content": "Bone", "type": "text", "target_group_id": "g2"},
    {"id": "i2", "content": "Pot", "type": "text", "target_group_id": "g1"},
    {"id": "i3", "content": "Rose", "type": "text", "target_group_id": "g2"},
    {"id": "i4", "content": "Fox", "type": "text", "target_group_id": "g1"}
]'::jsonb
WHERE micro_skill_id = '99999999-9999-9999-9999-999999999999';

-- Q2: Sort Fruits vs Vegetables
INSERT INTO questions (micro_skill_id, type, parts, drag_groups, drag_items, solution, difficulty) VALUES 
(
    '99999999-9999-9999-9999-999999999999',
    'dragAndDrop',
    '[{"type": "text", "content": "Sort food items."}]'::jsonb,
    '[
      {"id": "g1", "label": "Fruits"},
      {"id": "g2", "label": "Vegetables"}
    ]'::jsonb,
    '[
      {"id": "i1", "content": "Apple", "type": "text", "target_group_id": "g1"},
      {"id": "i2", "content": "Carrot", "type": "text", "target_group_id": "g2"},
      {"id": "i3", "content": "Banana", "type": "text", "target_group_id": "g1"},
      {"id": "i4", "content": "Broccoli", "type": "text", "target_group_id": "g2"}
    ]'::jsonb,
    'Fruits have seeds. Vegetables are roots, stems, or leaves.',
    'easy'
);
