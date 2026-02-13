-- ====================================================================
-- BATCH INSERT: 3 SEASON/WEATHER QUESTIONS (fourPicsOneWord Style)
-- Micro-skill ID: 72e66906-0e03-4667-aafc-00973b0ecf5c
-- ====================================================================

INSERT INTO "public"."questions" (
    "micro_skill_id", "type", "parts", "options", 
    "correct_answer_index", "correct_answer_text", "solution", "difficulty", "marks"
) VALUES 
-- 1. WINTER
(
    -- Assuming a valid fallback micro_skill_id if this specific GUID doesn't exist userset
    'e982adb6-851d-4498-9d3f-48a2f1e2abf2', 
    'fourPicsOneWord', 
    '[{"type": "text", "content": "What season is this?"}, {"type": "image", "imageUrl": "https://thumbs.dreamstime.com/b/freezing-boy-winter-cold-cartoon-vector-shivering-young-standing-snowman-illustration-103588415.jpg"}]'::jsonb, 
    '[]'::jsonb, 
    -1, 
    'WINTER', 
    '[
        {"type": "text", "content": "Step 1: Look at the image. It shows a **snowflake**."},
        {"type": "text", "content": "Step 2: Snowflakes and cold weather represent the **WINTER** season."}
    ]'::jsonb, 
    'medium', 
    1
),

-- 2. MONSOON / RAIN
(
    'e982adb6-851d-4498-9d3f-48a2f1e2abf2', 
    'fourPicsOneWord', 
    '[{"type": "text", "content": "What season is this?"}, {"type": "image", "imageUrl": "https://i.pinimg.com/474x/95/d9/89/95d989fe5f9c082a3a8a51edc9645b4a.jpg"}]'::jsonb, 
    '[]'::jsonb, 
    -1, 
    'MONSOON', 
    '[
        {"type": "text", "content": "Step 1: The image shows a **cloud with raindrops**."},
        {"type": "text", "content": "Step 2: This represents the rainy season, also known as **MONSOON**."}
    ]'::jsonb, 
    'medium', 
    1
),

-- 3. SPRING
(
    'e982adb6-851d-4498-9d3f-48a2f1e2abf2', 
    'fourPicsOneWord', 
    '[{"type": "text", "content": "What season is this?"}, {"type": "image", "imageUrl": "https://toppng.com/uploads/preview/spring-season-clipart-png-115522423344u9ovwqeum.png"}]'::jsonb, 
    '[]'::jsonb, 
    -1, 
    'SPRING', 
    '[
        {"type": "text", "content": "Step 1: The image shows a **blooming flower** and a butterfly."},
        {"type": "text", "content": "Step 2: Flowers bloom during the **SPRING** season."}
    ]'::jsonb, 
    'medium', 
    1
);
