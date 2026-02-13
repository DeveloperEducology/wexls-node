
import { createBrowserClient } from '@supabase/ssr'
import { Database } from '../database.types'

// Type client based on generated database types
export const createClient = () => {
    return createBrowserClient<Database>(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    )
}
