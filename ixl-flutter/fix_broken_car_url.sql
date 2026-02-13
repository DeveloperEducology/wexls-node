-- Update the broken car image URL to a working one (Flaticon)
UPDATE "public"."questions"
SET "drag_items" = REPLACE("drag_items"::text, 
    'https://png.pngtree.com/png-vector/20250110/ourmid/pngtree-a-red-suv-car-in-side-view-png-image_15131280.png', 
    'https://cdn-icons-png.flaticon.com/512/3202/3202926.png')::jsonb
WHERE "drag_items"::text LIKE '%pngtree%';
