-- Supabase Tables for Bimba Bolao

-- Users table (managed by Supabase Auth)
-- This is just a reference, as Supabase Auth handles the users table

-- Groups table
CREATE TABLE IF NOT EXISTS GROUPS (
  ID UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  NAME TEXT NOT NULL,
  DESCRIPTION TEXT,
  CREATED_BY UUID REFERENCES auth.users(id),
  CREATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UPDATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Group Members table
CREATE TABLE IF NOT EXISTS GROUP_MEMBERS (
  ID UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  GROUP_ID UUID REFERENCES GROUPS(ID) ON DELETE CASCADE,
  USER_ID UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  ROLE TEXT NOT NULL CHECK (ROLE IN ('ADMIN', 'MEMBER')),
  CREATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UPDATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(GROUP_ID, USER_ID)
);

-- Group Invites table
CREATE TABLE IF NOT EXISTS GROUP_INVITES (
  ID UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  GROUP_ID UUID REFERENCES GROUPS(ID) ON DELETE CASCADE,
  CODE TEXT NOT NULL UNIQUE,
  CREATED_BY UUID REFERENCES auth.users(id),
  CREATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  EXPIRES_AT TIMESTAMP WITH TIME ZONE NOT NULL,
  USED_AT TIMESTAMP WITH TIME ZONE
);

-- Matches table
CREATE TABLE IF NOT EXISTS MATCHES (
  ID UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  HOME_TEAM TEXT NOT NULL,
  AWAY_TEAM TEXT NOT NULL,
  HOME_TEAM_LOGO TEXT,
  AWAY_TEAM_LOGO TEXT,
  MATCH_TIME TIMESTAMP WITH TIME ZONE NOT NULL,
  MATCH_RESULT TEXT,
  CREATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UPDATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Predictions table
CREATE TABLE IF NOT EXISTS PREDICTIONS (
  ID UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  USER_ID UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  MATCH_ID UUID REFERENCES MATCHES(ID) ON DELETE CASCADE,
  HOME_SCORE INTEGER NOT NULL,
  AWAY_SCORE INTEGER NOT NULL,
  POINTS INTEGER,
  CREATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UPDATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(USER_ID, MATCH_ID)
);

-- Create a database function to handle group creation in a single transaction
CREATE OR REPLACE FUNCTION create_group_with_member(
  group_name TEXT,
  group_description TEXT,
  user_id UUID
) RETURNS UUID AS $$
DECLARE
  new_group_id UUID;
  invite_code TEXT;
BEGIN
  -- Generate invite code
  SELECT array_to_string(array(
    SELECT substr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', ((random() * 36)::integer + 1)::integer, 1)
    FROM generate_series(1, 10)
  ), '') || '-' || substr(extract(epoch from now())::text, 7) INTO invite_code;
  
  -- Insert group
  INSERT INTO GROUPS (NAME, DESCRIPTION, CREATED_BY)
  VALUES (group_name, group_description, user_id)
  RETURNING ID INTO new_group_id;
  
  -- Insert member
  INSERT INTO GROUP_MEMBERS (GROUP_ID, USER_ID, ROLE)
  VALUES (new_group_id, user_id, 'ADMIN');
  
  -- Insert invite
  INSERT INTO GROUP_INVITES (GROUP_ID, CODE, CREATED_BY, EXPIRES_AT)
  VALUES (new_group_id, invite_code, user_id, now() + interval '30 days');
  
  RETURN new_group_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION create_group_with_member TO authenticated;

-- Update the RLS policies to be more permissive
ALTER TABLE GROUPS DISABLE ROW LEVEL SECURITY;
ALTER TABLE GROUP_MEMBERS DISABLE ROW LEVEL SECURITY;
ALTER TABLE GROUP_INVITES DISABLE ROW LEVEL SECURITY;

-- Re-enable RLS with updated policies
ALTER TABLE GROUPS ENABLE ROW LEVEL SECURITY;
ALTER TABLE GROUP_MEMBERS ENABLE ROW LEVEL SECURITY;
ALTER TABLE GROUP_INVITES ENABLE ROW LEVEL SECURITY;

-- Create simple policies that allow all operations for authenticated users
CREATE POLICY "Allow all operations for authenticated users" ON GROUPS
  FOR ALL USING (auth.uid() IS NOT NULL);

CREATE POLICY "Allow all operations for authenticated users" ON GROUP_MEMBERS
  FOR ALL USING (auth.uid() IS NOT NULL);

CREATE POLICY "Allow all operations for authenticated users" ON GROUP_INVITES
  FOR ALL USING (auth.uid() IS NOT NULL);

-- Enable RLS (Row Level Security)
ALTER TABLE MATCHES ENABLE ROW LEVEL SECURITY;
ALTER TABLE PREDICTIONS ENABLE ROW LEVEL SECURITY;

-- Create policies
-- Groups policies
DROP POLICY IF EXISTS "Groups are viewable by members" ON GROUPS;

-- Group Members policies
DROP POLICY IF EXISTS "Group members are viewable by group members" ON GROUP_MEMBERS;

-- Group Invites policies
DROP POLICY IF EXISTS "Invites are viewable by group admins" ON GROUP_INVITES;

-- Matches policies
CREATE POLICY "Matches are viewable by all authenticated users" ON MATCHES
  FOR SELECT USING (auth.uid() IS NOT NULL);

-- Predictions policies
CREATE POLICY "Users can view their own predictions" ON PREDICTIONS
  FOR SELECT USING (auth.uid() = USER_ID);

CREATE POLICY "Users can create their own predictions" ON PREDICTIONS
  FOR INSERT WITH CHECK (auth.uid() = USER_ID);

CREATE POLICY "Users can update their own predictions" ON PREDICTIONS
  FOR UPDATE USING (auth.uid() = USER_ID);