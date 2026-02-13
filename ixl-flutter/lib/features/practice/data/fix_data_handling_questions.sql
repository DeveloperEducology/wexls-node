-- ====================================================================
-- BATCH INSERT: 5 DATA HANDLING & COMPARISON QUESTIONS (MICRO-SKILL 2)
-- Micro-skill ID: d939f2a2-4a80-4863-adca-e64790adb12b
-- ====================================================================

INSERT INTO "questions" (
    "id", "micro_skill_id", "type", "parts", "options", 
    "correct_answer_index", "correct_answer_text", "solution", "difficulty", "marks"
) VALUES 
-- 1. Total Count (Fruit Table)
(
    gen_random_uuid(), 'd939f2a2-4a80-4863-adca-e64790adb12b', 'fillInTheBlank', 
    '[
        {"type": "text", "content": "Look at the fruit table. How many fruits are there in total?"},
        {"type": "svg", "content": "<svg width=\"220\" height=\"140\" viewBox=\"0 0 220 140\">\n  <rect x=\"10\" y=\"10\" width=\"200\" height=\"120\" fill=\"#f9f9f9\" stroke=\"#333\" stroke-width=\"2\"/>\n  <line x1=\"10\" y1=\"50\" x2=\"210\" y2=\"50\" stroke=\"#333\" stroke-width=\"2\"/>\n  <line x1=\"110\" y1=\"10\" x2=\"110\" y2=\"130\" stroke=\"#333\" stroke-width=\"2\"/>\n  <text x=\"60\" y=\"35\" text-anchor=\"middle\" font-weight=\"bold\">Fruit</text>\n  <text x=\"160\" y=\"35\" text-anchor=\"middle\" font-weight=\"bold\">Count</text>\n  <text x=\"60\" y=\"80\" text-anchor=\"middle\">🍎 Apple</text>\n  <text x=\"160\" y=\"80\" text-anchor=\"middle\">5</text>\n  <text x=\"60\" y=\"110\" text-anchor=\"middle\">🍌 Banana</text>\n  <text x=\"160\" y=\"110\" text-anchor=\"middle\">3</text>\n</svg>"},
        {"id": "ans", "type": "input"}
    ]'::jsonb, 
    '[]'::jsonb, -1, '{"ans": "8"}', 
    '[{"type": "text", "content": "Step 1: Count the apples (5). Step 2: Count the bananas (3). Step 3: Add them together: 5 + 3 = 8."}]'::jsonb, 
    'easy', 1
),

-- 2. Most Liked Fruit (Comparison)
(
    gen_random_uuid(), 'd939f2a2-4a80-4863-adca-e64790adb12b', 'mcq', 
    '[
        {"type": "text", "content": "Which fruit is liked by the most children?"},
        {"type": "svg", "content": "<svg width=\"240\" height=\"100\">\n  <text x=\"10\" y=\"30\">🍎 Apples: 5</text>\n  <text x=\"10\" y=\"60\">🍌 Bananas: 3</text>\n  <text x=\"10\" y=\"90\">🍊 Oranges: 8</text>\n</svg>"}
    ]'::jsonb, 
    '[
        {"text": "Apples"},
        {"text": "Bananas"},
        {"text": "Oranges"}
    ]'::jsonb, 2, 'Oranges', 
    '[{"type": "text", "content": "Step 1: Compare the numbers 5, 3, and 8. Step 2: 8 is the largest number. Step 3: 8 corresponds to Oranges."}]'::jsonb, 
    'easy', 1
),

-- 3. Equality Comparison (Equal To)
(
    gen_random_uuid(), 'd939f2a2-4a80-4863-adca-e64790adb12b', 'mcq', 
    '[
        {"type": "text", "content": "Compare the number of Apples and Oranges. Apples are ________ to Oranges."},
        {"type": "svg", "content": "<svg width=\"200\" height=\"80\">\n  <rect x=\"10\" y=\"10\" width=\"80\" height=\"60\" fill=\"#fff\" stroke=\"#333\"/>\n  <text x=\"50\" y=\"35\" text-anchor=\"middle\">🍎</text>\n  <text x=\"50\" y=\"60\" text-anchor=\"middle\">5</text>\n  <rect x=\"110\" y=\"10\" width=\"80\" height=\"60\" fill=\"#fff\" stroke=\"#333\"/>\n  <text x=\"150\" y=\"35\" text-anchor=\"middle\">🍊</text>\n  <text x=\"150\" y=\"60\" text-anchor=\"middle\">5</text>\n</svg>"}
    ]'::jsonb, 
    '[
        {"text": "more than"},
        {"text": "less than"},
        {"text": "equal to"}
    ]'::jsonb, 2, 'equal to', 
    '[{"type": "text", "content": "Step 1: There are 5 apples. Step 2: There are 5 oranges. Step 3: Since 5 is the same as 5, they are equal."}]'::jsonb, 
    'easy', 1
),

-- 4. Less Than (Picture Counting)
(
    gen_random_uuid(), 'd939f2a2-4a80-4863-adca-e64790adb12b', 'fillInTheBlank', 
    '[
        {"type": "text", "content": "How many more Apples are there than Guavas?"},
        {"type": "svg", "content": "<svg width=\"220\" height=\"80\">\n  <text x=\"10\" y=\"30\">🍎 🍎 🍎 🍎 🍎 (5)</text>\n  <text x=\"10\" y=\"60\">🍐 🍐 (2)</text>\n</svg>"},
        {"id": "ans", "type": "input"}
    ]'::jsonb, 
    '[]'::jsonb, -1, '{"ans": "3"}', 
    '[{"type": "text", "content": "Step 1: Count Apples (5). Step 2: Count Guavas (2). Step 3: Subtract: 5 - 2 = 3."}]'::jsonb, 
    'medium', 1
),

-- 5. Least Liked Fruit
(
    gen_random_uuid(), 'd939f2a2-4a80-4863-adca-e64790adb12b', 'mcq', 
    '[
        {"type": "text", "content": "Which fruit is liked by the least (smallest) number of children?"},
        {"type": "svg", "content": "<svg width=\"220\" height=\"120\" viewBox=\"0 0 220 120\">\n  <rect x=\"10\" y=\"10\" width=\"180\" height=\"100\" fill=\"#fff\" stroke=\"#000\"/>\n  <text x=\"20\" y=\"40\">Apples: 5</text>\n  <text x=\"20\" y=\"70\">Bananas: 3</text>\n  <text x=\"20\" y=\"100\">Guava: 2</text>\n</svg>"}
    ]'::jsonb, 
    '[
        {"text": "Apples"},
        {"text": "Bananas"},
        {"text": "Guava"}
    ]'::jsonb, 2, 'Guava', 
    '[{"type": "text", "content": "Step 1: Look at the counts: 5, 3, and 2. Step 2: 2 is the smallest number. Step 3: 2 belongs to Guava."}]'::jsonb, 
    'easy', 1
);
