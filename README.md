# Bimba Bolao - Soccer Prediction Platform

A modern soccer prediction platform that allows users to create groups with friends and place score predictions on soccer games.

 

## Features

 

- User authentication with Supabase
- Dark/Light theme support with localStorage persistence
- User settings management
- Group creation and management
- Invitation system for joining groups
- Responsive design for all devices

 

## Project Setup

 

```bash
npm install
```

 

### Compiles and hot-reloads for development

 

```bash
npm run serve
```

 

### Compiles and minifies for production

 

```bash
npm run build
```

 

### Lints and fixes files

 

```bash
npm run lint
```

 

## Database Setup

 

This project uses Supabase as the backend. You need to set up the following tables in your Supabase project:

 

1. Run the SQL script in `supabase_tables.sql` in the Supabase SQL Editor to create all required tables:
   - GROUPS - for storing group information
   - GROUP_MEMBERS - for tracking group membership
   - GROUP_INVITES - for managing invitation codes

 

### How to run the SQL script

 

1. Log in to your Supabase dashboard
2. Navigate to the SQL Editor
3. Copy the contents of `supabase_tables.sql`
4. Paste into the SQL Editor
5. Click "Run" to execute the script

 

## Project Structure

 

```text
src/
├── assets/         # Static assets like images and icons
├── components/     # Reusable Vue components
├── config/         # Configuration files (Supabase config)
├── router/         # Vue Router configuration
├── services/       # API service calls
├── views/          # Page components
```

 

## Authentication Flow

 

The application implements a complete authentication flow

 

- Sign up
- Login
- Password reset
- Session management

 

## Group Management

 

Users can

 

- Create new prediction groups
- Join existing groups via invitation codes
- View groups they are members of
- Invite others to their groups

 

## Customization

 

See [Vue CLI Configuration Reference](https://cli.vuejs.org/config/) for customizing the configuration
