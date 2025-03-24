import { createClient } from '@supabase/supabase-js'
import SUPABASE_CONFIG from '../config/supabase.config'

// Create Supabase client with additional options
const SUPABASE = createClient(
  SUPABASE_CONFIG.SUPABASE_URL,
  SUPABASE_CONFIG.SUPABASE_ANON_KEY,
  {
    auth: {
      autoRefreshToken: true,
      persistSession: true,
      detectSessionInUrl: true
    },
    realtime: {
      timeout: 30000
    },
    db: {
      schema: 'public'
    },
    global: {
      headers: {
        'Content-Type': 'application/json',
        'X-Client-Info': 'bimba-bolao-app'
      }
    }
  }
)

// Test function to check authentication and database access
const testSupabaseConnection = async () => {
  try {
    // Test authentication
    const { data: authData, error: authError } = await SUPABASE.auth.getSession()
    
    if (authError) {
      console.error('Authentication error:', authError)
      return { success: false, error: authError, message: 'Authentication failed' }
    }
    
    if (!authData.session) {
      console.warn('No active session found')
      return { success: false, message: 'No active session' }
    }
    
    console.log('Authentication successful, user ID:', authData.session.user.id)
    
    // Test database access with a simple query
    const { data: testData, error: testError } = await SUPABASE
      .from('GROUPS')
      .select('count(*)')
      .limit(1)
    
    if (testError) {
      console.error('Database access error:', testError)
      return { success: false, error: testError, message: 'Database access failed' }
    }
    
    console.log('Database access successful')
    return { success: true, message: 'Connection test passed' }
  } catch (error) {
    console.error('Supabase connection test failed:', error)
    return { success: false, error, message: 'Connection test failed' }
  }
}

export { SUPABASE, testSupabaseConnection }
