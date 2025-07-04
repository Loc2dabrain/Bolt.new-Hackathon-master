/*
  # Business Management System Database Schema

  1. New Tables
    - `companies` - Business companies and organizations
      - `id` (uuid, primary key)
      - `name` (text, company name)
      - `industry` (text, industry type)
      - `size` (text, company size)
      - `website` (text, company website)
      - `phone` (text, phone number)
      - `email` (text, email address)
      - `address` (text, company address)
      - `notes` (text, additional notes)
      - `relationship_strength` (integer, 1-5 scale)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

    - `contacts` - Individual contacts within companies
      - `id` (uuid, primary key)
      - `company_id` (uuid, foreign key to companies)
      - `first_name` (text, contact first name)
      - `last_name` (text, contact last name)
      - `title` (text, job title)
      - `email` (text, email address)
      - `phone` (text, phone number)
      - `department` (text, department)
      - `notes` (text, additional notes)
      - `is_primary` (boolean, primary contact flag)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

    - `deals` - Sales deals and opportunities
      - `id` (uuid, primary key)
      - `company_id` (uuid, foreign key to companies)
      - `contact_id` (uuid, foreign key to contacts)
      - `title` (text, deal title)
      - `description` (text, deal description)
      - `value` (decimal, deal value)
      - `stage` (text, deal stage)
      - `probability` (integer, probability percentage)
      - `expected_close_date` (date, expected closing date)
      - `actual_close_date` (date, actual closing date)
      - `status` (text, deal status)
      - `notes` (text, additional notes)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

    - `inventory_items` - Inventory products and items
      - `id` (uuid, primary key)
      - `sku` (text, unique stock keeping unit)
      - `name` (text, item name)
      - `description` (text, item description)
      - `category` (text, item category)
      - `brand` (text, item brand)
      - `cost_price` (decimal, cost price)
      - `sell_price` (decimal, selling price)
      - `current_stock` (integer, current stock level)
      - `min_stock_level` (integer, minimum stock threshold)
      - `max_stock_level` (integer, maximum stock level)
      - `unit` (text, unit of measurement)
      - `location` (text, storage location)
      - `supplier` (text, supplier name)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

    - `stock_movements` - Track inventory movements
      - `id` (uuid, primary key)
      - `item_id` (uuid, foreign key to inventory_items)
      - `movement_type` (text, in/out/adjustment)
      - `quantity` (integer, quantity moved)
      - `reason` (text, reason for movement)
      - `reference` (text, reference number)
      - `cost_per_unit` (decimal, cost per unit)
      - `created_at` (timestamp)

    - `tasks` - Task management
      - `id` (uuid, primary key)
      - `title` (text, task title)
      - `description` (text, task description)
      - `assigned_to` (uuid, user id)
      - `company_id` (uuid, foreign key to companies, optional)
      - `contact_id` (uuid, foreign key to contacts, optional)
      - `deal_id` (uuid, foreign key to deals, optional)
      - `due_date` (date, due date)
      - `priority` (text, high/medium/low)
      - `status` (text, pending/completed/cancelled)
      - `completed_at` (timestamp, completion time)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

    - `communications` - Communication logs
      - `id` (uuid, primary key)
      - `company_id` (uuid, foreign key to companies, optional)
      - `contact_id` (uuid, foreign key to contacts, optional)
      - `deal_id` (uuid, foreign key to deals, optional)
      - `type` (text, email/call/meeting/note)
      - `subject` (text, communication subject)
      - `content` (text, communication content)
      - `direction` (text, inbound/outbound)
      - `created_at` (timestamp)

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
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE deals ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE communications ENABLE ROW LEVEL SECURITY;

-- Create policies (allowing all operations for authenticated users for this demo)
CREATE POLICY "Users can manage companies" ON companies FOR ALL TO authenticated USING (true);
CREATE POLICY "Users can manage contacts" ON contacts FOR ALL TO authenticated USING (true);
CREATE POLICY "Users can manage deals" ON deals FOR ALL TO authenticated USING (true);
CREATE POLICY "Users can manage inventory" ON inventory_items FOR ALL TO authenticated USING (true);
CREATE POLICY "Users can manage stock movements" ON stock_movements FOR ALL TO authenticated USING (true);
CREATE POLICY "Users can manage tasks" ON tasks FOR ALL TO authenticated USING (true);
CREATE POLICY "Users can manage communications" ON communications FOR ALL TO authenticated USING (true);

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
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_companies_updated_at BEFORE UPDATE ON companies FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_contacts_updated_at BEFORE UPDATE ON contacts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_deals_updated_at BEFORE UPDATE ON deals FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_inventory_items_updated_at BEFORE UPDATE ON inventory_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample companies
INSERT INTO companies (name, industry, size, website, phone, email, address, relationship_strength) VALUES
('TechCorp Solutions', 'Technology', 'Large (500+ employees)', 'https://techcorp.com', '+1-555-0101', 'info@techcorp.com', '123 Tech Street, Silicon Valley, CA 94000', 5),
('Green Energy Inc', 'Renewable Energy', 'Medium (50-200 employees)', 'https://greenenergy.com', '+1-555-0102', 'contact@greenenergy.com', '456 Solar Ave, Austin, TX 78701', 4),
('Urban Design Studio', 'Architecture', 'Small (10-50 employees)', 'https://urbandesign.com', '+1-555-0103', 'hello@urbandesign.com', '789 Design Blvd, New York, NY 10001', 3),
('MedTech Innovations', 'Healthcare', 'Medium (100-300 employees)', 'https://medtech.com', '+1-555-0104', 'info@medtech.com', '321 Health Way, Boston, MA 02101', 4),
('Food & Flavor Co', 'Food & Beverage', 'Small (20-50 employees)', 'https://foodflavor.com', '+1-555-0105', 'orders@foodflavor.com', '654 Taste Street, Portland, OR 97201', 2);

-- Insert sample contacts
INSERT INTO contacts (company_id, first_name, last_name, title, email, phone, department, is_primary) VALUES
((SELECT id FROM companies WHERE name = 'TechCorp Solutions'), 'John', 'Mitchell', 'CTO', 'john.mitchell@techcorp.com', '+1-555-0111', 'Technology', true),
((SELECT id FROM companies WHERE name = 'TechCorp Solutions'), 'Sarah', 'Chen', 'Product Manager', 'sarah.chen@techcorp.com', '+1-555-0112', 'Product', false),
((SELECT id FROM companies WHERE name = 'Green Energy Inc'), 'Michael', 'Rodriguez', 'CEO', 'michael@greenenergy.com', '+1-555-0121', 'Executive', true),
((SELECT id FROM companies WHERE name = 'Urban Design Studio'), 'Emily', 'Thompson', 'Lead Architect', 'emily@urbandesign.com', '+1-555-0131', 'Design', true),
((SELECT id FROM companies WHERE name = 'MedTech Innovations'), 'David', 'Park', 'VP of Sales', 'david.park@medtech.com', '+1-555-0141', 'Sales', true),
((SELECT id FROM companies WHERE name = 'Food & Flavor Co'), 'Lisa', 'Anderson', 'Operations Manager', 'lisa@foodflavor.com', '+1-555-0151', 'Operations', true);

-- Insert sample deals
INSERT INTO deals (company_id, contact_id, title, description, value, stage, probability, expected_close_date, status) VALUES
((SELECT id FROM companies WHERE name = 'TechCorp Solutions'), (SELECT id FROM contacts WHERE email = 'john.mitchell@techcorp.com'), 'Enterprise Software License', 'Annual license for enterprise management software', 150000.00, 'negotiation', 75, '2024-02-15', 'open'),
((SELECT id FROM companies WHERE name = 'Green Energy Inc'), (SELECT id FROM contacts WHERE email = 'michael@greenenergy.com'), 'Solar Panel Installation', 'Commercial solar panel system installation', 85000.00, 'proposal', 60, '2024-03-01', 'open'),
((SELECT id FROM companies WHERE name = 'Urban Design Studio'), (SELECT id FROM contacts WHERE email = 'emily@urbandesign.com'), 'Office Design Consultation', 'Complete office space redesign project', 45000.00, 'qualification', 40, '2024-02-28', 'open'),
((SELECT id FROM companies WHERE name = 'MedTech Innovations'), (SELECT id FROM contacts WHERE email = 'david.park@medtech.com'), 'Medical Equipment Purchase', 'Bulk purchase of medical monitoring devices', 220000.00, 'prospecting', 25, '2024-04-15', 'open'),
((SELECT id FROM companies WHERE name = 'Food & Flavor Co'), (SELECT id FROM contacts WHERE email = 'lisa@foodflavor.com'), 'Supply Chain Software', 'Implementation of supply chain management system', 35000.00, 'closed-won', 100, '2024-01-15', 'closed');

-- Insert sample inventory items
INSERT INTO inventory_items (sku, name, description, category, brand, cost_price, sell_price, current_stock, min_stock_level, max_stock_level, unit, location, supplier) VALUES
('LAPTOP-001', 'Business Laptop Pro', '15-inch professional laptop for business use', 'Electronics', 'TechBrand', 800.00, 1200.00, 25, 5, 50, 'pcs', 'Warehouse A-1', 'TechSupplier Inc'),
('DESK-001', 'Executive Office Desk', 'Premium wooden executive desk with drawers', 'Furniture', 'OfficeElite', 450.00, 750.00, 12, 3, 20, 'pcs', 'Warehouse B-2', 'Furniture Direct'),
('CHAIR-001', 'Ergonomic Office Chair', 'High-back ergonomic chair with lumbar support', 'Furniture', 'ComfortSeating', 180.00, 320.00, 35, 10, 60, 'pcs', 'Warehouse B-1', 'Seating Solutions'),
('MONITOR-001', '27-inch 4K Monitor', 'Ultra HD 4K monitor for professional use', 'Electronics', 'DisplayTech', 320.00, 520.00, 18, 8, 40, 'pcs', 'Warehouse A-2', 'Display World'),
('PRINTER-001', 'Multifunction Laser Printer', 'Color laser printer with scan and copy features', 'Electronics', 'PrintMaster', 280.00, 450.00, 8, 3, 15, 'pcs', 'Warehouse A-3', 'Office Equipment Co'),
('PAPER-001', 'Premium Copy Paper', 'High-quality A4 copy paper, 500 sheets per ream', 'Office Supplies', 'PaperPlus', 4.50, 8.00, 150, 50, 300, 'ream', 'Storage Room C', 'Paper Supply Co');

-- Insert sample stock movements
INSERT INTO stock_movements (item_id, movement_type, quantity, reason, reference, cost_per_unit) VALUES
((SELECT id FROM inventory_items WHERE sku = 'LAPTOP-001'), 'in', 30, 'Initial stock purchase', 'PO-2024-001', 800.00),
((SELECT id FROM inventory_items WHERE sku = 'LAPTOP-001'), 'out', 5, 'Sale to TechCorp Solutions', 'SO-2024-001', 800.00),
((SELECT id FROM inventory_items WHERE sku = 'DESK-001'), 'in', 15, 'Initial stock purchase', 'PO-2024-002', 450.00),
((SELECT id FROM inventory_items WHERE sku = 'DESK-001'), 'out', 3, 'Sale to Urban Design Studio', 'SO-2024-002', 450.00),
((SELECT id FROM inventory_items WHERE sku = 'CHAIR-001'), 'in', 40, 'Initial stock purchase', 'PO-2024-003', 180.00),
((SELECT id FROM inventory_items WHERE sku = 'CHAIR-001'), 'out', 5, 'Sale to various customers', 'SO-2024-003', 180.00);

-- Insert sample tasks
INSERT INTO tasks (title, description, company_id, contact_id, deal_id, due_date, priority, status) VALUES
('Follow up on Enterprise Software Deal', 'Call John Mitchell to discuss contract terms and next steps', (SELECT id FROM companies WHERE name = 'TechCorp Solutions'), (SELECT id FROM contacts WHERE email = 'john.mitchell@techcorp.com'), (SELECT id FROM deals WHERE title = 'Enterprise Software License'), '2024-01-25', 'high', 'pending'),
('Prepare Solar Panel Proposal', 'Create detailed proposal for Green Energy Inc solar installation project', (SELECT id FROM companies WHERE name = 'Green Energy Inc'), (SELECT id FROM contacts WHERE email = 'michael@greenenergy.com'), (SELECT id FROM deals WHERE title = 'Solar Panel Installation'), '2024-01-28', 'high', 'pending'),
('Design Consultation Meeting', 'Schedule and prepare for office design consultation with Urban Design Studio', (SELECT id FROM companies WHERE name = 'Urban Design Studio'), (SELECT id FROM contacts WHERE email = 'emily@urbandesign.com'), (SELECT id FROM deals WHERE title = 'Office Design Consultation'), '2024-01-30', 'medium', 'pending'),
('Restock Low Inventory Items', 'Order new stock for items below minimum threshold', NULL, NULL, NULL, '2024-01-26', 'medium', 'pending'),
('Update CRM Data', 'Clean and update contact information in CRM system', NULL, NULL, NULL, '2024-01-27', 'low', 'pending');

-- Insert sample communications
INSERT INTO communications (company_id, contact_id, deal_id, type, subject, content, direction) VALUES
((SELECT id FROM companies WHERE name = 'TechCorp Solutions'), (SELECT id FROM contacts WHERE email = 'john.mitchell@techcorp.com'), (SELECT id FROM deals WHERE title = 'Enterprise Software License'), 'email', 'Enterprise Software License Discussion', 'Initial discussion about enterprise software requirements and pricing options.', 'outbound'),
((SELECT id FROM companies WHERE name = 'Green Energy Inc'), (SELECT id FROM contacts WHERE email = 'michael@greenenergy.com'), (SELECT id FROM deals WHERE title = 'Solar Panel Installation'), 'call', 'Solar Installation Requirements Call', 'Phone call to discuss site requirements and installation timeline for solar panel project.', 'outbound'),
((SELECT id FROM companies WHERE name = 'Urban Design Studio'), (SELECT id FROM contacts WHERE email = 'emily@urbandesign.com'), (SELECT id FROM deals WHERE title = 'Office Design Consultation'), 'meeting', 'Office Design Consultation Meeting', 'In-person meeting to discuss office space requirements and design preferences.', 'inbound'),
((SELECT id FROM companies WHERE name = 'MedTech Innovations'), (SELECT id FROM contacts WHERE email = 'david.park@medtech.com'), (SELECT id FROM deals WHERE title = 'Medical Equipment Purchase'), 'email', 'Medical Equipment Inquiry', 'Initial inquiry about bulk purchase of medical monitoring devices.', 'inbound'),
((SELECT id FROM companies WHERE name = 'Food & Flavor Co'), (SELECT id FROM contacts WHERE email = 'lisa@foodflavor.com'), (SELECT id FROM deals WHERE title = 'Supply Chain Software'), 'call', 'Project Completion Call', 'Final call to confirm successful implementation of supply chain management system.', 'outbound');