/*
  # Business Management System Database Schema

  1. New Tables
    - `companies` - Business companies and organizations
    - `contacts` - Individual contacts within companies
    - `deals` - Sales deals and opportunities
    - `inventory_items` - Inventory products and items
    - `stock_movements` - Track inventory movements
    - `tasks` - Task management
    - `communications` - Communication logs

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users to manage their data
*/

-- Companies table
CREATE TABLE IF NOT EXISTS companies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  industry text DEFAULT '',
  size text DEFAULT '',
  website text DEFAULT '',
  phone text DEFAULT '',
  email text DEFAULT '',
  address text DEFAULT '',
  notes text DEFAULT '',
  relationship_strength integer DEFAULT 3 CHECK (relationship_strength >= 1 AND relationship_strength <= 5),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Contacts table
CREATE TABLE IF NOT EXISTS contacts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  first_name text NOT NULL,
  last_name text NOT NULL,
  title text DEFAULT '',
  email text DEFAULT '',
  phone text DEFAULT '',
  department text DEFAULT '',
  notes text DEFAULT '',
  is_primary boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Deals table
CREATE TABLE IF NOT EXISTS deals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  contact_id uuid REFERENCES contacts(id) ON DELETE SET NULL,
  title text NOT NULL,
  description text DEFAULT '',
  value decimal(15,2) DEFAULT 0,
  stage text DEFAULT 'prospecting',
  probability integer DEFAULT 0 CHECK (probability >= 0 AND probability <= 100),
  expected_close_date date,
  actual_close_date date,
  status text DEFAULT 'open',
  notes text DEFAULT '',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Inventory items table
CREATE TABLE IF NOT EXISTS inventory_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sku text UNIQUE NOT NULL,
  name text NOT NULL,
  description text DEFAULT '',
  category text DEFAULT '',
  brand text DEFAULT '',
  cost_price decimal(10,2) DEFAULT 0,
  sell_price decimal(10,2) DEFAULT 0,
  current_stock integer DEFAULT 0,
  min_stock_level integer DEFAULT 0,
  max_stock_level integer DEFAULT 1000,
  unit text DEFAULT 'pcs',
  location text DEFAULT '',
  supplier text DEFAULT '',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Stock movements table
CREATE TABLE IF NOT EXISTS stock_movements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  item_id uuid REFERENCES inventory_items(id) ON DELETE CASCADE,
  movement_type text NOT NULL CHECK (movement_type IN ('in', 'out', 'adjustment')),
  quantity integer NOT NULL,
  reason text DEFAULT '',
  reference text DEFAULT '',
  cost_per_unit decimal(10,2) DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Tasks table
CREATE TABLE IF NOT EXISTS tasks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text DEFAULT '',
  assigned_to uuid,
  company_id uuid REFERENCES companies(id) ON DELETE SET NULL,
  contact_id uuid REFERENCES contacts(id) ON DELETE SET NULL,
  deal_id uuid REFERENCES deals(id) ON DELETE SET NULL,
  due_date date,
  priority text DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'cancelled')),
  completed_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Communications table
CREATE TABLE IF NOT EXISTS communications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE SET NULL,
  contact_id uuid REFERENCES contacts(id) ON DELETE SET NULL,
  deal_id uuid REFERENCES deals(id) ON DELETE SET NULL,
  type text NOT NULL CHECK (type IN ('email', 'call', 'meeting', 'note')),
  subject text NOT NULL,
  content text DEFAULT '',
  direction text DEFAULT 'outbound' CHECK (direction IN ('inbound', 'outbound')),
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
DO $$
BEGIN
  -- Enable RLS on tables if not already enabled
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables 
    WHERE schemaname = 'public' 
    AND tablename = 'companies' 
    AND rowsecurity = true
  ) THEN
    ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables 
    WHERE schemaname = 'public' 
    AND tablename = 'contacts' 
    AND rowsecurity = true
  ) THEN
    ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables 
    WHERE schemaname = 'public' 
    AND tablename = 'deals' 
    AND rowsecurity = true
  ) THEN
    ALTER TABLE deals ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables 
    WHERE schemaname = 'public' 
    AND tablename = 'inventory_items' 
    AND rowsecurity = true
  ) THEN
    ALTER TABLE inventory_items ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables 
    WHERE schemaname = 'public' 
    AND tablename = 'stock_movements' 
    AND rowsecurity = true
  ) THEN
    ALTER TABLE stock_movements ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables 
    WHERE schemaname = 'public' 
    AND tablename = 'tasks' 
    AND rowsecurity = true
  ) THEN
    ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables 
    WHERE schemaname = 'public' 
    AND tablename = 'communications' 
    AND rowsecurity = true
  ) THEN
    ALTER TABLE communications ENABLE ROW LEVEL SECURITY;
  END IF;
END $$;

-- Create policies (allowing all operations for authenticated users for this demo)
DO $$
BEGIN
  -- Create policies if they don't exist
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'companies' 
    AND policyname = 'Users can manage companies'
  ) THEN
    CREATE POLICY "Users can manage companies" ON companies FOR ALL TO authenticated USING (true);
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'contacts' 
    AND policyname = 'Users can manage contacts'
  ) THEN
    CREATE POLICY "Users can manage contacts" ON contacts FOR ALL TO authenticated USING (true);
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'deals' 
    AND policyname = 'Users can manage deals'
  ) THEN
    CREATE POLICY "Users can manage deals" ON deals FOR ALL TO authenticated USING (true);
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'inventory_items' 
    AND policyname = 'Users can manage inventory'
  ) THEN
    CREATE POLICY "Users can manage inventory" ON inventory_items FOR ALL TO authenticated USING (true);
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'stock_movements' 
    AND policyname = 'Users can manage stock movements'
  ) THEN
    CREATE POLICY "Users can manage stock movements" ON stock_movements FOR ALL TO authenticated USING (true);
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'tasks' 
    AND policyname = 'Users can manage tasks'
  ) THEN
    CREATE POLICY "Users can manage tasks" ON tasks FOR ALL TO authenticated USING (true);
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'communications' 
    AND policyname = 'Users can manage communications'
  ) THEN
    CREATE POLICY "Users can manage communications" ON communications FOR ALL TO authenticated USING (true);
  END IF;
END $$;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_contacts_company_id ON contacts(company_id);
CREATE INDEX IF NOT EXISTS idx_deals_company_id ON deals(company_id);
CREATE INDEX IF NOT EXISTS idx_deals_contact_id ON deals(contact_id);
CREATE INDEX IF NOT EXISTS idx_stock_movements_item_id ON stock_movements(item_id);
CREATE INDEX IF NOT EXISTS idx_tasks_company_id ON tasks(company_id);
CREATE INDEX IF NOT EXISTS idx_tasks_contact_id ON tasks(contact_id);
CREATE INDEX IF NOT EXISTS idx_tasks_deal_id ON tasks(deal_id);
CREATE INDEX IF NOT EXISTS idx_communications_company_id ON communications(company_id);
CREATE INDEX IF NOT EXISTS idx_communications_contact_id ON communications(contact_id);
CREATE INDEX IF NOT EXISTS idx_communications_deal_id ON communications(deal_id);

-- Function to update updated_at timestamp
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_proc 
    WHERE proname = 'update_updated_at_column'
  ) THEN
    CREATE OR REPLACE FUNCTION update_updated_at_column()
    RETURNS TRIGGER AS $$
    BEGIN
        NEW.updated_at = now();
        RETURN NEW;
    END;
    $$ language 'plpgsql';
  END IF;
END $$;

-- Create triggers for updated_at
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger 
    WHERE tgname = 'update_companies_updated_at'
  ) THEN
    CREATE TRIGGER update_companies_updated_at BEFORE UPDATE ON companies FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger 
    WHERE tgname = 'update_contacts_updated_at'
  ) THEN
    CREATE TRIGGER update_contacts_updated_at BEFORE UPDATE ON contacts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger 
    WHERE tgname = 'update_deals_updated_at'
  ) THEN
    CREATE TRIGGER update_deals_updated_at BEFORE UPDATE ON deals FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger 
    WHERE tgname = 'update_inventory_items_updated_at'
  ) THEN
    CREATE TRIGGER update_inventory_items_updated_at BEFORE UPDATE ON inventory_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger 
    WHERE tgname = 'update_tasks_updated_at'
  ) THEN
    CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

-- Insert sample data only if tables are empty
DO $$
BEGIN
  -- Insert sample companies if none exist
  IF NOT EXISTS (SELECT 1 FROM companies LIMIT 1) THEN
    INSERT INTO companies (name, industry, size, website, phone, email, address, relationship_strength) VALUES
    ('TechCorp Solutions', 'Technology', 'Large (500+ employees)', 'https://techcorp.com', '+1-555-0101', 'info@techcorp.com', '123 Tech Street, Silicon Valley, CA 94000', 5),
    ('Green Energy Inc', 'Renewable Energy', 'Medium (50-200 employees)', 'https://greenenergy.com', '+1-555-0102', 'contact@greenenergy.com', '456 Solar Ave, Austin, TX 78701', 4),
    ('Urban Design Studio', 'Architecture', 'Small (10-50 employees)', 'https://urbandesign.com', '+1-555-0103', 'hello@urbandesign.com', '789 Design Blvd, New York, NY 10001', 3),
    ('MedTech Innovations', 'Healthcare', 'Medium (100-300 employees)', 'https://medtech.com', '+1-555-0104', 'info@medtech.com', '321 Health Way, Boston, MA 02101', 4),
    ('Food & Flavor Co', 'Food & Beverage', 'Small (20-50 employees)', 'https://foodflavor.com', '+1-555-0105', 'orders@foodflavor.com', '654 Taste Street, Portland, OR 97201', 2);
  END IF;

  -- Insert sample contacts if none exist
  IF NOT EXISTS (SELECT 1 FROM contacts LIMIT 1) THEN
    INSERT INTO contacts (company_id, first_name, last_name, title, email, phone, department, is_primary) VALUES
    ((SELECT id FROM companies WHERE name = 'TechCorp Solutions' LIMIT 1), 'John', 'Mitchell', 'CTO', 'john.mitchell@techcorp.com', '+1-555-0111', 'Technology', true),
    ((SELECT id FROM companies WHERE name = 'TechCorp Solutions' LIMIT 1), 'Sarah', 'Chen', 'Product Manager', 'sarah.chen@techcorp.com', '+1-555-0112', 'Product', false),
    ((SELECT id FROM companies WHERE name = 'Green Energy Inc' LIMIT 1), 'Michael', 'Rodriguez', 'CEO', 'michael@greenenergy.com', '+1-555-0121', 'Executive', true),
    ((SELECT id FROM companies WHERE name = 'Urban Design Studio' LIMIT 1), 'Emily', 'Thompson', 'Lead Architect', 'emily@urbandesign.com', '+1-555-0131', 'Design', true),
    ((SELECT id FROM companies WHERE name = 'MedTech Innovations' LIMIT 1), 'David', 'Park', 'VP of Sales', 'david.park@medtech.com', '+1-555-0141', 'Sales', true),
    ((SELECT id FROM companies WHERE name = 'Food & Flavor Co' LIMIT 1), 'Lisa', 'Anderson', 'Operations Manager', 'lisa@foodflavor.com', '+1-555-0151', 'Operations', true);
  END IF;

  -- Insert sample deals if none exist
  IF NOT EXISTS (SELECT 1 FROM deals LIMIT 1) THEN
    INSERT INTO deals (company_id, contact_id, title, description, value, stage, probability, expected_close_date, status) VALUES
    ((SELECT id FROM companies WHERE name = 'TechCorp Solutions' LIMIT 1), (SELECT id FROM contacts WHERE email = 'john.mitchell@techcorp.com' LIMIT 1), 'Enterprise Software License', 'Annual license for enterprise management software', 150000.00, 'negotiation', 75, '2024-02-15', 'open'),
    ((SELECT id FROM companies WHERE name = 'Green Energy Inc' LIMIT 1), (SELECT id FROM contacts WHERE email = 'michael@greenenergy.com' LIMIT 1), 'Solar Panel Installation', 'Commercial solar panel system installation', 85000.00, 'proposal', 60, '2024-03-01', 'open'),
    ((SELECT id FROM companies WHERE name = 'Urban Design Studio' LIMIT 1), (SELECT id FROM contacts WHERE email = 'emily@urbandesign.com' LIMIT 1), 'Office Design Consultation', 'Complete office space redesign project', 45000.00, 'qualification', 40, '2024-02-28', 'open'),
    ((SELECT id FROM companies WHERE name = 'MedTech Innovations' LIMIT 1), (SELECT id FROM contacts WHERE email = 'david.park@medtech.com' LIMIT 1), 'Medical Equipment Purchase', 'Bulk purchase of medical monitoring devices', 220000.00, 'prospecting', 25, '2024-04-15', 'open'),
    ((SELECT id FROM companies WHERE name = 'Food & Flavor Co' LIMIT 1), (SELECT id FROM contacts WHERE email = 'lisa@foodflavor.com' LIMIT 1), 'Supply Chain Software', 'Implementation of supply chain management system', 35000.00, 'closed-won', 100, '2024-01-15', 'closed');
  END IF;

  -- Insert sample inventory items if none exist
  IF NOT EXISTS (SELECT 1 FROM inventory_items LIMIT 1) THEN
    INSERT INTO inventory_items (sku, name, description, category, brand, cost_price, sell_price, current_stock, min_stock_level, max_stock_level, unit, location, supplier) VALUES
    ('LAPTOP-001', 'Business Laptop Pro', '15-inch professional laptop for business use', 'Electronics', 'TechBrand', 800.00, 1200.00, 25, 5, 50, 'pcs', 'Warehouse A-1', 'TechSupplier Inc'),
    ('DESK-001', 'Executive Office Desk', 'Premium wooden executive desk with drawers', 'Furniture', 'OfficeElite', 450.00, 750.00, 12, 3, 20, 'pcs', 'Warehouse B-2', 'Furniture Direct'),
    ('CHAIR-001', 'Ergonomic Office Chair', 'High-back ergonomic chair with lumbar support', 'Furniture', 'ComfortSeating', 180.00, 320.00, 35, 10, 60, 'pcs', 'Warehouse B-1', 'Seating Solutions'),
    ('MONITOR-001', '27-inch 4K Monitor', 'Ultra HD 4K monitor for professional use', 'Electronics', 'DisplayTech', 320.00, 520.00, 18, 8, 40, 'pcs', 'Warehouse A-2', 'Display World'),
    ('PRINTER-001', 'Multifunction Laser Printer', 'Color laser printer with scan and copy features', 'Electronics', 'PrintMaster', 280.00, 450.00, 8, 3, 15, 'pcs', 'Warehouse A-3', 'Office Equipment Co'),
    ('PAPER-001', 'Premium Copy Paper', 'High-quality A4 copy paper, 500 sheets per ream', 'Office Supplies', 'PaperPlus', 4.50, 8.00, 150, 50, 300, 'ream', 'Storage Room C', 'Paper Supply Co');
  END IF;

  -- Insert sample stock movements if none exist
  IF NOT EXISTS (SELECT 1 FROM stock_movements LIMIT 1) THEN
    INSERT INTO stock_movements (item_id, movement_type, quantity, reason, reference, cost_per_unit) VALUES
    ((SELECT id FROM inventory_items WHERE sku = 'LAPTOP-001' LIMIT 1), 'in', 30, 'Initial stock purchase', 'PO-2024-001', 800.00),
    ((SELECT id FROM inventory_items WHERE sku = 'LAPTOP-001' LIMIT 1), 'out', 5, 'Sale to TechCorp Solutions', 'SO-2024-001', 800.00),
    ((SELECT id FROM inventory_items WHERE sku = 'DESK-001' LIMIT 1), 'in', 15, 'Initial stock purchase', 'PO-2024-002', 450.00),
    ((SELECT id FROM inventory_items WHERE sku = 'DESK-001' LIMIT 1), 'out', 3, 'Sale to Urban Design Studio', 'SO-2024-002', 450.00),
    ((SELECT id FROM inventory_items WHERE sku = 'CHAIR-001' LIMIT 1), 'in', 40, 'Initial stock purchase', 'PO-2024-003', 180.00),
    ((SELECT id FROM inventory_items WHERE sku = 'CHAIR-001' LIMIT 1), 'out', 5, 'Sale to various customers', 'SO-2024-003', 180.00);
  END IF;

  -- Insert sample tasks if none exist
  IF NOT EXISTS (SELECT 1 FROM tasks LIMIT 1) THEN
    INSERT INTO tasks (title, description, company_id, contact_id, deal_id, due_date, priority, status) VALUES
    ('Follow up on Enterprise Software Deal', 'Call John Mitchell to discuss contract terms and next steps', (SELECT id FROM companies WHERE name = 'TechCorp Solutions' LIMIT 1), (SELECT id FROM contacts WHERE email = 'john.mitchell@techcorp.com' LIMIT 1), (SELECT id FROM deals WHERE title = 'Enterprise Software License' LIMIT 1), '2024-01-25', 'high', 'pending'),
    ('Prepare Solar Panel Proposal', 'Create detailed proposal for Green Energy Inc solar installation project', (SELECT id FROM companies WHERE name = 'Green Energy Inc' LIMIT 1), (SELECT id FROM contacts WHERE email = 'michael@greenenergy.com' LIMIT 1), (SELECT id FROM deals WHERE title = 'Solar Panel Installation' LIMIT 1), '2024-01-28', 'high', 'pending'),
    ('Design Consultation Meeting', 'Schedule and prepare for office design consultation with Urban Design Studio', (SELECT id FROM companies WHERE name = 'Urban Design Studio' LIMIT 1), (SELECT id FROM contacts WHERE email = 'emily@urbandesign.com' LIMIT 1), (SELECT id FROM deals WHERE title = 'Office Design Consultation' LIMIT 1), '2024-01-30', 'medium', 'pending'),
    ('Restock Low Inventory Items', 'Order new stock for items below minimum threshold', NULL, NULL, NULL, '2024-01-26', 'medium', 'pending'),
    ('Update CRM Data', 'Clean and update contact information in CRM system', NULL, NULL, NULL, '2024-01-27', 'low', 'pending');
  END IF;

  -- Insert sample communications if none exist
  IF NOT EXISTS (SELECT 1 FROM communications LIMIT 1) THEN
    INSERT INTO communications (company_id, contact_id, deal_id, type, subject, content, direction) VALUES
    ((SELECT id FROM companies WHERE name = 'TechCorp Solutions' LIMIT 1), (SELECT id FROM contacts WHERE email = 'john.mitchell@techcorp.com' LIMIT 1), (SELECT id FROM deals WHERE title = 'Enterprise Software License' LIMIT 1), 'email', 'Enterprise Software License Discussion', 'Initial discussion about enterprise software requirements and pricing options.', 'outbound'),
    ((SELECT id FROM companies WHERE name = 'Green Energy Inc' LIMIT 1), (SELECT id FROM contacts WHERE email = 'michael@greenenergy.com' LIMIT 1), (SELECT id FROM deals WHERE title = 'Solar Panel Installation' LIMIT 1), 'call', 'Solar Installation Requirements Call', 'Phone call to discuss site requirements and installation timeline for solar panel project.', 'outbound'),
    ((SELECT id FROM companies WHERE name = 'Urban Design Studio' LIMIT 1), (SELECT id FROM contacts WHERE email = 'emily@urbandesign.com' LIMIT 1), (SELECT id FROM deals WHERE title = 'Office Design Consultation' LIMIT 1), 'meeting', 'Office Design Consultation Meeting', 'In-person meeting to discuss office space requirements and design preferences.', 'inbound'),
    ((SELECT id FROM companies WHERE name = 'MedTech Innovations' LIMIT 1), (SELECT id FROM contacts WHERE email = 'david.park@medtech.com' LIMIT 1), (SELECT id FROM deals WHERE title = 'Medical Equipment Purchase' LIMIT 1), 'email', 'Medical Equipment Inquiry', 'Initial inquiry about bulk purchase of medical monitoring devices.', 'inbound'),
    ((SELECT id FROM companies WHERE name = 'Food & Flavor Co' LIMIT 1), (SELECT id FROM contacts WHERE email = 'lisa@foodflavor.com' LIMIT 1), (SELECT id FROM deals WHERE title = 'Supply Chain Software' LIMIT 1), 'call', 'Project Completion Call', 'Final call to confirm successful implementation of supply chain management system.', 'outbound');
  END IF;
END $$;