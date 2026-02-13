-- ==========================================
-- CREATE ACTIVITY TABLE
-- Stores user test results and practice history.
-- ==========================================

CREATE TABLE IF NOT EXISTS student_activities (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    test_title TEXT NOT NULL,
    test_type TEXT DEFAULT 'practice', -- 'exam' or 'practice'
    score INT DEFAULT 0,
    total_score INT DEFAULT 0,
    passed BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS (Row Level Security) - simplified for now
ALTER TABLE student_activities ENABLE ROW LEVEL SECURITY;

-- Policy: Users can insert their own activity
CREATE POLICY "Users can insert their own activity" 
ON student_activities FOR INSERT 
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can view their own activity
CREATE POLICY "Users can view their own activity" 
ON student_activities FOR SELECT 
USING (auth.uid() = user_id);
