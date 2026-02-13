-- ==========================================
-- UPDATE TEST SCHEMA & SEED DATA
-- Updates test_series table and adds sample data.
-- ==========================================

-- 1. Add 'type' column to test_series if missing
DO $$
BEGIN
    ALTER TABLE test_series ADD COLUMN type TEXT DEFAULT 'mock';
EXCEPTION
    WHEN duplicate_column THEN 
    -- Do nothing if it already exists
END $$;


-- 2. Insert Sample Mock Tests & Previous Papers
-- We will use target_class='Class 6' to match the likely user profile.

INSERT INTO test_series (title, description, duration, category, target_class, type, is_free)
VALUES
-- Mock Tests
('Full Mock Test 1', 'Complete Navodaya Pattern Test', 120, 'Navodaya', 'Class 6', 'mock', true),
('Full Mock Test 2', 'Complete Navodaya Pattern Test', 120, 'Navodaya', 'Class 6', 'mock', true),

-- Previous Papers
('JNVST 2024 Paper', 'Previous Year Question Paper', 120, 'Navodaya', 'Class 6', 'previous', true),
('JNVST 2023 Paper', 'Previous Year Question Paper', 120, 'Navodaya', 'Class 6', 'previous', true);
