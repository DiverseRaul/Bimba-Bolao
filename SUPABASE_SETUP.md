# Supabase Setup for Bimba Bolao

This guide explains how to set up and use Supabase in the Bimba Bolao soccer prediction platform.

## Setup Instructions

### 1. Create a Supabase Project

1. Go to [Supabase](https://supabase.com/) and sign up/login
2. Create a new project
3. Note your project URL and anon key from the API settings

### 2. Configure Supabase Credentials

Update the configuration file with your Supabase credentials:

```javascript
// src/config/supabase.config.js
const SUPABASE_CONFIG = {
  SUPABASE_URL: 'https://your-actual-project-url.supabase.co',
  SUPABASE_ANON_KEY: 'your-actual-supabase-anon-key'
}

export default SUPABASE_CONFIG
```

### 3. Set Up Database Schema

1. Go to the SQL Editor in your Supabase dashboard
2. Copy and paste the contents of `migrations/schema.sql`
3. Run the SQL script to create all necessary tables and functions

## Using Supabase in Components

### Authentication

```javascript
// Login with email and password
async function LOGIN_USER(EMAIL, PASSWORD) {
  const { data, error } = await this.$supabase.auth.signInWithPassword({
    email: EMAIL,
    password: PASSWORD
  })
  return { data, error }
}

// Register a new user
async function REGISTER_USER(EMAIL, PASSWORD, USERNAME) {
  const { data: authData, error: authError } = await this.$supabase.auth.signUp({
    email: EMAIL,
    password: PASSWORD
  })
  
  if (authError) return { data: null, error: authError }
  
  // Create user profile
  const { data, error } = await this.$supabase
    .from('USERS')
    .insert([{ 
      ID: authData.user.id, 
      USERNAME: USERNAME 
    }])
    
  return { data, error }
}
```

### Data Operations

```javascript
// Get matches
async function GET_MATCHES() {
  const { data, error } = await this.$supabase
    .from('MATCHES')
    .select(`
      ID,
      MATCH_DATE,
      HOME_SCORE,
      AWAY_SCORE,
      STATUS,
      HOME_TEAM:TEAMS!HOME_TEAM_ID(ID, NAME, LOGO_URL),
      AWAY_TEAM:TEAMS!AWAY_TEAM_ID(ID, NAME, LOGO_URL)
    `)
    .order('MATCH_DATE', { ascending: true })
    
  return { data, error }
}

// Create prediction
async function CREATE_PREDICTION(MATCH_ID, HOME_SCORE, AWAY_SCORE) {
  const { data, error } = await this.$supabase
    .from('PREDICTIONS')
    .insert([{
      USER_ID: this.$supabase.auth.user().id,
      MATCH_ID: MATCH_ID,
      HOME_SCORE: HOME_SCORE,
      AWAY_SCORE: AWAY_SCORE
    }])
    
  return { data, error }
}

// Get leaderboard
async function GET_LEADERBOARD(COMPETITION_ID) {
  const { data, error } = await this.$supabase
    .from('LEADERBOARD')
    .select('*')
    .eq('COMPETITION_ID', COMPETITION_ID)
    
  return { data, error }
}
```

### Real-time Subscriptions

```javascript
// Subscribe to match updates
function SUBSCRIBE_TO_MATCHES() {
  const SUBSCRIPTION = this.$supabase
    .from('MATCHES')
    .on('UPDATE', payload => {
      // Handle match update
      console.log('Match updated:', payload.new)
    })
    .subscribe()
    
  return SUBSCRIPTION
}
```

## Multilingual Support

To implement multilingual support with Supabase:

1. Store user language preference in the USERS table
2. Create translation tables or files for each supported language
3. Use the user's language preference to fetch the appropriate translations

## Security Best Practices

1. Never expose your Supabase keys in client-side code
2. Use Row Level Security (RLS) policies to control data access
3. Validate all user inputs before sending to Supabase
4. Use prepared statements to prevent SQL injection
