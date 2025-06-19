/*
  # Sample Data for Business Management System

  This migration adds sample data to demonstrate the system functionality.
*/

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