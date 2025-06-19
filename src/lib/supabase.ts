import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || '';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || '';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Database types
export interface Company {
  id: string;
  name: string;
  industry: string;
  size: string;
  website: string;
  phone: string;
  email: string;
  address: string;
  notes: string;
  relationship_strength: number;
  created_at: string;
  updated_at: string;
}

export interface Contact {
  id: string;
  company_id: string;
  first_name: string;
  last_name: string;
  title: string;
  email: string;
  phone: string;
  department: string;
  notes: string;
  is_primary: boolean;
  created_at: string;
  updated_at: string;
}

export interface Deal {
  id: string;
  company_id: string;
  contact_id: string;
  title: string;
  description: string;
  value: number;
  stage: string;
  probability: number;
  expected_close_date: string;
  actual_close_date: string;
  status: string;
  notes: string;
  created_at: string;
  updated_at: string;
}

export interface InventoryItem {
  id: string;
  sku: string;
  name: string;
  description: string;
  category: string;
  brand: string;
  cost_price: number;
  sell_price: number;
  current_stock: number;
  min_stock_level: number;
  max_stock_level: number;
  unit: string;
  location: string;
  supplier: string;
  created_at: string;
  updated_at: string;
}

export interface StockMovement {
  id: string;
  item_id: string;
  movement_type: 'in' | 'out' | 'adjustment';
  quantity: number;
  reason: string;
  reference: string;
  cost_per_unit: number;
  created_at: string;
}

export interface Task {
  id: string;
  title: string;
  description: string;
  assigned_to: string;
  company_id: string;
  contact_id: string;
  deal_id: string;
  due_date: string;
  priority: 'low' | 'medium' | 'high';
  status: 'pending' | 'completed' | 'cancelled';
  completed_at: string;
  created_at: string;
  updated_at: string;
}

export interface Communication {
  id: string;
  company_id: string;
  contact_id: string;
  deal_id: string;
  type: 'email' | 'call' | 'meeting' | 'note';
  subject: string;
  content: string;
  direction: 'inbound' | 'outbound';
  created_at: string;
}