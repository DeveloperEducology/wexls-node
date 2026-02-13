-- 1. Day before Monday
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", 
    "is_multi_select", "correct_answer_index", 
    "correct_answer_text", "solution", "difficulty", "marks", 
    "drag_groups", "drag_items", "sub_topic", "complexity"
) VALUES (
    '8ede627c-ed91-4fe4-a185-80406ae8d2f6', 'mcq', 
    '[{"type": "text", "content": "Which day comes **before** Monday?"}]'::jsonb, 
    '[{"text": "Tuesday"}, {"text": "Saturday"}, {"text": "Sunday"}, {"text": "Friday"}]'::jsonb, 
    FALSE, 2, '{"ans": "Sunday"}', 
    '[{"type": "text", "content": "Sunday is the day before Monday."}]'::jsonb, 
    'easy', 1, '[]'::jsonb, '[]'::jsonb, 'Days of the Week', 20
);

-- 2. Day after Sunday
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", 
    "is_multi_select", "correct_answer_index", 
    "correct_answer_text", "solution", "difficulty", "marks", 
    "drag_groups", "drag_items", "sub_topic", "complexity"
) VALUES (
    '8ede627c-ed91-4fe4-a185-80406ae8d2f6', 'mcq', 
    '[{"type": "text", "content": "Which day comes **after** Sunday?"}]'::jsonb, 
    '[{"text": "Tuesday"}, {"text": "Monday"}, {"text": "Wednesday"}, {"text": "Friday"}]'::jsonb, 
    FALSE, 1, '{"ans": "Monday"}', 
    '[{"type": "text", "content": "The week starts with Monday after Sunday."}]'::jsonb, 
    'easy', 1, '[]'::jsonb, '[]'::jsonb, 'Days of the Week', 20
);

-- 3. Between Monday and Wednesday
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", 
    "is_multi_select", "correct_answer_index", 
    "correct_answer_text", "solution", "difficulty", "marks", 
    "drag_groups", "drag_items", "sub_topic", "complexity"
) VALUES (
    '8ede627c-ed91-4fe4-a185-80406ae8d2f6', 'mcq', 
    '[{"type": "text", "content": "Which day falls between **Monday** and **Wednesday**?"}]'::jsonb, 
    '[{"text": "Thursday"}, {"text": "Tuesday"}, {"text": "Friday"}, {"text": "Sunday"}]'::jsonb, 
    FALSE, 1, '{"ans": "Tuesday"}', 
    '[{"type": "text", "content": "The order is Monday, **Tuesday**, Wednesday."}]'::jsonb, 
    'medium', 1, '[]'::jsonb, '[]'::jsonb, 'Days of the Week', 30
);

-- 4. Between Thursday and Saturday
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", 
    "is_multi_select", "correct_answer_index", 
    "correct_answer_text", "solution", "difficulty", "marks", 
    "drag_groups", "drag_items", "sub_topic", "complexity"
) VALUES (
    '8ede627c-ed91-4fe4-a185-80406ae8d2f6', 'mcq', 
    '[{"type": "text", "content": "Which day is between **Thursday** and **Saturday**?"}]'::jsonb, 
    '[{"text": "Sunday"}, {"text": "Wednesday"}, {"text": "Friday"}, {"text": "Monday"}]'::jsonb, 
    FALSE, 2, '{"ans": "Friday"}', 
    '[{"type": "text", "content": "The order is Thursday, **Friday**, Saturday."}]'::jsonb, 
    'medium', 1, '[]'::jsonb, '[]'::jsonb, 'Days of the Week', 30
);

-- 5. Day before Wednesday
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", 
    "is_multi_select", "correct_answer_index", 
    "correct_answer_text", "solution", "difficulty", "marks", 
    "drag_groups", "drag_items", "sub_topic", "complexity"
) VALUES (
    '8ede627c-ed91-4fe4-a185-80406ae8d2f6', 'mcq', 
    '[{"type": "text", "content": "What day comes **before** Wednesday?"}]'::jsonb, 
    '[{"text": "Monday"}, {"text": "Tuesday"}, {"text": "Thursday"}, {"text": "Friday"}]'::jsonb, 
    FALSE, 1, '{"ans": "Tuesday"}', 
    '[{"type": "text", "content": "Tuesday comes right before Wednesday."}]'::jsonb, 
    'easy', 1, '[]'::jsonb, '[]'::jsonb, 'Days of the Week', 20
);

-- 6. Day after Monday
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", 
    "is_multi_select", "correct_answer_index", 
    "correct_answer_text", "solution", "difficulty", "marks", 
    "drag_groups", "drag_items", "sub_topic", "complexity"
) VALUES (
    '8ede627c-ed91-4fe4-a185-80406ae8d2f6', 'mcq', 
    '[{"type": "text", "content": "What day comes **after** Monday?"}]'::jsonb, 
    '[{"text": "Sunday"}, {"text": "Wednesday"}, {"text": "Tuesday"}, {"text": "Thursday"}]'::jsonb, 
    FALSE, 2, '{"ans": "Tuesday"}', 
    '[{"type": "text", "content": "Tuesday comes right after Monday."}]'::jsonb, 
    'easy', 1, '[]'::jsonb, '[]'::jsonb, 'Days of the Week', 20
);

-- 7. Day before Sunday
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", 
    "is_multi_select", "correct_answer_index", 
    "correct_answer_text", "solution", "difficulty", "marks", 
    "drag_groups", "drag_items", "sub_topic", "complexity"
) VALUES (
    '8ede627c-ed91-4fe4-a185-80406ae8d2f6', 'mcq', 
    '[{"type": "text", "content": "What day comes **before** Sunday?"}]'::jsonb, 
    '[{"text": "Friday"}, {"text": "Saturday"}, {"text": "Monday"}, {"text": "Tuesday"}]'::jsonb, 
    FALSE, 1, '{"ans": "Saturday"}', 
    '[{"type": "text", "content": "Saturday is the day before Sunday."}]'::jsonb, 
    'easy', 1, '[]'::jsonb, '[]'::jsonb, 'Days of the Week', 20
);

-- 8. Day after Thursday
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", 
    "is_multi_select", "correct_answer_index", 
    "correct_answer_text", "solution", "difficulty", "marks", 
    "drag_groups", "drag_items", "sub_topic", "complexity"
) VALUES (
    '8ede627c-ed91-4fe4-a185-80406ae8d2f6', 'mcq', 
    '[{"type": "text", "content": "What day comes **after** Thursday?"}]'::jsonb, 
    '[{"text": "Wednesday"}, {"text": "Saturday"}, {"text": "Sunday"}, {"text": "Friday"}]'::jsonb, 
    FALSE, 3, '{"ans": "Friday"}', 
    '[{"type": "text", "content": "Friday comes after Thursday."}]'::jsonb, 
    'easy', 1, '[]'::jsonb, '[]'::jsonb, 'Days of the Week', 20
);

-- 9. Tomorrow if today is Tuesday
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", 
    "is_multi_select", "correct_answer_index", 
    "correct_answer_text", "solution", "difficulty", "marks", 
    "drag_groups", "drag_items", "sub_topic", "complexity"
) VALUES (
    '8ede627c-ed91-4fe4-a185-80406ae8d2f6', 'mcq', 
    '[{"type": "text", "content": "If today is **Tuesday**, what day is tomorrow?"}]'::jsonb, 
    '[{"text": "Monday"}, {"text": "Thursday"}, {"text": "Wednesday"}, {"text": "Friday"}]'::jsonb, 
    FALSE, 2, '{"ans": "Wednesday"}', 
    '[{"type": "text", "content": "The day after Tuesday is Wednesday."}]'::jsonb, 
    'medium', 1, '[]'::jsonb, '[]'::jsonb, 'Days of the Week', 30
);

-- 10. Today if yesterday was Friday
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", 
    "is_multi_select", "correct_answer_index", 
    "correct_answer_text", "solution", "difficulty", "marks", 
    "drag_groups", "drag_items", "sub_topic", "complexity"
) VALUES (
    '8ede627c-ed91-4fe4-a185-80406ae8d2f6', 'mcq', 
    '[{"type": "text", "content": "If yesterday was **Friday**, what day is today?"}]'::jsonb, 
    '[{"text": "Sunday"}, {"text": "Thursday"}, {"text": "Saturday"}, {"text": "Monday"}]'::jsonb, 
    FALSE, 2, '{"ans": "Saturday"}', 
    '[{"type": "text", "content": "The day after Friday is Saturday."}]'::jsonb, 
    'medium', 1, '[]'::jsonb, '[]'::jsonb, 'Days of the Week', 30
);

-- 11. Two days after Monday
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", 
    "is_multi_select", "correct_answer_index", 
    "correct_answer_text", "solution", "difficulty", "marks", 
    "drag_groups", "drag_items", "sub_topic", "complexity"
) VALUES (
    '8ede627c-ed91-4fe4-a185-80406ae8d2f6', 'mcq', 
    '[{"type": "text", "content": "What day comes **two days after** Monday?"}]'::jsonb, 
    '[{"text": "Tuesday"}, {"text": "Thursday"}, {"text": "Wednesday"}, {"text": "Friday"}]'::jsonb, 
    FALSE, 2, '{"ans": "Wednesday"}', 
    '[{"type": "text", "content": "One day after Monday is Tuesday. Two days after Monday is Wednesday."}]'::jsonb, 
    'hard', 1, '[]'::jsonb, '[]'::jsonb, 'Days of the Week', 40
);

-- 12. Day between Friday and Sunday
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", 
    "is_multi_select", "correct_answer_index", 
    "correct_answer_text", "solution", "difficulty", "marks", 
    "drag_groups", "drag_items", "sub_topic", "complexity"
) VALUES (
    '8ede627c-ed91-4fe4-a185-80406ae8d2f6', 'mcq', 
    '[{"type": "text", "content": "Which day is between **Friday** and **Sunday**?"}]'::jsonb, 
    '[{"text": "Monday"}, {"text": "Thursday"}, {"text": "Saturday"}, {"text": "Tuesday"}]'::jsonb, 
    FALSE, 2, '{"ans": "Saturday"}', 
    '[{"type": "text", "content": "The order is Friday, **Saturday**, Sunday."}]'::jsonb, 
    'medium', 1, '[]'::jsonb, '[]'::jsonb, 'Days of the Week', 30
);

-- 13. [Multi-Select] Days starting with T
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", 
    "is_multi_select", "correct_answer_indices", 
    "correct_answer_text", "solution", "difficulty", "marks", 
    "drag_groups", "drag_items", "sub_topic", "complexity"
) VALUES (
    '8ede627c-ed91-4fe4-a185-80406ae8d2f6', 'mcq', 
    '[{"type": "text", "content": "Select the **two** days that start with the letter **T**."}]'::jsonb, 
    '[{"text": "Tuesday"}, {"text": "Monday"}, {"text": "Thursday"}, {"text": "Friday"}]'::jsonb, 
    TRUE, '[0, 2]'::jsonb, '{"ans": ["Tuesday", "Thursday"]}', 
    '[{"type": "text", "content": "Tuesday and Thursday both start with the letter T."}]'::jsonb, 
    'medium', 1, '[]'::jsonb, '[]'::jsonb, 'Days of the Week', 35
);

-- 14. [Multi-Select] Weekend days
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", 
    "is_multi_select", "correct_answer_indices", 
    "correct_answer_text", "solution", "difficulty", "marks", 
    "drag_groups", "drag_items", "sub_topic", "complexity"
) VALUES (
    '8ede627c-ed91-4fe4-a185-80406ae8d2f6', 'mcq', 
    '[{"type": "text", "content": "Which days are part of the **weekend**?"}]'::jsonb, 
    '[{"text": "Monday"}, {"text": "Saturday"}, {"text": "Wednesday"}, {"text": "Sunday"}]'::jsonb, 
    TRUE, '[1, 3]'::jsonb, '{"ans": ["Saturday", "Sunday"]}', 
    '[{"type": "text", "content": "The weekend consists of Saturday and Sunday."}]'::jsonb, 
    'medium', 1, '[]'::jsonb, '[]'::jsonb, 'Days of the Week', 35
);

-- 15. Yesterday if today is Saturday
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", 
    "is_multi_select", "correct_answer_index", 
    "correct_answer_text", "solution", "difficulty", "marks", 
    "drag_groups", "drag_items", "sub_topic", "complexity"
) VALUES (
    '8ede627c-ed91-4fe4-a185-80406ae8d2f6', 'mcq', 
    '[{"type": "text", "content": "If today is **Saturday**, what day was **yesterday**?"}]'::jsonb, 
    '[{"text": "Sunday"}, {"text": "Friday"}, {"text": "Thursday"}, {"text": "Monday"}]'::jsonb, 
    FALSE, 1, '{"ans": "Friday"}', 
    '[{"type": "text", "content": "The day before Saturday is Friday."}]'::jsonb, 
    'medium', 1, '[]'::jsonb, '[]'::jsonb, 'Days of the Week', 30
);
