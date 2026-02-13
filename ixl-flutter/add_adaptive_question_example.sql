-- Example of creating an 'Adaptive' Question
-- This question deliberately sets the 'sub_topic' and 'complexity' fields.

-- Skill: Patterns (using previous skill ID as placeholder)
-- Sub-topic: 'identifying_shapes'
-- Complexity: 20 (Easy-ish, on a scale of 0-100)

INSERT INTO questions (
    micro_skill_id, 
    type, 
    parts, 
    options, 
    correct_answer_index, 
    solution, 
    difficulty, 
    marks,
    sub_topic,    -- NEW: Granular topic tag
    complexity    -- NEW: Granular difficulty score (0-100)
) VALUES (
    'b74172ec-421b-4901-b1a6-388d3db61f87', -- Replace with your actual Skill ID
    'mcq', 
    '[
        {"type": "text", "content": "Which shape comes next in the pattern?"},
        {"type": "sequence", "children": [
             {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/3209/3209265.png", "width": 50}, -- Circle
             {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/3209/3209203.png", "width": 50}, -- Square
             {"type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/3209/3209265.png", "width": 50}, -- Circle
             {"type": "text", "content": "?"}
        ]}
    ]'::jsonb, 
    '[
        {"text": "Square", "imageUrl": "https://cdn-icons-png.flaticon.com/512/3209/3209203.png"}, 
        {"text": "Triangle", "imageUrl": "https://cdn-icons-png.flaticon.com/512/3209/3209228.png"}
    ]'::jsonb, 
    0, -- Index 0 (Square) is correct
    'The pattern goes Circle, Square, Circle... so the next shape is Square.', 
    'easy', 
    1,
    'pattern_recognition_shapes', -- sub_topic
    20                            -- complexity
);
