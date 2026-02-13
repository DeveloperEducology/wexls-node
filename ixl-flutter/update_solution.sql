-- Update the solution for the Sequence Question
-- Adjust the WHERE clause to target the specific question you want to update.
-- For example, you can target by ID or by matching the question text.

UPDATE questions
SET solution = '[
  { "type": "text", "content": "First, identify the missing number in the sequence." },
  { "type": "svg", "content": "<svg viewBox=\"0 0 100 50\"><text x=\"10\" y=\"40\" font-size=\"20\">7 _ 9</text><path d=\"M30,45 Q50,10 70,45\" stroke=\"red\" fill=\"none\"/></svg>" },
  { "type": "math", "content": "7 < ? < 9 \\\\rightarrow ? = 8" },
  { "type": "text", "content": "Now, determine if 8 is even or odd by pairing." },
  { "type": "image", "imageUrl": "https://cdn-icons-png.flaticon.com/512/3570/3570099.png" },
  { "type": "text", "content": "Since 8 can be split into two equal groups of 4, it is **even**." }
]'
WHERE parts::text LIKE '%Type the missing numbers in the sequence%' 
   OR parts::text LIKE '%missing number%';
