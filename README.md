# BizManager - Business Management System

BizManager is a comprehensive business management system that integrates Inventory, CRM, and Business Relationship Management into a single application.

## Features

- **Companies Management**: Track business relationships with companies
- **Contacts Management**: Manage contacts within companies
- **Deals Management**: Track sales opportunities and deals
- **Inventory Management**: Manage product inventory and stock levels
- **Tasks Management**: Assign and track tasks
- **Communications Tracking**: Log all communications with contacts

## Setup Instructions

### 1. Connect to Supabase

Before using the application, you need to connect to Supabase:

1. Click the "Connect to Supabase" button in the top right corner
2. Follow the prompts to connect to your Supabase project
3. After connecting, you'll need to set up your database:
   - Go to your Supabase dashboard
   - Navigate to the SQL Editor
   - Copy the contents of `supabase/migrations/create_tables.sql`
   - Run the SQL to create all necessary tables and sample data

### 2. Configure Environment Variables

The application requires the following environment variables:

1. `VITE_SUPABASE_URL`: Your Supabase project URL
2. `VITE_SUPABASE_ANON_KEY`: Your Supabase anonymous key

These should be automatically set when you connect to Supabase through the StackBlitz interface.

### 3. Start the Application

Once Supabase is connected and the database is set up, you can start using the application:

1. Sign up with any email and password
2. Explore the different sections of the application
3. Add, edit, and manage your business data

## Technology Stack

- React with TypeScript
- Tailwind CSS for styling
- Supabase for backend and authentication
- Recharts for data visualization
- Lucide React for icons

## Development

To run the application locally:

```bash
npm run dev
```

## Troubleshooting

If you encounter issues with Supabase connectivity:

1. Make sure you've clicked "Connect to Supabase" in the top right corner
2. Verify that your `.env` file contains the correct Supabase URL and anonymous key
3. Check that you've run the SQL migration script to create the necessary tables
4. Try signing out and signing back in to refresh your authentication token

## License

This project is licensed under the MIT License.