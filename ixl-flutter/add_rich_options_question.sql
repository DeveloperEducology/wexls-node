INSERT INTO questions (micro_skill_id, type, parts, options, correct_answer_index, difficulty) 
VALUES (
    'e982adb6-851d-4498-9d3f-48a2f1e2abf2', -- Same placeholder Skill ID
    'imageChoice',
    '[
        {"type": "text", "content": "Choose the animal that says **Meow**."}
    ]'::jsonb,
    '[
        {"text": "Dog", "imageUrl": "https://cdn-icons-png.flaticon.com/512/616/616408.png"},
        {"text": "Cat", "imageUrl": "https://cdn-icons-png.flaticon.com/512/616/616430.png"},
        {"text": "Bird", "imageUrl": "https://cdn-icons-png.flaticon.com/512/3069/3069172.png"}
    ]'::jsonb, 
    1, -- Cat
    'easy'
);
