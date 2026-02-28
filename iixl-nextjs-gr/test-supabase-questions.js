require('dotenv').config({ path: '.env.local' });
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);

async function test() {
  const { count } = await supabase.from('questions').select('*', { count: 'exact', head: true });
  console.log('Total questions in Supabase:', count);
  process.exit();
}
test();
