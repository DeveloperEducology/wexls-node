-- ====================================================================
-- ADDING SORT BY SIZE DRAG & DROP QUESTION
-- ====================================================================

INSERT INTO questions (micro_skill_id, type, parts, drag_groups, drag_items, solution, difficulty) VALUES 
(
    '99999999-9999-9999-9999-999999999999', -- Reusing "Sort Vowel Sounds" skill for D&D demo
    'dragAndDrop',
    '[{"type": "text", "content": "Sort the items by size."}]'::jsonb,
    -- Groups
    '[
      {"id": "small", "label": "Small"},
      {"id": "medium", "label": "Medium"},
      {"id": "large", "label": "Large"}
    ]'::jsonb,
    -- SVG Items
    '[
      {
        "id": "s1", 
        "type": "svg", 
        "target_group_id": "small",
        "content": "<svg viewBox=\"0 0 100 100\" xmlns=\"http://www.w3.org/2000/svg\"><circle cx=\"50\" cy=\"50\" r=\"15\" fill=\"#FF5252\" /></svg>"
      },
      {
        "id": "s2", 
        "type": "svg", 
        "target_group_id": "small",
        "content": "<svg viewBox=\"0 0 100 100\" xmlns=\"http://www.w3.org/2000/svg\"><rect x=\"35\" y=\"35\" width=\"30\" height=\"30\" fill=\"#448AFF\" rx=\"4\" /></svg>"
      },
      
      {
        "id": "m1", 
        "type": "svg", 
        "target_group_id": "medium",
        "content": "<svg viewBox=\"0 0 100 100\" xmlns=\"http://www.w3.org/2000/svg\"><circle cx=\"50\" cy=\"50\" r=\"30\" fill=\"#66BB6A\" /></svg>"
      },
      {
        "id": "m2", 
        "type": "svg", 
        "target_group_id": "medium",
        "content": "<svg viewBox=\"0 0 100 100\" xmlns=\"http://www.w3.org/2000/svg\"><rect x=\"20\" y=\"20\" width=\"60\" height=\"60\" fill=\"#FFD740\" rx=\"6\" /></svg>"
      },

      {
        "id": "l1", 
        "type": "svg", 
        "target_group_id": "large",
        "content": "<svg viewBox=\"0 0 100 100\" xmlns=\"http://www.w3.org/2000/svg\"><circle cx=\"50\" cy=\"50\" r=\"45\" fill=\"#E040FB\" /></svg>"
      },
      {
        "id": "l2", 
        "type": "svg", 
        "target_group_id": "large",
        "content": "<svg viewBox=\"0 0 100 100\" xmlns=\"http://www.w3.org/2000/svg\"><rect x=\"5\" y=\"5\" width=\"90\" height=\"90\" fill=\"#FF6E40\" rx=\"8\" /></svg>"
      }
    ]'::jsonb,
    'Look at how much space each shape takes up.',
    'medium'
);
