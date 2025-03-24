// Database Setup Script
const { createClient } = require('@supabase/supabase-js')
const fs = require('fs')
const path = require('path')

// Import configuration
const SUPABASE_URL = 'https://wnfrwuabfdiuuuaidjfi.supabase.co'
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY // This should be set as an environment variable

// Check if service key is available
if (!SUPABASE_SERVICE_KEY) {
  console.error('ERROR: SUPABASE_SERVICE_KEY environment variable is not set')
  console.error('Please set it using: set SUPABASE_SERVICE_KEY=your_service_key')
  process.exit(1)
}

// Create Supabase client with service role
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
})

async function setupDatabase() {
  try {
    console.log('Starting database setup...')
    
    // Read SQL file
    const sqlFilePath = path.join(__dirname, 'supabase_tables.sql')
    const sqlContent = fs.readFileSync(sqlFilePath, 'utf8')
    
    // Split SQL into individual statements
    const statements = sqlContent
      .replace(/--.*$/gm, '') // Remove comments
      .split(';')
      .filter(statement => statement.trim() !== '')
      .map(statement => statement.trim() + ';')
    
    console.log(`Found ${statements.length} SQL statements to execute`)
    
    // Execute each statement
    for (let i = 0; i < statements.length; i++) {
      const statement = statements[i]
      console.log(`Executing statement ${i + 1}/${statements.length}...`)
      
      const { error } = await supabase.rpc('exec_sql', { query: statement })
      
      if (error) {
        console.error(`Error executing statement ${i + 1}:`, error)
        console.error('Statement:', statement)
      }
    }
    
    console.log('Database setup completed successfully!')
    
    // Verify tables exist
    const { data: tables, error } = await supabase
      .from('information_schema.tables')
      .select('table_name')
      .eq('table_schema', 'public')
    
    if (error) {
      console.error('Error checking tables:', error)
    } else {
      console.log('Tables created:')
      tables.forEach(table => {
        console.log(`- ${table.table_name}`)
      })
    }
    
  } catch (error) {
    console.error('Error setting up database:', error)
  }
}

setupDatabase()
