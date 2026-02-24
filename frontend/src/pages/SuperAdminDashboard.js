import { useEffect, useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import axios from 'axios';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Users, ShoppingBag, DollarSign, Store, CheckCircle, Clock, Package } from 'lucide-react';

const BACKEND_URL = process.env.REACT_APP_BACKEND_URL;
const API = `${BACKEND_URL}/api`;

const SuperAdminDashboard = () => {
  const { user, logout } = useAuth();
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      const response = await axios.get(`${API}/dashboard/stats`);
      setStats(response.data);
    } catch (error) {
      console.error('Failed to fetch stats:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-lg">Loading dashboard...</div>
      </div>
    );
  }

  const statCards = [
    {
      title: 'Total Orders Today',
      value: stats?.total_orders_today || 0,
      icon: ShoppingBag,
      color: '#e92587'
    },
    {
      title: 'Revenue Today',
      value: `₹${stats?.total_revenue_today?.toLocaleString() || 0}`,
      icon: DollarSign,
      color: '#10b981'
    },
    {
      title: 'Pending Orders',
      value: stats?.pending_orders || 0,
      icon: Clock,
      color: '#f59e0b'
    },
    {
      title: 'Ready Orders',
      value: stats?.ready_orders || 0,
      icon: Package,
      color: '#3b82f6'
    },
    {
      title: 'Delivered Today',
      value: stats?.delivered_orders || 0,
      icon: CheckCircle,
      color: '#10b981'
    },
    {
      title: 'Total Outlets',
      value: stats?.total_outlets || 0,
      icon: Store,
      color: '#8b5cf6'
    },
    {
      title: 'Total Users',
      value: stats?.total_users || 0,
      icon: Users,
      color: '#6366f1'
    }
  ];

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b" style={{ borderColor: '#e92587' }}>
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex justify-between items-center">
            <div className="flex items-center space-x-4">
              <img src="/us-bakers-logo.jpg" alt="US Bakers" className="h-12" />
              <div>
                <h1 className="text-2xl font-bold" style={{ color: '#e92587' }}>
                  US Bakers - Bakery Management System
                </h1>
                <p className="text-sm text-gray-600">Super Admin Dashboard</p>
              </div>
            </div>
            <div className="flex items-center space-x-4">
              <div className="text-right">
                <p className="font-semibold">{user?.name}</p>
                <p className="text-sm text-gray-500">{user?.email}</p>
              </div>
              <Button
                variant="outline"
                onClick={logout}
                data-testid="logout-button"
              >
                Logout
              </Button>
            </div>
          </div>
        </div>
      </header>

      {/* Navigation */}
      <nav className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex space-x-8">
            <button
              className="px-3 py-4 text-sm font-medium border-b-2"
              style={{ borderColor: '#e92587', color: '#e92587' }}
              data-testid="nav-dashboard"
            >
              Dashboard
            </button>
            <button
              className="px-3 py-4 text-sm font-medium text-gray-500 hover:text-gray-700"
              data-testid="nav-outlets"
            >
              Outlets
            </button>
            <button
              className="px-3 py-4 text-sm font-medium text-gray-500 hover:text-gray-700"
              data-testid="nav-users"
            >
              Users
            </button>
            <button
              className="px-3 py-4 text-sm font-medium text-gray-500 hover:text-gray-700"
              data-testid="nav-zones"
            >
              Zones
            </button>
            <button
              className="px-3 py-4 text-sm font-medium text-gray-500 hover:text-gray-700"
              data-testid="nav-settings"
            >
              Settings
            </button>
          </div>
        </div>
      </nav>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          {statCards.map((stat, index) => {
            const Icon = stat.icon;
            return (
              <Card key={index} className="hover:shadow-lg transition-shadow">
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium text-gray-600">
                    {stat.title}
                  </CardTitle>
                  <Icon className="h-5 w-5" style={{ color: stat.color }} />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold" style={{ color: stat.color }}>
                    {stat.value}
                  </div>
                </CardContent>
              </Card>
            );
          })}
        </div>

        {/* Orders by Occasion */}
        {stats?.orders_by_occasion && Object.keys(stats.orders_by_occasion).length > 0 && (
          <Card className="mb-8">
            <CardHeader>
              <CardTitle>Orders by Occasion</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                {Object.entries(stats.orders_by_occasion).map(([occasion, count]) => (
                  <div key={occasion} className="text-center p-4 bg-gray-50 rounded-lg">
                    <div className="text-2xl font-bold" style={{ color: '#e92587' }}>
                      {count}
                    </div>
                    <div className="text-sm text-gray-600 mt-1">{occasion}</div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        )}

        {/* Quick Actions */}
        <Card>
          <CardHeader>
            <CardTitle>Quick Actions</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <Button
                className="w-full text-white"
                style={{ backgroundColor: '#e92587' }}
                data-testid="quick-action-create-outlet"
              >
                Create New Outlet
              </Button>
              <Button
                className="w-full text-white"
                style={{ backgroundColor: '#e92587' }}
                data-testid="quick-action-create-user"
              >
                Add New User
              </Button>
              <Button
                className="w-full text-white"
                style={{ backgroundColor: '#e92587' }}
                data-testid="quick-action-view-reports"
              >
                View Reports
              </Button>
            </div>
          </CardContent>
        </Card>
      </main>
    </div>
  );
};

export default SuperAdminDashboard;
