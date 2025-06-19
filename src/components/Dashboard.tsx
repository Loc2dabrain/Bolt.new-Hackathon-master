import React, { useEffect, useState } from 'react';
import { 
  TrendingUp, 
  Users, 
  Package, 
  DollarSign, 
  AlertTriangle,
  CheckCircle,
  Calendar,
  Building2,
  MessageSquare
} from 'lucide-react';
import { supabase } from '../lib/supabase';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts';

interface DashboardStats {
  totalCompanies: number;
  totalContacts: number;
  totalDeals: number;
  totalDealValue: number;
  openDeals: number;
  lowStockItems: number;
  pendingTasks: number;
  overdueTasks: number;
}

const COLORS = ['#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6'];

export default function Dashboard() {
  const [stats, setStats] = useState<DashboardStats>({
    totalCompanies: 0,
    totalContacts: 0,
    totalDeals: 0,
    totalDealValue: 0,
    openDeals: 0,
    lowStockItems: 0,
    pendingTasks: 0,
    overdueTasks: 0,
  });
  const [dealsByStage, setDealsByStage] = useState<any[]>([]);
  const [recentActivities, setRecentActivities] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      // Fetch basic stats
      const [
        companiesResult,
        contactsResult,
        dealsResult,
        inventoryResult,
        tasksResult,
        communicationsResult
      ] = await Promise.all([
        supabase.from('companies').select('*'),
        supabase.from('contacts').select('*'),
        supabase.from('deals').select('*'),
        supabase.from('inventory_items').select('*'),
        supabase.from('tasks').select('*'),
        supabase.from('communications').select('*, companies(name), contacts(first_name, last_name)').order('created_at', { ascending: false }).limit(5)
      ]);

      const companies = companiesResult.data || [];
      const contacts = contactsResult.data || [];
      const deals = dealsResult.data || [];
      const inventory = inventoryResult.data || [];
      const tasks = tasksResult.data || [];

      // Calculate stats
      const totalDealValue = deals.reduce((sum, deal) => sum + (deal.value || 0), 0);
      const openDeals = deals.filter(deal => deal.status === 'open').length;
      const lowStockItems = inventory.filter(item => item.current_stock <= item.min_stock_level).length;
      const pendingTasks = tasks.filter(task => task.status === 'pending').length;
      const overdueTasks = tasks.filter(task => 
        task.status === 'pending' && 
        task.due_date && 
        new Date(task.due_date) < new Date()
      ).length;

      setStats({
        totalCompanies: companies.length,
        totalContacts: contacts.length,
        totalDeals: deals.length,
        totalDealValue,
        openDeals,
        lowStockItems,
        pendingTasks,
        overdueTasks,
      });

      // Deals by stage
      const stageGroups = deals.reduce((acc, deal) => {
        acc[deal.stage] = (acc[deal.stage] || 0) + 1;
        return acc;
      }, {} as Record<string, number>);

      const stageData = Object.entries(stageGroups).map(([stage, count]) => ({
        name: stage.charAt(0).toUpperCase() + stage.slice(1),
        value: count
      }));

      setDealsByStage(stageData);

      // Recent activities from communications
      const activities = (communicationsResult.data || []).map(comm => ({
        id: comm.id,
        type: comm.type,
        subject: comm.subject,
        company: comm.companies?.name || 'Unknown Company',
        contact: comm.contacts ? `${comm.contacts.first_name} ${comm.contacts.last_name}` : '',
        created_at: comm.created_at
      }));

      setRecentActivities(activities);

    } catch (error) {
      console.error('Error fetching dashboard data:', error);
    } finally {
      setLoading(false);
    }
  };

  const statCards = [
    {
      title: 'Total Companies',
      value: stats.totalCompanies,
      icon: Building2,
      color: 'bg-blue-500',
      change: '+12%'
    },
    {
      title: 'Total Contacts',
      value: stats.totalContacts,
      icon: Users,
      color: 'bg-green-500',
      change: '+8%'
    },
    {
      title: 'Open Deals',
      value: stats.openDeals,
      icon: DollarSign,
      color: 'bg-purple-500',
      change: '+15%'
    },
    {
      title: 'Deal Value',
      value: `$${stats.totalDealValue.toLocaleString()}`,
      icon: TrendingUp,
      color: 'bg-orange-500',
      change: '+22%'
    },
  ];

  const alertCards = [
    {
      title: 'Low Stock Items',
      value: stats.lowStockItems,
      icon: AlertTriangle,
      color: 'bg-red-500',
      description: 'Items below minimum stock level'
    },
    {
      title: 'Pending Tasks',
      value: stats.pendingTasks,
      icon: CheckCircle,
      color: 'bg-blue-500',
      description: 'Tasks requiring attention'
    },
    {
      title: 'Overdue Tasks',
      value: stats.overdueTasks,
      icon: Calendar,
      color: 'bg-red-500',
      description: 'Tasks past due date'
    },
  ];

  if (loading) {
    return (
      <div className="space-y-6 animate-pulse">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {[...Array(4)].map((_, i) => (
            <div key={i} className="bg-white p-6 rounded-xl shadow-sm border h-32"></div>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-600 mt-2">Welcome to your business management overview</p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {statCards.map((card, index) => {
          const Icon = card.icon;
          return (
            <div key={index} className="bg-white p-6 rounded-xl shadow-sm border hover:shadow-md transition-shadow">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">{card.title}</p>
                  <p className="text-2xl font-bold text-gray-900 mt-1">{card.value}</p>
                  <p className="text-sm text-green-600 mt-1">{card.change} from last month</p>
                </div>
                <div className={`p-3 rounded-lg ${card.color}`}>
                  <Icon className="w-6 h-6 text-white" />
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Alert Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {alertCards.map((card, index) => {
          const Icon = card.icon;
          return (
            <div key={index} className="bg-white p-6 rounded-xl shadow-sm border hover:shadow-md transition-shadow">
              <div className="flex items-center space-x-4">
                <div className={`p-3 rounded-lg ${card.color}`}>
                  <Icon className="w-6 h-6 text-white" />
                </div>
                <div>
                  <p className="text-2xl font-bold text-gray-900">{card.value}</p>
                  <p className="text-sm font-medium text-gray-600">{card.title}</p>
                  <p className="text-xs text-gray-500 mt-1">{card.description}</p>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Deals by Stage */}
        <div className="bg-white p-6 rounded-xl shadow-sm border">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Deals by Stage</h3>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={dealsByStage}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {dealsByStage.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Recent Activities */}
        <div className="bg-white p-6 rounded-xl shadow-sm border">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Recent Activities</h3>
          <div className="space-y-4">
            {recentActivities.map((activity) => (
              <div key={activity.id} className="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
                <div className="flex-shrink-0">
                  <MessageSquare className="w-5 h-5 text-blue-500" />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-gray-900 truncate">
                    {activity.subject}
                  </p>
                  <p className="text-sm text-gray-500">
                    {activity.company} {activity.contact && `• ${activity.contact}`}
                  </p>
                  <p className="text-xs text-gray-400">
                    {new Date(activity.created_at).toLocaleDateString()}
                  </p>
                </div>
                <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                  activity.type === 'email' ? 'bg-blue-100 text-blue-800' :
                  activity.type === 'call' ? 'bg-green-100 text-green-800' :
                  activity.type === 'meeting' ? 'bg-purple-100 text-purple-800' :
                  'bg-gray-100 text-gray-800'
                }`}>
                  {activity.type}
                </span>
              </div>
            ))}
            {recentActivities.length === 0 && (
              <p className="text-gray-500 text-center py-4">No recent activities</p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}