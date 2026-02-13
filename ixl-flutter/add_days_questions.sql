-- Question 1: What day comes after Wednesday?
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", 
    "is_multi_select", "correct_answer_index", 
    "correct_answer_text", "solution", "difficulty", "marks", 
    "drag_groups", "drag_items", "sub_topic", "complexity"
) VALUES (
    '8ede627c-ed91-4fe4-a185-80406ae8d2f6', 
    'mcq', 
    '[{"type": "text", "content": "Which day comes after **Wednesday**?"}]'::jsonb, 
    '[
        {"text": "Monday"}, {"text": "Friday"}, {"text": "Thursday"}, 
        {"text": "Tuesday"}, {"text": "Saturday"}, {"text": "Sunday"}
    ]'::jsonb, 
    FALSE, 
    2, -- Thursday is at index 2
    '{"ans": "Thursday"}', 
    '[{"type": "text", "content": "The order of days is Wednesday, then Thursday."}]'::jsonb, 
    'easy', 1, '[]'::jsonb, '[]'::jsonb, 'Days of the Week', 20
);

-- Question 2: What day comes before Friday?
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", 
    "is_multi_select", "correct_answer_index", 
    "correct_answer_text", "solution", "difficulty", "marks", 
    "drag_groups", "drag_items", "sub_topic", "complexity"
) VALUES (
    '8ede627c-ed91-4fe4-a185-80406ae8d2f6', 
    'mcq', 
    '[{"type": "text", "content": "Which day comes before **Friday**?"}]'::jsonb, 
    '[
        {"text": "Tuesday"}, {"text": "Wednesday"}, {"text": "Monday"}, 
        {"text": "Thursday"}, {"text": "Saturday"}, {"text": "Sunday"}
    ]'::jsonb, 
    FALSE, 
    3, -- Thursday is at index 3
    '{"ans": "Thursday"}', 
    '[{"type": "text", "content": "Thursday is the day that comes immediately before Friday."}]'::jsonb, 
    'easy', 1, '[]'::jsonb, '[]'::jsonb, 'Days of the Week', 20
);

-- Question 3: What day comes after Saturday?
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", 
    "is_multi_select", "correct_answer_index", 
    "correct_answer_text", "solution", "difficulty", "marks", 
    "drag_groups", "drag_items", "sub_topic", "complexity"
) VALUES (
    '8ede627c-ed91-4fe4-a185-80406ae8d2f6', 
    'mcq', 
    '[{"type": "text", "content": "Which day comes after **Saturday**?"}]'::jsonb, 
    '[
        {"text": "Sunday"}, {"text": "Monday"}, {"text": "Friday"}, 
        {"text": "Wednesday"}, {"text": "Tuesday"}, {"text": "Thursday"}
    ]'::jsonb, 
    FALSE, 
    0, -- Sunday is at index 0
    '{"ans": "Sunday"}', 
    '[{"type": "text", "content": "After Saturday, the week starts over with Sunday."}]'::jsonb, 
    'easy', 1, '[]'::jsonb, '[]'::jsonb, 'Days of the Week', 20
);
