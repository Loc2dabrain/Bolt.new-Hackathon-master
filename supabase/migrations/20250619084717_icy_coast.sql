/*
  # Business Management System Database Schema

  This migration creates all necessary tables for the BizManager application.
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

-- Insert sample data
INSERT INTO companies (name, industry, size, website, phone, email, address, relationship_strength) VALUES
('TechCorp Solutions', 'Technology', 'Large (500+ employees)', 'https://techcorp.com', '+1-555-0101', 'info@techcorp.com', '123 Tech Street, Silicon Valley, CA 94000', 5),
('Green Energy Inc', 'Renewable Energy', 'Medium (50-200 employees)', 'https://greenenergy.com', '+1-555-0102', 'contact@greenenergy.com', '456 Solar Ave, Austin, TX 78701', 4),
('Urban Design Studio', 'Architecture', 'Small (10-50 employees)', 'https://urbandesign.com', '+1-555-0103', 'hello@urbandesign.com', '789 Design Blvd, New York, NY 10001', 3),
('MedTech Innovations', 'Healthcare', 'Medium (100-300 employees)', 'https://medtech.com', '+1-555-0104', 'info@medtech.com', '321 Health Way, Boston, MA 02101', 4),
('Food & Flavor Co', 'Food & Beverage', 'Small (20-50 employees)', 'https://foodflavor.com', '+1-555-0105', 'orders@foodflavor.com', '654 Taste Street, Portland, OR 97201', 2);