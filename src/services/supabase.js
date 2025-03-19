import { createClient } from '@supabase/supabase-js'
import SUPABASE_CONFIG from '../config/supabase.config'

// Create Supabase client
const SUPABASE = createClient(
  SUPABASE_CONFIG.SUPABASE_URL,
  SUPABASE_CONFIG.SUPABASE_ANON_KEY
)

export { SUPABASE }
