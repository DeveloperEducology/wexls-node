-- ====================================================================
-- BATCH INSERT: PATTERN ANALOGY QUESTIONS (SVG)
-- Micro-skill ID: ec6f1505-fdbf-4f3b-9f04-eef53d7dce7e
-- ====================================================================

-- 1. Shape Swap Analogy (Medium)
INSERT INTO "public"."questions" (
    "id", "micro_skill_id", "type", "parts", "options", 
    "correct_answer_index", "correct_answer_text", "solution", "difficulty", "complexity", "sub_topic", "marks"
) VALUES 
(
    gen_random_uuid(), 
    'ec6f1505-fdbf-4f3b-9f04-eef53d7dce7e', 
    'mcq', 
    '[
        {"type": "text", "content": "Think and complete the pattern:"},
        {"type": "svg", "content": "<svg width=\"350\" height=\"120\" viewBox=\"0 0 350 120\" xmlns=\"http://www.w3.org/2000/svg\">\n  <!-- Arrow Marker -->\n  <defs>\n    <marker id=\"arrow\" markerWidth=\"10\" markerHeight=\"10\" refX=\"9\" refY=\"3\" orient=\"auto\" markerUnits=\"strokeWidth\">\n      <path d=\"M0,0 L0,6 L9,3 z\" fill=\"black\" />\n    </marker>\n  </defs>\n\n  <!-- Pair 1: Square inside Circle -> Circle inside Square -->\n  <circle cx=\"40\" cy=\"60\" r=\"30\" fill=\"#ffcc80\" stroke=\"black\" />\n  <rect x=\"25\" y=\"45\" width=\"30\" height=\"30\" fill=\"#d32f2f\" stroke=\"black\" />\n  \n  <line x1=\"80\" y1=\"60\" x2=\"110\" y2=\"60\" stroke=\"black\" stroke-width=\"2\" marker-end=\"url(#arrow)\" />\n  \n  <rect x=\"130\" y=\"30\" width=\"60\" height=\"60\" fill=\"#d32f2f\" stroke=\"black\" />\n  <circle cx=\"160\" cy=\"60\" r=\"15\" fill=\"#ffcc80\" stroke=\"black\" />\n\n  <!-- Pair 2: Circle inside Star -> ? -->\n  <!-- Star logic approx -->\n  <polygon points=\"240,30 248,55 275,55 253,70 260,95 240,80 220,95 227,70 205,55 232,55\" fill=\"#ffcc80\" stroke=\"black\" transform=\"translate(0,0)\"/>\n  <circle cx=\"240\" cy=\"68\" r=\"10\" fill=\"#d32f2f\" stroke=\"black\" />\n\n  <line x1=\"285\" y1=\"60\" x2=\"315\" y2=\"60\" stroke=\"black\" stroke-width=\"2\" marker-end=\"url(#arrow)\" />\n  \n  <rect x=\"330\" y=\"30\" width=\"60\" height=\"60\" fill=\"#fff9c4\" rx=\"10\" stroke=\"#ccc\" stroke-dasharray=\"4\"/>\n  <text x=\"360\" y=\"65\" text-anchor=\"middle\" font-size=\"30\">?</text>\n</svg>"},
        {"type": "text", "content": "The logic is: Outer shape becomes Inner, Inner becomes Outer. Colors swap."}
    ]'::jsonb, 
    '["Star inside Circle (Red Outer)", "Circle inside Star", "Star inside Square"]'::jsonb, 
    0, 
    null, 
    '[
        {"type": "text", "content": "1. In the first pair, the Inner Square becomes Outer Square (Pink to Red)."},
        {"type": "text", "content": "2. The Outer Circle becomes Inner Circle (Pink to Yellow)."},
        {"type": "text", "content": "3. Applying this: The Inner Red Circle becomes Outer Red Circle. The Outer Yellow Star becomes Inner Yellow Star."}
    ]'::jsonb, 
    'medium', 
    60,
    'Shape Analogy',
    '1'
);

-- 2. Mirror Image / Rotation (Easy)
INSERT INTO "public"."questions" (
    "id", "micro_skill_id", "type", "parts", "options", 
    "correct_answer_index", "correct_answer_text", "solution", "difficulty", "complexity", "sub_topic", "marks"
) VALUES 
(
    gen_random_uuid(), 
    'ec6f1505-fdbf-4f3b-9f04-eef53d7dce7e', 
    'mcq', 
    '[
        {"type": "text", "content": "Find the matching number pair:"},
        {"type": "svg", "content": "<svg width=\"350\" height=\"100\" xmlns=\"http://www.w3.org/2000/svg\">\n  <defs>\n    <marker id=\"arrow2\" markerWidth=\"10\" markerHeight=\"10\" refX=\"9\" refY=\"3\" orient=\"auto\" markerUnits=\"strokeWidth\">\n      <path d=\"M0,0 L0,6 L9,3 z\" fill=\"black\" />\n    </marker>\n  </defs>\n  <!-- Example: Mirror 5 -> 5 -->\n  <text x=\"40\" y=\"70\" font-size=\"50\" transform=\"scale(-1, 1) translate(-80, 0)\">5</text>\n  <line x1=\"60\" y1=\"55\" x2=\"90\" y2=\"55\" stroke=\"black\" stroke-width=\"2\" marker-end=\"url(#arrow2)\" />\n  <text x=\"110\" y=\"70\" font-size=\"50\">5</text>\n  \n  <!-- Question: Mirror 7 -> ? -->\n  <text x=\"200\" y=\"70\" font-size=\"50\" transform=\"scale(-1, 1) translate(-400, 0)\">7</text>\n  <line x1=\"220\" y1=\"55\" x2=\"250\" y2=\"55\" stroke=\"black\" stroke-width=\"2\" marker-end=\"url(#arrow2)\" />\n  <rect x=\"270\" y=\"30\" width=\"50\" height=\"50\" fill=\"#fff9c4\" stroke=\"#ccc\" stroke-dasharray=\"4\"/>\n  <text x=\"295\" y=\"65\" text-anchor=\"middle\" font-size=\"30\">?</text>\n</svg>"},
        {"type": "text", "content": "What happens when you flip the image?"}
    ]'::jsonb, 
    '["7", "L", "5"]'::jsonb, 
    0, 
    null, 
    '[
        {"type": "text", "content": "The rule is correcting the mirror image."},
        {"type": "text", "content": "The backwards 7 should become a normal 7."}
    ]'::jsonb, 
    'easy', 
    30,
    'Visual Logic',
    '1'
);

-- 3. Shape Growing (Easy)
INSERT INTO "public"."questions" (
    "id", "micro_skill_id", "type", "parts", "options", 
    "correct_answer_index", "correct_answer_text", "solution", "difficulty", "complexity", "sub_topic", "marks"
) VALUES 
(
    gen_random_uuid(), 
    'ec6f1505-fdbf-4f3b-9f04-eef53d7dce7e', 
    'mcq', 
    '[
        {"type": "text", "content": "What comes next?"},
        {"type": "svg", "content": "<svg width=\"350\" height=\"80\" xmlns=\"http://www.w3.org/2000/svg\">\n  <circle cx=\"30\" cy=\"40\" r=\"10\" fill=\"#4caf50\"/>\n  <line x1=\"50\" y1=\"40\" x2=\"70\" y2=\"40\" stroke=\"black\" stroke-width=\"2\" marker-end=\"url(#arrow)\"/>\n  <circle cx=\"100\" cy=\"40\" r=\"20\" fill=\"#4caf50\"/>\n  \n  <rect x=\"160\" y=\"30\" width=\"20\" height=\"20\" fill=\"#2196f3\"/>\n  <line x1=\"190\" y1=\"40\" x2=\"210\" y2=\"40\" stroke=\"black\" stroke-width=\"2\" marker-end=\"url(#arrow)\"/>\n  <rect x=\"240\" y=\"20\" width=\"40\" height=\"40\" fill=\"#fff\" stroke=\"#999\" stroke-dasharray=\"4\"/>\n  <text x=\"260\" y=\"45\" text-anchor=\"middle\">?</text>\n</svg>"},
        {"type": "text", "content": "Small Circle -> Big Circle. Small Square -> ...?"}
    ]'::jsonb, 
    '["Big Square", "Small Circle", "Big Triangle"]'::jsonb, 
    0, 
    null, 
    '[
        {"type": "text", "content": "The pattern is: Shape gets bigger."},
        {"type": "text", "content": "So, Small Square becomes Big Square."}
    ]'::jsonb, 
    'easy', 
    20,
    'Size Patterns',
    '1'
);

-- 4. Rotation Pattern (Hard)
INSERT INTO "public"."questions" (
    "id", "micro_skill_id", "type", "parts", "options", 
    "correct_answer_index", "correct_answer_text", "solution", "difficulty", "complexity", "sub_topic", "marks"
) VALUES 
(
    gen_random_uuid(), 
    'ec6f1505-fdbf-4f3b-9f04-eef53d7dce7e', 
    'mcq', 
    '[
        {"type": "text", "content": "Look at the rotation:"},
        {"type": "svg", "content": "<svg width=\"350\" height=\"100\" xmlns=\"http://www.w3.org/2000/svg\">\n  <defs>\n     <marker id=\"arrow3\" markerWidth=\"10\" markerHeight=\"10\" refX=\"9\" refY=\"3\" orient=\"auto\" markerUnits=\"strokeWidth\"><path d=\"M0,0 L0,6 L9,3 z\" fill=\"black\" /></marker>\n  </defs>\n  <!-- Arrow pointing UP -->\n  <path d=\"M30 60 L30 20 L20 30 M30 20 L40 30\" stroke=\"black\" stroke-width=\"4\" fill=\"none\"/>\n  <line x1=\"60\" y1=\"40\" x2=\"80\" y2=\"40\" stroke=\"black\"  marker-end=\"url(#arrow3)\"/>\n  <!-- Arrow pointing RIGHT -->\n  <path d=\"M100 50 L140 50 L130 40 M140 50 L130 60\" stroke=\"black\" stroke-width=\"4\" fill=\"none\"/>\n  \n  <!-- Arrow pointing RIGHT -> ? -->\n  <path d=\"M200 50 L240 50 L230 40 M240 50 L230 60\" stroke=\"black\" stroke-width=\"4\" fill=\"none\"/>\n  <line x1=\"260\" y1=\"40\" x2=\"280\" y2=\"40\" stroke=\"black\" marker-end=\"url(#arrow3)\"/>\n  <rect x=\"300\" y=\"20\" width=\"40\" height=\"40\" fill=\"none\" stroke=\"#999\" stroke-dasharray=\"4\"/>\n  <text x=\"320\" y=\"45\" text-anchor=\"middle\">?</text>\n</svg>"},
        {"type": "text", "content": "Up -> Right. Right -> ...?"}
    ]'::jsonb, 
    '["Down", "Up", "Left"]'::jsonb, 
    0, 
    null, 
    '[
        {"type": "text", "content": "The pattern rotates 90 degrees clockwise."},
        {"type": "text", "content": "Up -> Right -> Down."}
    ]'::jsonb, 
    'hard', 
    85,
    'Spatial Reasoning',
    '1'
);
