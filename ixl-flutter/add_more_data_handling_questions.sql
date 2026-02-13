-- ====================================================================
-- BATCH INSERT: DATA HANDLING QUESTIONS (PART 2)
-- Micro-skill ID: 7807b899-df98-41c3-8eb0-1165b52db286
-- ====================================================================

INSERT INTO "public"."questions" (
    "id", "micro_skill_id", "type", "parts", "options", 
    "correct_answer_index", "correct_answer_text", "solution", "difficulty", "complexity", "sub_topic", "marks"
) VALUES 

-- 7. Tally Marks Interpretation (Easy, Complexity 30)
(
    gen_random_uuid(), 
    '7807b899-df98-41c3-8eb0-1165b52db286', 
    'mcq', 
    '[
        {"type": "text", "content": "Count the tally marks for **Blue** team:"},
        {"type": "svg", "content": "<svg width=\"300\" height=\"120\" xmlns=\"http://www.w3.org/2000/svg\"><style>.t { font: 16px sans-serif; }</style><rect width=\"300\" height=\"120\" rx=\"8\" fill=\"#fff\" stroke=\"#888\"/><line x1=\"0\" y1=\"40\" x2=\"300\" y2=\"40\" stroke=\"#eee\"/><line x1=\"0\" y1=\"80\" x2=\"300\" y2=\"80\" stroke=\"#eee\"/><text x=\"20\" y=\"25\" class=\"t\" font-weight=\"bold\">Team</text><text x=\"150\" y=\"25\" class=\"t\" font-weight=\"bold\">Points</text><text x=\"20\" y=\"65\" class=\"t\" fill=\"red\">Red</text><text x=\"150\" y=\"65\" class=\"t\">|||| (4)</text><text x=\"20\" y=\"105\" class=\"t\" fill=\"blue\">Blue</text><text x=\"150\" y=\"105\" class=\"t\">||||| || (Wait, 5+2)</text><!-- Drawing Tally for 7: Group of 5, then 2 --><path d=\"M150 95 v20 M155 95 v20 M160 95 v20 M165 95 v20 M148 115 L167 95\" stroke=\"black\" stroke-width=\"2\"/><path d=\"M180 95 v20 M185 95 v20\" stroke=\"black\" stroke-width=\"2\"/></svg>"},
        {"type": "text", "content": "How many points does Blue team have?"}
    ]'::jsonb, 
    '["5", "6", "7", "8"]'::jsonb, 
    2, 
    null, 
    '[
        {"type": "text", "content": "A group with a diagonal line is 5."},
        {"type": "text", "content": "5 + 2 extra lines = 7."}
    ]'::jsonb, 
    'easy', 
    30,
    'Tally Marks',
    '1'
),

-- 8. Pictograph Scale (Medium, Complexity 60)
(
    gen_random_uuid(), 
    '7807b899-df98-41c3-8eb0-1165b52db286', 
    'mcq', 
    '[
        {"type": "text", "content": "Favorite Ice Cream Flavors:"},
        {"type": "svg", "content": "<svg width=\"300\" height=\"150\" xmlns=\"http://www.w3.org/2000/svg\"><text x=\"220\" y=\"20\" font-size=\"12\" fill=\"#666\">⭐ = 2 votes</text><rect x=\"10\" y=\"30\" width=\"280\" height=\"40\" fill=\"#fce4ec\" rx=\"5\"/><text x=\"20\" y=\"55\" font-size=\"14\">Vanilla</text><text x=\"100\" y=\"55\" font-size=\"20\">⭐⭐⭐</text><rect x=\"10\" y=\"80\" width=\"280\" height=\"40\" fill=\"#e0f7fa\" rx=\"5\"/><text x=\"20\" y=\"105\" font-size=\"14\">Choco</text><text x=\"100\" y=\"105\" font-size=\"20\">⭐⭐⭐⭐</text></svg>"},
        {"type": "text", "content": "If each ⭐ stands for **2 votes**, how many people liked **Vanilla**?"}
    ]'::jsonb, 
    '["3", "5", "6", "8"]'::jsonb, 
    2, 
    null, 
    '[
        {"type": "text", "content": "There are 3 stars for Vanilla."},
        {"type": "text", "content": "Each star = 2 votes."},
        {"type": "text", "content": "3 x 2 = 6 votes."}
    ]'::jsonb, 
    'medium', 
    60,
    'Pictographs',
    '1'
),

-- 9. Completing the Table (Medium, Complexity 70)
(
    gen_random_uuid(), 
    '7807b899-df98-41c3-8eb0-1165b52db286', 
    'textInput', 
    '[
        {"type": "text", "content": "Look at the incomplete table:"},
        {"type": "svg", "content": "<svg width=\"250\" height=\"120\" xmlns=\"http://www.w3.org/2000/svg\"><rect width=\"250\" height=\"120\" fill=\"white\" stroke=\"black\"/><line x1=\"0\" y1=\"40\" x2=\"250\" y2=\"40\" stroke=\"black\"/><line x1=\"125\" y1=\"0\" x2=\"125\" y2=\"120\" stroke=\"black\"/><text x=\"62\" y=\"25\" text-anchor=\"middle\" font-weight=\"bold\">Item</text><text x=\"187\" y=\"25\" text-anchor=\"middle\" font-weight=\"bold\">Cost</text><text x=\"62\" y=\"70\" text-anchor=\"middle\">Pencil</text><text x=\"187\" y=\"70\" text-anchor=\"middle\">₹5</text><text x=\"62\" y=\"105\" text-anchor=\"middle\">Eraser</text><text x=\"187\" y=\"105\" text-anchor=\"middle\">?</text></svg>"},
        {"type": "text", "content": "If the **total cost** of a Pencil and Eraser is ₹8, what is the cost of the Eraser?"}
    ]'::jsonb, 
    null, 
    null, 
    '{"exact": "3"}'::jsonb, 
    '[
        {"type": "text", "content": "Total = ₹8. Pencil = ₹5."},
        {"type": "text", "content": "Eraser = 8 - 5 = ₹3."}
    ]'::jsonb, 
    'medium', 
    70,
    'Logical Reasoning',
    '1'
),

-- 10. Bar Chart Difference (Hard, Complexity 90)
(
    gen_random_uuid(), 
    '7807b899-df98-41c3-8eb0-1165b52db286', 
    'mcq', 
    '[
        {"type": "text", "content": "Points scored in a game:"},
        {"type": "svg", "content": "<svg width=\"300\" height=\"150\" xmlns=\"http://www.w3.org/2000/svg\"><line x1=\"40\" y1=\"130\" x2=\"280\" y2=\"130\" stroke=\"black\"/><line x1=\"40\" y1=\"130\" x2=\"40\" y2=\"10\" stroke=\"black\"/><text x=\"20\" y=\"130\">0</text><text x=\"20\" y=\"80\">10</text><text x=\"20\" y=\"30\">20</text><rect x=\"60\" y=\"30\" width=\"40\" height=\"100\" fill=\"#4caf50\"/><text x=\"65\" y=\"145\">Sam</text><text x=\"70\" y=\"25\">20</text><rect x=\"130\" y=\"55\" width=\"40\" height=\"75\" fill=\"#2196f3\"/><text x=\"135\" y=\"145\">Tom</text><text x=\"140\" y=\"50\">15</text><rect x=\"200\" y=\"80\" width=\"40\" height=\"50\" fill=\"#ff9800\"/><text x=\"205\" y=\"145\">Max</text><text x=\"210\" y=\"75\">10</text></svg>"},
        {"type": "text", "content": "How many **more** points did Sam score than Max?"}
    ]'::jsonb, 
    '["5", "10", "15", "20"]'::jsonb, 
    1, 
    null, 
    '[
        {"type": "text", "content": "Sam scored 20 points."},
        {"type": "text", "content": "Max scored 10 points."},
        {"type": "text", "content": "Difference = 20 - 10 = 10."}
    ]'::jsonb, 
    'hard', 
    90,
    'Bar Graphs',
    '1'
);
