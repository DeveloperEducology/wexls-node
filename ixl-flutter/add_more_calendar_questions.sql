-- =============================================
-- 15 New Calendar & Time Questions
-- Micro-skill ID: 3258a85f-26c5-4565-8e56-b612ec6656b6
-- =============================================

-- --- SET A: General Calendar Knowledge (No Image needed) ---

-- 1. Month after April
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", "is_multi_select", "correct_answer_index", "correct_answer_text", "solution", "difficulty", "marks", "sub_topic", "complexity"
) VALUES (
    '3258a85f-26c5-4565-8e56-b612ec6656b6', 'mcq', 
    '[{"type": "text", "content": "Which month comes immediately after **April**?"}]'::jsonb, 
    '[{"text": "March"}, {"text": "May"}, {"text": "June"}, {"text": "February"}]'::jsonb, 
    FALSE, 1, '{"ans": "May"}', 
    '[{"type": "text", "content": "The order is January, February, March, April, **May**."}]'::jsonb, 
    'easy', 1, 'Calendar Knowledge', 20
);

-- 2. First month of the year
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", "is_multi_select", "correct_answer_index", "correct_answer_text", "solution", "difficulty", "marks", "sub_topic", "complexity"
) VALUES (
    '3258a85f-26c5-4565-8e56-b612ec6656b6', 'mcq', 
    '[{"type": "text", "content": "Which is the **first** month of the year?"}]'::jsonb, 
    '[{"text": "December"}, {"text": "January"}, {"text": "June"}, {"text": "August"}]'::jsonb, 
    FALSE, 1, '{"ans": "January"}', 
    '[{"type": "text", "content": "The year starts with January."}]'::jsonb, 
    'easy', 1, 'Calendar Knowledge', 20
);

-- 3. Last month of the year
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", "is_multi_select", "correct_answer_index", "correct_answer_text", "solution", "difficulty", "marks", "sub_topic", "complexity"
) VALUES (
    '3258a85f-26c5-4565-8e56-b612ec6656b6', 'mcq', 
    '[{"type": "text", "content": "Which is the **last** month of the year?"}]'::jsonb, 
    '[{"text": "November"}, {"text": "September"}, {"text": "December"}, {"text": "January"}]'::jsonb, 
    FALSE, 2, '{"ans": "December"}', 
    '[{"type": "text", "content": "The 12th and last month is December."}]'::jsonb, 
    'easy', 1, 'Calendar Knowledge', 20
);

-- 4. Days in a week
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", "is_multi_select", "correct_answer_index", "correct_answer_text", "solution", "difficulty", "marks", "sub_topic", "complexity"
) VALUES (
    '3258a85f-26c5-4565-8e56-b612ec6656b6', 'mcq', 
    '[{"type": "text", "content": "How many days are there in one week?"}]'::jsonb, 
    '[{"text": "5"}, {"text": "7"}, {"text": "10"}, {"text": "12"}]'::jsonb, 
    FALSE, 1, '{"ans": "7"}', 
    '[{"type": "text", "content": "There are 7 days: Mon, Tue, Wed, Thu, Fri, Sat, Sun."}]'::jsonb, 
    'easy', 1, 'Calendar Knowledge', 20
);

-- 5. Shortest Month
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", "is_multi_select", "correct_answer_index", "correct_answer_text", "solution", "difficulty", "marks", "sub_topic", "complexity"
) VALUES (
    '3258a85f-26c5-4565-8e56-b612ec6656b6', 'mcq', 
    '[{"type": "text", "content": "Which month has the fewest number of days (28 or 29)?"}]'::jsonb, 
    '[{"text": "January"}, {"text": "February"}, {"text": "March"}, {"text": "April"}]'::jsonb, 
    FALSE, 1, '{"ans": "February"}', 
    '[{"type": "text", "content": "February usually has 28 days, solving it the shortest month."}]'::jsonb, 
    'medium', 1, 'Calendar Knowledge', 30
);

-- --- SET B: Using the September Calendar (Reused SVG) ---
-- Scale: Sept 1=Sun, 30 days.

-- 6. Day of Sept 19
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", "is_multi_select", "correct_answer_index", "correct_answer_text", "solution", "difficulty", "marks", "sub_topic", "complexity"
) VALUES (
    '3258a85f-26c5-4565-8e56-b612ec6656b6', 'mcq', 
    '[
        {"type": "text", "content": "Look at the September calendar. What day of the week is **September 19**?"},
        {"type": "svg", "content": "<svg width=\"280\" height=\"220\" viewBox=\"0 0 280 220\" xmlns=\"http://www.w3.org/2000/svg\"><rect width=\"280\" height=\"220\" fill=\"white\" stroke=\"#333\" stroke-width=\"1\"/><rect width=\"280\" height=\"35\" fill=\"#4A90E2\"/><text x=\"140\" y=\"25\" font-family=\"Arial\" font-size=\"18\" fill=\"white\" text-anchor=\"middle\" font-weight=\"bold\">September</text><g font-family=\"Arial\" font-size=\"14\" font-weight=\"bold\" fill=\"#4A90E2\"><text x=\"20\" y=\"55\">Sun</text><text x=\"60\" y=\"55\">Mon</text><text x=\"100\" y=\"55\">Tue</text><text x=\"140\" y=\"55\">Wed</text><text x=\"180\" y=\"55\">Thu</text><text x=\"220\" y=\"55\">Fri</text><text x=\"255\" y=\"55\">Sat</text></g><g font-family=\"Arial\" font-size=\"14\" fill=\"#333\"><text x=\"25\" y=\"80\">1</text><text x=\"65\" y=\"80\">2</text><text x=\"105\" y=\"80\">3</text><text x=\"145\" y=\"80\">4</text><text x=\"185\" y=\"80\">5</text><text x=\"225\" y=\"80\">6</text><text x=\"260\" y=\"80\">7</text><text x=\"25\" y=\"110\">8</text><text x=\"65\" y=\"110\">9</text><text x=\"105\" y=\"110\">10</text><text x=\"145\" y=\"110\">11</text><text x=\"185\" y=\"110\">12</text><text x=\"225\" y=\"110\">13</text><text x=\"260\" y=\"110\">14</text><text x=\"25\" y=\"140\">15</text><text x=\"65\" y=\"140\">16</text><text x=\"105\" y=\"140\">17</text><text x=\"145\" y=\"140\">18</text><text x=\"185\" y=\"140\">19</text><text x=\"225\" y=\"140\">20</text><text x=\"260\" y=\"140\">21</text><text x=\"25\" y=\"170\">22</text><text x=\"65\" y=\"170\">23</text><text x=\"105\" y=\"170\">24</text><text x=\"145\" y=\"170\">25</text><text x=\"185\" y=\"170\">26</text><text x=\"225\" y=\"170\">27</text><text x=\"260\" y=\"170\">28</text><text x=\"25\" y=\"200\">29</text><text x=\"65\" y=\"200\">30</text></g></svg>"}
    ]'::jsonb, 
    '[{"text": "Wednesday"}, {"text": "Thursday"}, {"text": "Friday"}, {"text": "Saturday"}]'::jsonb, 
    FALSE, 1, '{"ans": "Thursday"}', 
    '[{"type": "text", "content": "Find number 19. Look to the top of that column. It says \"Thu\" (Thursday)."}]'::jsonb, 
    'medium', 1, 'Reading Calendars', 40
);

-- 7. Count of Tuesdays (Sept)
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", "is_multi_select", "correct_answer_index", "correct_answer_text", "solution", "difficulty", "marks", "sub_topic", "complexity"
) VALUES (
    '3258a85f-26c5-4565-8e56-b612ec6656b6', 'mcq', 
    '[
        {"type": "text", "content": "How many **Tuesdays** are there in September?"},
        {"type": "svg", "content": "<svg width=\"280\" height=\"220\" viewBox=\"0 0 280 220\" xmlns=\"http://www.w3.org/2000/svg\"><rect width=\"280\" height=\"220\" fill=\"white\" stroke=\"#333\" stroke-width=\"1\"/><rect width=\"280\" height=\"35\" fill=\"#4A90E2\"/><text x=\"140\" y=\"25\" font-family=\"Arial\" font-size=\"18\" fill=\"white\" text-anchor=\"middle\" font-weight=\"bold\">September</text><g font-family=\"Arial\" font-size=\"14\" font-weight=\"bold\" fill=\"#4A90E2\"><text x=\"20\" y=\"55\">Sun</text><text x=\"60\" y=\"55\">Mon</text><text x=\"100\" y=\"55\">Tue</text><text x=\"140\" y=\"55\">Wed</text><text x=\"180\" y=\"55\">Thu</text><text x=\"220\" y=\"55\">Fri</text><text x=\"255\" y=\"55\">Sat</text></g><g font-family=\"Arial\" font-size=\"14\" fill=\"#333\"><text x=\"25\" y=\"80\">1</text><text x=\"65\" y=\"80\">2</text><text x=\"105\" y=\"80\">3</text><text x=\"145\" y=\"80\">4</text><text x=\"185\" y=\"80\">5</text><text x=\"225\" y=\"80\">6</text><text x=\"260\" y=\"80\">7</text><text x=\"25\" y=\"110\">8</text><text x=\"65\" y=\"110\">9</text><text x=\"105\" y=\"110\">10</text><text x=\"145\" y=\"110\">11</text><text x=\"185\" y=\"110\">12</text><text x=\"225\" y=\"110\">13</text><text x=\"260\" y=\"110\">14</text><text x=\"25\" y=\"140\">15</text><text x=\"65\" y=\"140\">16</text><text x=\"105\" y=\"140\">17</text><text x=\"145\" y=\"140\">18</text><text x=\"185\" y=\"140\">19</text><text x=\"225\" y=\"140\">20</text><text x=\"260\" y=\"140\">21</text><text x=\"25\" y=\"170\">22</text><text x=\"65\" y=\"170\">23</text><text x=\"105\" y=\"170\">24</text><text x=\"145\" y=\"170\">25</text><text x=\"185\" y=\"170\">26</text><text x=\"225\" y=\"170\">27</text><text x=\"260\" y=\"170\">28</text><text x=\"25\" y=\"200\">29</text><text x=\"65\" y=\"200\">30</text></g></svg>"}
    ]'::jsonb, 
    '[{"text": "3"}, {"text": "4"}, {"text": "5"}, {"text": "2"}]'::jsonb, 
    FALSE, 1, '{"ans": "4"}', 
    '[{"type": "text", "content": "The Tuesdays are on the 3rd, 10th, 17th, and 24th. That makes 4 Tuesdays."}]'::jsonb, 
    'medium', 1, 'Reading Calendars', 40
);

-- 8. Identify Date (Sept)
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", "is_multi_select", "correct_answer_index", "correct_answer_text", "solution", "difficulty", "marks", "sub_topic", "complexity"
) VALUES (
    '3258a85f-26c5-4565-8e56-b612ec6656b6', 'mcq', 
    '[
        {"type": "text", "content": "What is the date of the **third Sunday** in September?"},
        {"type": "svg", "content": "<svg width=\"280\" height=\"220\" viewBox=\"0 0 280 220\" xmlns=\"http://www.w3.org/2000/svg\"><rect width=\"280\" height=\"220\" fill=\"white\" stroke=\"#333\" stroke-width=\"1\"/><rect width=\"280\" height=\"35\" fill=\"#4A90E2\"/><text x=\"140\" y=\"25\" font-family=\"Arial\" font-size=\"18\" fill=\"white\" text-anchor=\"middle\" font-weight=\"bold\">September</text><g font-family=\"Arial\" font-size=\"14\" font-weight=\"bold\" fill=\"#4A90E2\"><text x=\"20\" y=\"55\">Sun</text><text x=\"60\" y=\"55\">Mon</text><text x=\"100\" y=\"55\">Tue</text><text x=\"140\" y=\"55\">Wed</text><text x=\"180\" y=\"55\">Thu</text><text x=\"220\" y=\"55\">Fri</text><text x=\"255\" y=\"55\">Sat</text></g><g font-family=\"Arial\" font-size=\"14\" fill=\"#333\"><text x=\"25\" y=\"80\">1</text><text x=\"65\" y=\"80\">2</text><text x=\"105\" y=\"80\">3</text><text x=\"145\" y=\"80\">4</text><text x=\"185\" y=\"80\">5</text><text x=\"225\" y=\"80\">6</text><text x=\"260\" y=\"80\">7</text><text x=\"25\" y=\"110\">8</text><text x=\"65\" y=\"110\">9</text><text x=\"105\" y=\"110\">10</text><text x=\"145\" y=\"110\">11</text><text x=\"185\" y=\"110\">12</text><text x=\"225\" y=\"110\">13</text><text x=\"260\" y=\"110\">14</text><text x=\"25\" y=\"140\">15</text><text x=\"65\" y=\"140\">16</text><text x=\"105\" y=\"140\">17</text><text x=\"145\" y=\"140\">18</text><text x=\"185\" y=\"140\">19</text><text x=\"225\" y=\"140\">20</text><text x=\"260\" y=\"140\">21</text><text x=\"25\" y=\"170\">22</text><text x=\"65\" y=\"170\">23</text><text x=\"105\" y=\"170\">24</text><text x=\"145\" y=\"170\">25</text><text x=\"185\" y=\"170\">26</text><text x=\"225\" y=\"170\">27</text><text x=\"260\" y=\"170\">28</text><text x=\"25\" y=\"200\">29</text><text x=\"65\" y=\"200\">30</text></g></svg>"}
    ]'::jsonb, 
    '[{"text": "Sept 1"}, {"text": "Sept 8"}, {"text": "Sept 15"}, {"text": "Sept 22"}]'::jsonb, 
    FALSE, 2, '{"ans": "Sept 15"}', 
    '[{"type": "text", "content": "1st Sunday is Sept 1. 2nd is Sept 8. 3rd is Sept 15."}]'::jsonb, 
    'medium', 1, 'Reading Calendars', 40
);

-- 9. Date Math (Sept)
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", "is_multi_select", "correct_answer_index", "correct_answer_text", "solution", "difficulty", "marks", "sub_topic", "complexity"
) VALUES (
    '3258a85f-26c5-4565-8e56-b612ec6656b6', 'mcq', 
    '[
        {"type": "text", "content": "If today is **September 4** (Wednesday), what date will it be exactly **one week** later?"},
        {"type": "svg", "content": "<svg width=\"280\" height=\"220\" viewBox=\"0 0 280 220\" xmlns=\"http://www.w3.org/2000/svg\"><rect width=\"280\" height=\"220\" fill=\"white\" stroke=\"#333\" stroke-width=\"1\"/><rect width=\"280\" height=\"35\" fill=\"#4A90E2\"/><text x=\"140\" y=\"25\" font-family=\"Arial\" font-size=\"18\" fill=\"white\" text-anchor=\"middle\" font-weight=\"bold\">September</text><g font-family=\"Arial\" font-size=\"14\" font-weight=\"bold\" fill=\"#4A90E2\"><text x=\"20\" y=\"55\">Sun</text><text x=\"60\" y=\"55\">Mon</text><text x=\"100\" y=\"55\">Tue</text><text x=\"140\" y=\"55\">Wed</text><text x=\"180\" y=\"55\">Thu</text><text x=\"220\" y=\"55\">Fri</text><text x=\"255\" y=\"55\">Sat</text></g><g font-family=\"Arial\" font-size=\"14\" fill=\"#333\"><text x=\"25\" y=\"80\">1</text><text x=\"65\" y=\"80\">2</text><text x=\"105\" y=\"80\">3</text><text x=\"145\" y=\"80\">4</text><text x=\"185\" y=\"80\">5</text><text x=\"225\" y=\"80\">6</text><text x=\"260\" y=\"80\">7</text><text x=\"25\" y=\"110\">8</text><text x=\"65\" y=\"110\">9</text><text x=\"105\" y=\"110\">10</text><text x=\"145\" y=\"110\">11</text><text x=\"185\" y=\"110\">12</text><text x=\"225\" y=\"110\">13</text><text x=\"260\" y=\"110\">14</text><text x=\"25\" y=\"140\">15</text><text x=\"65\" y=\"140\">16</text><text x=\"105\" y=\"140\">17</text><text x=\"145\" y=\"140\">18</text><text x=\"185\" y=\"140\">19</text><text x=\"225\" y=\"140\">20</text><text x=\"260\" y=\"140\">21</text><text x=\"25\" y=\"170\">22</text><text x=\"65\" y=\"170\">23</text><text x=\"105\" y=\"170\">24</text><text x=\"145\" y=\"170\">25</text><text x=\"185\" y=\"170\">26</text><text x=\"225\" y=\"170\">27</text><text x=\"260\" y=\"170\">28</text><text x=\"25\" y=\"200\">29</text><text x=\"65\" y=\"200\">30</text></g></svg>"}
    ]'::jsonb, 
    '[{"text": "Sept 10"}, {"text": "Sept 11"}, {"text": "Sept 12"}, {"text": "Sept 13"}]'::jsonb, 
    FALSE, 1, '{"ans": "Sept 11"}', 
    '[{"type": "text", "content": "One week is 7 days. 4 + 7 = 11. Or move one row down."}]'::jsonb, 
    'hard', 1, 'Reading Calendars', 50
);

-- 10. Multi-Select Mondays (Sept)
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", "is_multi_select", "correct_answer_indices", "correct_answer_text", "solution", "difficulty", "marks", "sub_topic", "complexity"
) VALUES (
    '3258a85f-26c5-4565-8e56-b612ec6656b6', 'mcq', 
    '[
        {"type": "text", "content": "Look at the September calendar. Select **two** dates that fall on a **Monday**."},
        {"type": "svg", "content": "<svg width=\"280\" height=\"220\" viewBox=\"0 0 280 220\" xmlns=\"http://www.w3.org/2000/svg\"><rect width=\"280\" height=\"220\" fill=\"white\" stroke=\"#333\" stroke-width=\"1\"/><rect width=\"280\" height=\"35\" fill=\"#4A90E2\"/><text x=\"140\" y=\"25\" font-family=\"Arial\" font-size=\"18\" fill=\"white\" text-anchor=\"middle\" font-weight=\"bold\">September</text><g font-family=\"Arial\" font-size=\"14\" font-weight=\"bold\" fill=\"#4A90E2\"><text x=\"20\" y=\"55\">Sun</text><text x=\"60\" y=\"55\">Mon</text><text x=\"100\" y=\"55\">Tue</text><text x=\"140\" y=\"55\">Wed</text><text x=\"180\" y=\"55\">Thu</text><text x=\"220\" y=\"55\">Fri</text><text x=\"255\" y=\"55\">Sat</text></g><g font-family=\"Arial\" font-size=\"14\" fill=\"#333\"><text x=\"25\" y=\"80\">1</text><text x=\"65\" y=\"80\">2</text><text x=\"105\" y=\"80\">3</text><text x=\"145\" y=\"80\">4</text><text x=\"185\" y=\"80\">5</text><text x=\"225\" y=\"80\">6</text><text x=\"260\" y=\"80\">7</text><text x=\"25\" y=\"110\">8</text><text x=\"65\" y=\"110\">9</text><text x=\"105\" y=\"110\">10</text><text x=\"145\" y=\"110\">11</text><text x=\"185\" y=\"110\">12</text><text x=\"225\" y=\"110\">13</text><text x=\"260\" y=\"110\">14</text><text x=\"25\" y=\"140\">15</text><text x=\"65\" y=\"140\">16</text><text x=\"105\" y=\"140\">17</text><text x=\"145\" y=\"140\">18</text><text x=\"185\" y=\"140\">19</text><text x=\"225\" y=\"140\">20</text><text x=\"260\" y=\"140\">21</text><text x=\"25\" y=\"170\">22</text><text x=\"65\" y=\"170\">23</text><text x=\"105\" y=\"170\">24</text><text x=\"145\" y=\"170\">25</text><text x=\"185\" y=\"170\">26</text><text x=\"225\" y=\"170\">27</text><text x=\"260\" y=\"170\">28</text><text x=\"25\" y=\"200\">29</text><text x=\"65\" y=\"200\">30</text></g></svg>"}
    ]'::jsonb, 
    '[{"text": "2nd"}, {"text": "3rd"}, {"text": "9th"}, {"text": "10th"}]'::jsonb, 
    TRUE, '[0, 2]'::jsonb, '{"ans": ["2nd", "9th"]}', 
    '[{"type": "text", "content": "Look under \"Mon\". The dates are 2, 9, 16, 23, 30."}]'::jsonb, 
    'medium', 1, 'Reading Calendars', 40
);

-- --- SET C: New Calendar (October) ---
-- Config: Starts Tue (1st), 31 Days.

-- 11. Day of Oct 31
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", "is_multi_select", "correct_answer_index", "correct_answer_text", "solution", "difficulty", "marks", "sub_topic", "complexity"
) VALUES (
    '3258a85f-26c5-4565-8e56-b612ec6656b6', 'mcq', 
    '[
        {"type": "text", "content": "Look at the October calendar. On which day is **Halloween (Oct 31)**?"},
        {"type": "svg", "content": "<svg width=\"280\" height=\"220\" viewBox=\"0 0 280 220\" xmlns=\"http://www.w3.org/2000/svg\"><rect width=\"280\" height=\"220\" fill=\"white\" stroke=\"#333\" stroke-width=\"1\"/><rect width=\"280\" height=\"35\" fill=\"#E24A4A\"/><text x=\"140\" y=\"25\" font-family=\"Arial\" font-size=\"18\" fill=\"white\" text-anchor=\"middle\" font-weight=\"bold\">October</text><g font-family=\"Arial\" font-size=\"14\" font-weight=\"bold\" fill=\"#E24A4A\"><text x=\"20\" y=\"55\">Sun</text><text x=\"60\" y=\"55\">Mon</text><text x=\"100\" y=\"55\">Tue</text><text x=\"140\" y=\"55\">Wed</text><text x=\"180\" y=\"55\">Thu</text><text x=\"220\" y=\"55\">Fri</text><text x=\"255\" y=\"55\">Sat</text></g><g font-family=\"Arial\" font-size=\"14\" fill=\"#333\"><text x=\"105\" y=\"80\">1</text><text x=\"145\" y=\"80\">2</text><text x=\"185\" y=\"80\">3</text><text x=\"225\" y=\"80\">4</text><text x=\"260\" y=\"80\">5</text><text x=\"25\" y=\"110\">6</text><text x=\"65\" y=\"110\">7</text><text x=\"105\" y=\"110\">8</text><text x=\"145\" y=\"110\">9</text><text x=\"185\" y=\"110\">10</text><text x=\"225\" y=\"110\">11</text><text x=\"260\" y=\"110\">12</text><text x=\"25\" y=\"140\">13</text><text x=\"65\" y=\"140\">14</text><text x=\"105\" y=\"140\">15</text><text x=\"145\" y=\"140\">16</text><text x=\"185\" y=\"140\">17</text><text x=\"225\" y=\"140\">18</text><text x=\"260\" y=\"140\">19</text><text x=\"25\" y=\"170\">20</text><text x=\"65\" y=\"170\">21</text><text x=\"105\" y=\"170\">22</text><text x=\"145\" y=\"170\">23</text><text x=\"185\" y=\"170\">24</text><text x=\"225\" y=\"170\">25</text><text x=\"260\" y=\"170\">26</text><text x=\"25\" y=\"200\">27</text><text x=\"65\" y=\"200\">28</text><text x=\"105\" y=\"200\">29</text><text x=\"145\" y=\"200\">30</text><text x=\"185\" y=\"200\">31</text></g></svg>"}
    ]'::jsonb, 
    '[{"text": "Wednesday"}, {"text": "Thursday"}, {"text": "Friday"}, {"text": "Monday"}]'::jsonb, 
    FALSE, 1, '{"ans": "Thursday"}', 
    '[{"type": "text", "content": "Find number 31. Look up to see \"Thu\"."}]'::jsonb, 
    'medium', 1, 'Reading Calendars', 40
);

-- 12. Count of Fridays (Oct)
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", "is_multi_select", "correct_answer_index", "correct_answer_text", "solution", "difficulty", "marks", "sub_topic", "complexity"
) VALUES (
    '3258a85f-26c5-4565-8e56-b612ec6656b6', 'mcq', 
    '[
        {"type": "text", "content": "How many **Fridays** are there in October?"},
        {"type": "svg", "content": "<svg width=\"280\" height=\"220\" viewBox=\"0 0 280 220\" xmlns=\"http://www.w3.org/2000/svg\"><rect width=\"280\" height=\"220\" fill=\"white\" stroke=\"#333\" stroke-width=\"1\"/><rect width=\"280\" height=\"35\" fill=\"#E24A4A\"/><text x=\"140\" y=\"25\" font-family=\"Arial\" font-size=\"18\" fill=\"white\" text-anchor=\"middle\" font-weight=\"bold\">October</text><g font-family=\"Arial\" font-size=\"14\" font-weight=\"bold\" fill=\"#E24A4A\"><text x=\"20\" y=\"55\">Sun</text><text x=\"60\" y=\"55\">Mon</text><text x=\"100\" y=\"55\">Tue</text><text x=\"140\" y=\"55\">Wed</text><text x=\"180\" y=\"55\">Thu</text><text x=\"220\" y=\"55\">Fri</text><text x=\"255\" y=\"55\">Sat</text></g><g font-family=\"Arial\" font-size=\"14\" fill=\"#333\"><text x=\"105\" y=\"80\">1</text><text x=\"145\" y=\"80\">2</text><text x=\"185\" y=\"80\">3</text><text x=\"225\" y=\"80\">4</text><text x=\"260\" y=\"80\">5</text><text x=\"25\" y=\"110\">6</text><text x=\"65\" y=\"110\">7</text><text x=\"105\" y=\"110\">8</text><text x=\"145\" y=\"110\">9</text><text x=\"185\" y=\"110\">10</text><text x=\"225\" y=\"110\">11</text><text x=\"260\" y=\"110\">12</text><text x=\"25\" y=\"140\">13</text><text x=\"65\" y=\"140\">14</text><text x=\"105\" y=\"140\">15</text><text x=\"145\" y=\"140\">16</text><text x=\"185\" y=\"140\">17</text><text x=\"225\" y=\"140\">18</text><text x=\"260\" y=\"140\">19</text><text x=\"25\" y=\"170\">20</text><text x=\"65\" y=\"170\">21</text><text x=\"105\" y=\"170\">22</text><text x=\"145\" y=\"170\">23</text><text x=\"185\" y=\"170\">24</text><text x=\"225\" y=\"170\">25</text><text x=\"260\" y=\"170\">26</text><text x=\"25\" y=\"200\">27</text><text x=\"65\" y=\"200\">28</text><text x=\"105\" y=\"200\">29</text><text x=\"145\" y=\"200\">30</text><text x=\"185\" y=\"200\">31</text></g></svg>"}
    ]'::jsonb, 
    '[{"text": "4"}, {"text": "5"}, {"text": "3"}, {"text": "6"}]'::jsonb, 
    FALSE, 0, '{"ans": "4"}', 
    '[{"type": "text", "content": "Count the numbers under Fri: 4, 11, 18, 25."}]'::jsonb, 
    'medium', 1, 'Reading Calendars', 40
);

-- 13. Identify Date (Oct)
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", "is_multi_select", "correct_answer_index", "correct_answer_text", "solution", "difficulty", "marks", "sub_topic", "complexity"
) VALUES (
    '3258a85f-26c5-4565-8e56-b612ec6656b6', 'mcq', 
    '[
        {"type": "text", "content": "What is the date of the **first Saturday** in October?"},
        {"type": "svg", "content": "<svg width=\"280\" height=\"220\" viewBox=\"0 0 280 220\" xmlns=\"http://www.w3.org/2000/svg\"><rect width=\"280\" height=\"220\" fill=\"white\" stroke=\"#333\" stroke-width=\"1\"/><rect width=\"280\" height=\"35\" fill=\"#E24A4A\"/><text x=\"140\" y=\"25\" font-family=\"Arial\" font-size=\"18\" fill=\"white\" text-anchor=\"middle\" font-weight=\"bold\">October</text><g font-family=\"Arial\" font-size=\"14\" font-weight=\"bold\" fill=\"#E24A4A\"><text x=\"20\" y=\"55\">Sun</text><text x=\"60\" y=\"55\">Mon</text><text x=\"100\" y=\"55\">Tue</text><text x=\"140\" y=\"55\">Wed</text><text x=\"180\" y=\"55\">Thu</text><text x=\"220\" y=\"55\">Fri</text><text x=\"255\" y=\"55\">Sat</text></g><g font-family=\"Arial\" font-size=\"14\" fill=\"#333\"><text x=\"105\" y=\"80\">1</text><text x=\"145\" y=\"80\">2</text><text x=\"185\" y=\"80\">3</text><text x=\"225\" y=\"80\">4</text><text x=\"260\" y=\"80\">5</text><text x=\"25\" y=\"110\">6</text><text x=\"65\" y=\"110\">7</text><text x=\"105\" y=\"110\">8</text><text x=\"145\" y=\"110\">9</text><text x=\"185\" y=\"110\">10</text><text x=\"225\" y=\"110\">11</text><text x=\"260\" y=\"110\">12</text><text x=\"25\" y=\"140\">13</text><text x=\"65\" y=\"140\">14</text><text x=\"105\" y=\"140\">15</text><text x=\"145\" y=\"140\">16</text><text x=\"185\" y=\"140\">17</text><text x=\"225\" y=\"140\">18</text><text x=\"260\" y=\"140\">19</text><text x=\"25\" y=\"170\">20</text><text x=\"65\" y=\"170\">21</text><text x=\"105\" y=\"170\">22</text><text x=\"145\" y=\"170\">23</text><text x=\"185\" y=\"170\">24</text><text x=\"225\" y=\"170\">25</text><text x=\"260\" y=\"170\">26</text><text x=\"25\" y=\"200\">27</text><text x=\"65\" y=\"200\">28</text><text x=\"105\" y=\"200\">29</text><text x=\"145\" y=\"200\">30</text><text x=\"185\" y=\"200\">31</text></g></svg>"}
    ]'::jsonb, 
    '[{"text": "Oct 1"}, {"text": "Oct 5"}, {"text": "Oct 7"}, {"text": "Oct 4"}]'::jsonb, 
    FALSE, 1, '{"ans": "Oct 5"}', 
    '[{"type": "text", "content": "Look at the first number under \"Sat\". It is 5."}]'::jsonb, 
    'medium', 1, 'Reading Calendars', 40
);

-- 14. Date Math (Oct)
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", "is_multi_select", "correct_answer_index", "correct_answer_text", "solution", "difficulty", "marks", "sub_topic", "complexity"
) VALUES (
    '3258a85f-26c5-4565-8e56-b612ec6656b6', 'mcq', 
    '[
        {"type": "text", "content": "If today is **October 10** (Thursday), what date will it be **2 days later**?"},
        {"type": "svg", "content": "<svg width=\"280\" height=\"220\" viewBox=\"0 0 280 220\" xmlns=\"http://www.w3.org/2000/svg\"><rect width=\"280\" height=\"220\" fill=\"white\" stroke=\"#333\" stroke-width=\"1\"/><rect width=\"280\" height=\"35\" fill=\"#E24A4A\"/><text x=\"140\" y=\"25\" font-family=\"Arial\" font-size=\"18\" fill=\"white\" text-anchor=\"middle\" font-weight=\"bold\">October</text><g font-family=\"Arial\" font-size=\"14\" font-weight=\"bold\" fill=\"#E24A4A\"><text x=\"20\" y=\"55\">Sun</text><text x=\"60\" y=\"55\">Mon</text><text x=\"100\" y=\"55\">Tue</text><text x=\"140\" y=\"55\">Wed</text><text x=\"180\" y=\"55\">Thu</text><text x=\"220\" y=\"55\">Fri</text><text x=\"255\" y=\"55\">Sat</text></g><g font-family=\"Arial\" font-size=\"14\" fill=\"#333\"><text x=\"105\" y=\"80\">1</text><text x=\"145\" y=\"80\">2</text><text x=\"185\" y=\"80\">3</text><text x=\"225\" y=\"80\">4</text><text x=\"260\" y=\"80\">5</text><text x=\"25\" y=\"110\">6</text><text x=\"65\" y=\"110\">7</text><text x=\"105\" y=\"110\">8</text><text x=\"145\" y=\"110\">9</text><text x=\"185\" y=\"110\">10</text><text x=\"225\" y=\"110\">11</text><text x=\"260\" y=\"110\">12</text><text x=\"25\" y=\"140\">13</text><text x=\"65\" y=\"140\">14</text><text x=\"105\" y=\"140\">15</text><text x=\"145\" y=\"140\">16</text><text x=\"185\" y=\"140\">17</text><text x=\"225\" y=\"140\">18</text><text x=\"260\" y=\"140\">19</text><text x=\"25\" y=\"170\">20</text><text x=\"65\" y=\"170\">21</text><text x=\"105\" y=\"170\">22</text><text x=\"145\" y=\"170\">23</text><text x=\"185\" y=\"170\">24</text><text x=\"225\" y=\"170\">25</text><text x=\"260\" y=\"170\">26</text><text x=\"25\" y=\"200\">27</text><text x=\"65\" y=\"200\">28</text><text x=\"105\" y=\"200\">29</text><text x=\"145\" y=\"200\">30</text><text x=\"185\" y=\"200\">31</text></g></svg>"}
    ]'::jsonb, 
    '[{"text": "Oct 11"}, {"text": "Oct 12"}, {"text": "Oct 13"}, {"text": "Oct 9"}]'::jsonb, 
    FALSE, 1, '{"ans": "Oct 12"}', 
    '[{"type": "text", "content": "10 + 2 = 12. Also, two blocks to the right from 10 is 12."}]'::jsonb, 
    'medium', 1, 'Reading Calendars', 40
);

-- 15. Multi-Select Weekends (Oct)
INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", "is_multi_select", "correct_answer_indices", "correct_answer_text", "solution", "difficulty", "marks", "sub_topic", "complexity"
) VALUES (
    '3258a85f-26c5-4565-8e56-b612ec6656b6', 'mcq', 
    '[
        {"type": "text", "content": "Select **two** weekend dates in October from the options below."},
        {"type": "svg", "content": "<svg width=\"280\" height=\"220\" viewBox=\"0 0 280 220\" xmlns=\"http://www.w3.org/2000/svg\"><rect width=\"280\" height=\"220\" fill=\"white\" stroke=\"#333\" stroke-width=\"1\"/><rect width=\"280\" height=\"35\" fill=\"#E24A4A\"/><text x=\"140\" y=\"25\" font-family=\"Arial\" font-size=\"18\" fill=\"white\" text-anchor=\"middle\" font-weight=\"bold\">October</text><g font-family=\"Arial\" font-size=\"14\" font-weight=\"bold\" fill=\"#E24A4A\"><text x=\"20\" y=\"55\">Sun</text><text x=\"60\" y=\"55\">Mon</text><text x=\"100\" y=\"55\">Tue</text><text x=\"140\" y=\"55\">Wed</text><text x=\"180\" y=\"55\">Thu</text><text x=\"220\" y=\"55\">Fri</text><text x=\"255\" y=\"55\">Sat</text></g><g font-family=\"Arial\" font-size=\"14\" fill=\"#333\"><text x=\"105\" y=\"80\">1</text><text x=\"145\" y=\"80\">2</text><text x=\"185\" y=\"80\">3</text><text x=\"225\" y=\"80\">4</text><text x=\"260\" y=\"80\">5</text><text x=\"25\" y=\"110\">6</text><text x=\"65\" y=\"110\">7</text><text x=\"105\" y=\"110\">8</text><text x=\"145\" y=\"110\">9</text><text x=\"185\" y=\"110\">10</text><text x=\"225\" y=\"110\">11</text><text x=\"260\" y=\"110\">12</text><text x=\"25\" y=\"140\">13</text><text x=\"65\" y=\"140\">14</text><text x=\"105\" y=\"140\">15</text><text x=\"145\" y=\"140\">16</text><text x=\"185\" y=\"140\">17</text><text x=\"225\" y=\"140\">18</text><text x=\"260\" y=\"140\">19</text><text x=\"25\" y=\"170\">20</text><text x=\"65\" y=\"170\">21</text><text x=\"105\" y=\"170\">22</text><text x=\"145\" y=\"170\">23</text><text x=\"185\" y=\"170\">24</text><text x=\"225\" y=\"170\">25</text><text x=\"260\" y=\"170\">26</text><text x=\"25\" y=\"200\">27</text><text x=\"65\" y=\"200\">28</text><text x=\"105\" y=\"200\">29</text><text x=\"145\" y=\"200\">30</text><text x=\"185\" y=\"200\">31</text></g></svg>"}
    ]'::jsonb, 
    '[{"text": "Oct 1 (Tue)"}, {"text": "Oct 6 (Sun)"}, {"text": "Oct 12 (Sat)"}, {"text": "Oct 16 (Wed)"}]'::jsonb, 
    TRUE, '[1, 2]'::jsonb, '{"ans": ["Oct 6", "Oct 12"]}', 
    '[{"type": "text", "content": "Weekends are Saturdays and Sundays. Oct 6 is a Sunday and Oct 12 is a Saturday."}]'::jsonb, 
    'medium', 1, 'Reading Calendars', 40
);
