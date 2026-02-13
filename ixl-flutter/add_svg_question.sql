-- ====================================================================
-- ADDING SVG SHAPES DRAG & DROP QUESTION
-- ====================================================================

INSERT INTO questions (micro_skill_id, type, parts, drag_groups, drag_items, solution, difficulty) VALUES 
(
    '99999999-9999-9999-9999-999999999999', -- Sort Vowel Sounds skill (Reusing existing D&D skill for simplicity)
    'dragAndDrop',
    '[{"type": "text", "content": "Sort the shapes."}]'::jsonb,
    -- Groups
    '[
      {"id": "g1", "label": "Circles"},
      {"id": "g2", "label": "Squares"}
    ]'::jsonb,
    -- SVG Items
    '[
      {
        "id": "i1", 
        "type": "svg", 
        "target_group_id": "g1",
        "content": "<svg viewBox=\"0 0 100 100\" xmlns=\"http://www.w3.org/2000/svg\"><circle cx=\"50\" cy=\"50\" r=\"40\" fill=\"#FF5722\" /></svg>"
      },
      {
        "id": "i2", 
        "type": "svg", 
        "target_group_id": "g2",
        "content": "<svg viewBox=\"0 0 100 100\" xmlns=\"http://www.w3.org/2000/svg\"><rect x=\"10\" y=\"10\" width=\"80\" height=\"80\" fill=\"#2196F3\" /></svg>"
      },
      {
        "id": "i3", 
        "type": "svg", 
        "target_group_id": "g1",
        "content": "<svg viewBox=\"0 0 100 100\" xmlns=\"http://www.w3.org/2000/svg\"><circle cx=\"50\" cy=\"50\" r=\"30\" fill=\"#FFC107\" stroke=\"black\" stroke-width=\"4\" /></svg>"
      },
      {
        "id": "i4", 
        "type": "svg", 
        "target_group_id": "g2",
        "content": "<svg viewBox=\"0 0 100 100\" xmlns=\"http://www.w3.org/2000/svg\"><rect x=\"20\" y=\"20\" width=\"60\" height=\"60\" fill=\"#4CAF50\" rx=\"10\" /></svg>"
      }
    ]'::jsonb,
    'Circles are round. Squares have 4 equal sides.',
    'easy'
);
