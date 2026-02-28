const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ path: '.env.local' });

async function test() {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!supabaseUrl || !supabaseKey) { console.log("Missing supabase credentials"); process.exit(1); }

  const supabase = createClient(supabaseUrl, supabaseKey);
  const { data, error, count } = await supabase.from('questions').select('*', { count: 'exact', head: true });
  console.log("Total questions in Supabase:", count, error);
  process.exit(0);
}
test();
