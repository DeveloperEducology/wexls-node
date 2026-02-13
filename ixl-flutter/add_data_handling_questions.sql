-- ====================================================================
-- BATCH INSERT: DATA HANDLING QUESTIONS
-- Micro-skill ID: 7807b899-df98-41c3-8eb0-1165b52db286
-- ====================================================================

-- DELETE PREVIOUS TO AVOID DUPLICATES
DELETE FROM "public"."questions" WHERE "micro_skill_id" = '7807b899-df98-41c3-8eb0-1165b52db286';

INSERT INTO "public"."questions" (
    "id", "micro_skill_id", "type", "parts", "options", 
    "correct_answer_index", "correct_answer_text", "solution", "difficulty", "complexity", "sub_topic", "marks"
) VALUES 
-- 1. Simple Bar Chart Interpretation (Easy, Complexity 10)
(
    gen_random_uuid(), 
    '7807b899-df98-41c3-8eb0-1165b52db286', 
    'mcq', 
    '[
        {"type": "text", "content": "Look at the data below regarding favorite fruits:"},
        {"type": "text", "content": "🍎 Apples: 5 | 🍌 Bananas: 8 | 🍇 Grapes: 3"},
        {"type": "text", "content": "How many children chose **Bananas**?"}
    ]'::jsonb, 
    '["5", "8", "3", "16"]'::jsonb, 
    1, 
    null, 
    '[
        {"type": "text", "content": "The data shows clearly: Bananas: 8."}
    ]'::jsonb, 
    'easy', 
    10,
    'Reading Data',
    '1'
),

-- 2. Finding the Least (Easy, Complexity 25)
(
    gen_random_uuid(), 
    '7807b899-df98-41c3-8eb0-1165b52db286', 
    'mcq', 
    '[
        {"type": "text", "content": "Look at the votes for class monitor:"},
        {"type": "text", "content": "Rohan: |||| (4)\nSita: |||||| (6)\nAli: ||| (3)"},
        {"type": "text", "content": "Who got the **least** number of votes?"}
    ]'::jsonb, 
    '["Rohan", "Sita", "Ali"]'::jsonb, 
    2, 
    null, 
    '[
        {"type": "text", "content": "Comparing numbers: 4, 6, 3."},
        {"type": "text", "content": "3 is the smallest number. So, **Ali** got the least votes."}
    ]'::jsonb, 
    'easy', 
    25,
    'Comparing Data',
    '1'
),

-- 3. Total Calculation (Medium, Complexity 50)
(
    gen_random_uuid(), 
    '7807b899-df98-41c3-8eb0-1165b52db286', 
    'mcq', 
    '[
        {"type": "text", "content": "Look at the toys in the box:"},
        {"type": "text", "content": "🚗 Cars: 4\n⚽ Balls: 3\n🧸 Dolls: 2"},
        {"type": "text", "content": "How many toys are there **in total**?"}
    ]'::jsonb, 
    '["7", "9", "5", "8"]'::jsonb, 
    1, 
    null, 
    '[
        {"type": "text", "content": "To find the total, add them all up: 4 + 3 + 2."},
        {"type": "text", "content": "4 + 3 = 7. Then 7 + 2 = 9."}
    ]'::jsonb, 
    'medium', 
    50,
    'Simple Calculations',
    '1'
),

-- 4. SVG Chart Reading (Medium, Complexity 65)
(
    gen_random_uuid(), 
    '7807b899-df98-41c3-8eb0-1165b52db286', 
    'mcq', 
    '[
        {"type": "text", "content": "Look at the height chart. Who is the tallest?"},
        {"type": "svg", "content": "<svg width=\"200\" height=\"150\"><rect x=\"20\" y=\"80\" width=\"30\" height=\"70\" fill=\"orange\"/><text x=\"25\" y=\"165\">A</text><text x=\"25\" y=\"75\">70</text><rect x=\"70\" y=\"50\" width=\"30\" height=\"100\" fill=\"purple\"/><text x=\"75\" y=\"165\">B</text><text x=\"75\" y=\"45\">100</text><rect x=\"120\" y=\"70\" width=\"30\" height=\"80\" fill=\"cyan\"/><text x=\"125\" y=\"165\">C</text><text x=\"125\" y=\"65\">80</text></svg>"},
        {"type": "text", "content": "Bar A = 70cm, Bar B = 100cm, Bar C = 80cm. Choose the tallest."}
    ]'::jsonb, 
    '["A", "B", "C"]'::jsonb, 
    1, 
    null, 
    '[
        {"type": "text", "content": "Look for the tallest bar or highest number."},
        {"type": "text", "content": "B is 100cm, which is taller than 70 and 80. So **B** is consistent."}
    ]'::jsonb, 
    'medium', 
    65,
    'Visual Interpretation',
    '1'
),

-- 5. Comparison - How many more? (Hard, Complexity 80)
(
    gen_random_uuid(), 
    '7807b899-df98-41c3-8eb0-1165b52db286', 
    'mcq', 
    '[
        {"type": "text", "content": "Favorite Pets:"},
        {"type": "text", "content": "🐶 Dogs: 10"},
        {"type": "text", "content": "🐱 Cats: 6"},
        {"type": "text", "content": "How many **more** students like Dogs than Cats?"}
    ]'::jsonb, 
    '["4", "16", "6", "10"]'::jsonb, 
    0, 
    null, 
    '[
        {"type": "text", "content": "We need to find the difference between Dogs (10) and Cats (6)."},
        {"type": "text", "content": "10 - 6 = 4."}
    ]'::jsonb, 
    'hard', 
    80,
    'Calculations',
    '1'
),

-- 6. Contextual Input (Hard, Complexity 95)
-- Converted Table to SVG and Type to textInput
(
    gen_random_uuid(), 
    '7807b899-df98-41c3-8eb0-1165b52db286', 
    'textInput', 
    '[
        {"type": "text", "content": "Use the Reading Log table to answer:"},
        {"type": "svg", "content": "<svg width=\"300\" height=\"150\" xmlns=\"http://www.w3.org/2000/svg\">\n  <!-- Background -->\n  <rect width=\"300\" height=\"150\" rx=\"10\" fill=\"#f0f8ff\" stroke=\"#4a90e2\" stroke-width=\"2\"/>\n  \n  <!-- Headers -->\n  <rect x=\"20\" y=\"20\" width=\"120\" height=\"30\" fill=\"#4a90e2\" rx=\"5\"/>\n  <text x=\"80\" y=\"40\" font-family=\"Arial\" font-size=\"14\" fill=\"white\" text-anchor=\"middle\" dominant-baseline=\"middle\">Day</text>\n  \n  <rect x=\"160\" y=\"20\" width=\"120\" height=\"30\" fill=\"#4a90e2\" rx=\"5\"/>\n  <text x=\"220\" y=\"40\" font-family=\"Arial\" font-size=\"14\" fill=\"white\" text-anchor=\"middle\" dominant-baseline=\"middle\">Books Read</text>\n  \n  <!-- Row 1 -->\n  <text x=\"80\" y=\"70\" font-family=\"Arial\" font-size=\"14\" fill=\"#333\" text-anchor=\"middle\">Mon</text>\n  <text x=\"220\" y=\"70\" font-family=\"Arial\" font-size=\"14\" fill=\"#333\" text-anchor=\"middle\">2</text>\n  <line x1=\"20\" y1=\"80\" x2=\"280\" y2=\"80\" stroke=\"#ccc\" stroke-width=\"1\"/>\n  \n  <!-- Row 2 -->\n  <text x=\"80\" y=\"100\" font-family=\"Arial\" font-size=\"14\" fill=\"#333\" text-anchor=\"middle\">Tue</text>\n  <text x=\"220\" y=\"100\" font-family=\"Arial\" font-size=\"14\" fill=\"#333\" text-anchor=\"middle\">5</text>\n  <line x1=\"20\" y1=\"110\" x2=\"280\" y2=\"110\" stroke=\"#ccc\" stroke-width=\"1\"/>\n  \n  <!-- Row 3 -->\n  <text x=\"80\" y=\"130\" font-family=\"Arial\" font-size=\"14\" fill=\"#333\" text-anchor=\"middle\">Wed</text>\n  <text x=\"220\" y=\"130\" font-family=\"Arial\" font-size=\"14\" fill=\"#d0021b\" font-weight=\"bold\" text-anchor=\"middle\">?</text>\n</svg>"},
        {"type": "text", "content": "If the total books read in 3 days is 10, how many were read on Wednesday?"}
    ]'::jsonb, 
    null, 
    null, 
    '{"exact": "3"}'::jsonb, 
    '[
        {"type": "text", "content": "Total is 10."},
        {"type": "text", "content": "Mon + Tue = 2 + 5 = 7."},
        {"type": "text", "content": "Wed = Total - 7 = 3."}
    ]'::jsonb, 
    'hard', 
    95,
    'Logical Reasoning',
    '1'
);
