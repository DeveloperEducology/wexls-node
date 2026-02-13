-- Batch Insert Money Questions (Multi-Select)

-- 1. Buying a Notebook (20 + 10)
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", 
    "is_multi_select", "correct_answer_indices", 
    "correct_answer_text", "solution", "difficulty", "marks", 
    "drag_groups", "drag_items", "sub_topic", "complexity"
) VALUES (
    'c8834510-7aa3-45e1-8ab7-f993e32c3dcb', 
    'mcq', 
    '[{"type": "text", "content": "A notebook costs ₹30. Select the TWO notes you need to pay the exact amount:"}, {"type": "image", "height": 100, "imageUrl": "https://cdn-icons-png.flaticon.com/512/3232/3232902.png"}]'::jsonb, 
    '[
        {"text": "20 Rupees", "imageUrl": "https://pub-463c5e524a144b19b1f98c36673af4d9.r2.dev/money/20rsnote.jpeg"},
        {"text": "100 Rupees", "imageUrl": "https://pub-463c5e524a144b19b1f98c36673af4d9.r2.dev/money/100rsnot.png"},
        {"text": "10 Rupees", "imageUrl": "https://pub-463c5e524a144b19b1f98c36673af4d9.r2.dev/money/10rsnote.png"},
        {"text": "50 Rupees", "imageUrl": "https://pub-463c5e524a144b19b1f98c36673af4d9.r2.dev/money/50rsnote.jpg"}
    ]'::jsonb, 
    TRUE, 
    '[0, 2]'::jsonb, 
    '{"ans": ["20 Rupees", "10 Rupees"]}', 
    '[{"type": "text", "content": "Step 1: Look at the price (₹30). Step 2: Combine the ₹20 note and the ₹10 note. 20 + 10 = 30."}]'::jsonb, 
    'hard', 1, '[]'::jsonb, '[]'::jsonb, 'Buying with Multiple Notes', 65
);

-- 2. Buying a Pen (10 + 5)
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", 
    "is_multi_select", "correct_answer_indices", 
    "correct_answer_text", "solution", "difficulty", "marks", 
    "drag_groups", "drag_items", "sub_topic", "complexity"
) VALUES (
    'c8834510-7aa3-45e1-8ab7-f993e32c3dcb', 
    'mcq', 
    '[{"type": "text", "content": "A pen costs ₹15. Select the note and the coin you need to buy it:"}, {"type": "image", "height": 100, "imageUrl": "https://cdn-icons-png.flaticon.com/512/589/589061.png"}]'::jsonb, 
    '[
        {"text": "5 Rupees", "imageUrl": "https://pub-463c5e524a144b19b1f98c36673af4d9.r2.dev/money/5rupee.jpg"},
        {"text": "10 Rupees Note", "imageUrl": "https://pub-463c5e524a144b19b1f98c36673af4d9.r2.dev/money/10rsnote.png"},
        {"text": "2 Rupees", "imageUrl": "https://pub-463c5e524a144b19b1f98c36673af4d9.r2.dev/money/2rupe.jpg"},
        {"text": "50 Rupees", "imageUrl": "https://pub-463c5e524a144b19b1f98c36673af4d9.r2.dev/money/50rsnote.jpg"}
    ]'::jsonb, 
    TRUE, 
    '[0, 1]'::jsonb, 
    '{"ans": ["5 Rupees", "10 Rupees Note"]}', 
    '[{"type": "text", "content": "Step 1: The pen is ₹15. Step 2: Use the ₹10 note and the ₹5 coin. 10 + 5 = 15."}]'::jsonb, 
    'hard', 1, '[]'::jsonb, '[]'::jsonb, 'Buying with Mixed Currency', 60
);
