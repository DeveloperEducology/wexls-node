INSERT INTO "questions" (
    "micro_skill_id", "type", "parts", "options", 
    "is_multi_select", "correct_answer_index", -- CORRECT COLUMN FOR SINGLE SELECT
    "correct_answer_text", "solution", "difficulty", "marks", 
    "drag_groups", "drag_items", "sub_topic", "complexity"
) VALUES (
    '3258a85f-26c5-4565-8e56-b612ec6656b6', 
    'mcq', 
    '[
        {"type": "text", "content": "How many **Saturdays** are there in the month shown below?"},
        {
            "type": "svg",
            "content": "<svg width=\"280\" height=\"220\" viewBox=\"0 0 280 220\" xmlns=\"http://www.w3.org/2000/svg\"><rect width=\"280\" height=\"220\" fill=\"white\" stroke=\"#333\" stroke-width=\"1\"/><rect width=\"280\" height=\"35\" fill=\"#4A90E2\"/><text x=\"140\" y=\"25\" font-family=\"Arial\" font-size=\"18\" fill=\"white\" text-anchor=\"middle\" font-weight=\"bold\">September</text><g font-family=\"Arial\" font-size=\"14\" font-weight=\"bold\" fill=\"#4A90E2\"><text x=\"20\" y=\"55\">Sun</text><text x=\"60\" y=\"55\">Mon</text><text x=\"100\" y=\"55\">Tue</text><text x=\"140\" y=\"55\">Wed</text><text x=\"180\" y=\"55\">Thu</text><text x=\"220\" y=\"55\">Fri</text><text x=\"255\" y=\"55\">Sat</text></g><g font-family=\"Arial\" font-size=\"14\" fill=\"#333\"><text x=\"25\" y=\"80\">1</text><text x=\"65\" y=\"80\">2</text><text x=\"105\" y=\"80\">3</text><text x=\"145\" y=\"80\">4</text><text x=\"185\" y=\"80\">5</text><text x=\"225\" y=\"80\">6</text><text x=\"260\" y=\"80\">7</text><text x=\"25\" y=\"110\">8</text><text x=\"65\" y=\"110\">9</text><text x=\"105\" y=\"110\">10</text><text x=\"145\" y=\"110\">11</text><text x=\"185\" y=\"110\">12</text><text x=\"225\" y=\"110\">13</text><text x=\"260\" y=\"110\">14</text><text x=\"25\" y=\"140\">15</text><text x=\"65\" y=\"140\">16</text><text x=\"105\" y=\"140\">17</text><text x=\"145\" y=\"140\">18</text><text x=\"185\" y=\"140\">19</text><text x=\"225\" y=\"140\">20</text><text x=\"260\" y=\"140\">21</text><text x=\"25\" y=\"170\">22</text><text x=\"65\" y=\"170\">23</text><text x=\"105\" y=\"170\">24</text><text x=\"145\" y=\"170\">25</text><text x=\"185\" y=\"170\">26</text><text x=\"225\" y=\"170\">27</text><text x=\"260\" y=\"170\">28</text><text x=\"25\" y=\"200\">29</text><text x=\"65\" y=\"200\">30</text></g></svg>"
        }
    ]'::jsonb, 
    '[
        {"text": "5"}, {"text": "6"}, {"text": "4"}, {"text": "3"}
    ]'::jsonb, 
    FALSE, 
    2, -- Integer value for single select
    '{"ans": "4"}', 
    '[{"type": "text", "content": "Look at the column under \"Sat\". You can see the dates 7, 14, 21, and 28. Counting them gives a total of 4 Saturdays."}]'::jsonb, 
    'medium', 1, '[]'::jsonb, '[]'::jsonb, 'Reading Calendars', 40
);
