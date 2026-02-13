-- Enable RLS on practice_sessions if not already enabled
ALTER TABLE practice_sessions ENABLE ROW LEVEL SECURITY;

-- Create policy to allow users to INSERT their own sessions
CREATE POLICY "Users can insert their own practice sessions" 
ON practice_sessions FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = user_id);

-- Create policy to allow users to VIEW their own practice sessions
CREATE POLICY "Users can view their own practice sessions" 
ON practice_sessions FOR SELECT 
TO authenticated 
USING (auth.uid() = user_id);
