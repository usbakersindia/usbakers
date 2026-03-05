import { useEffect, useState } from 'react';
import axios from 'axios';
import LayoutWithSidebar from '../components/LayoutWithSidebar';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Truck, MapPin, CheckCircle, Clock } from 'lucide-react';

const BACKEND_URL = process.env.REACT_APP_BACKEND_URL;
const API = `${BACKEND_URL}/api`;

const DeliveryDashboard = () => {
  const [orders, setOrders] = useState([]);
  const [summary, setSummary] = useState(null);
  const [selectedOrder, setSelectedOrder] = useState(null);
  const [otpDialogOpen, setOtpDialogOpen] = useState(false);
  const [otp, setOtp] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetchOrders();
    fetchSummary();
  }, []);

  const fetchOrders = async () => {
    try {
      const response = await axios.get(`${API}/delivery/orders`);
      setOrders(response.data);
    } catch (error) {
      console.error('Failed to fetch orders:', error);
    }
  };

  const fetchSummary = async () => {
    try {
      const response = await axios.get(`${API}/delivery/summary`);
      setSummary(response.data);
    } catch (error) {
      console.error('Failed to fetch summary:', error);
    }
  };

  const updateOrderStatus = async (orderId, newStatus) => {
    setLoading(true);
    try {
      await axios.patch(`${API}/orders/${orderId}/status`, {
        status: newStatus
      });
      fetchOrders();
      fetchSummary();
      alert(`Order status updated to ${newStatus}`);
    } catch (error) {
      console.error('Failed to update status:', error);
      alert('Failed to update status');
    } finally {
      setLoading(false);
    }
  };

  const openOtpDialog = (order) => {
    setSelectedOrder(order);
    setOtp('');
    setOtpDialogOpen(true);
  };

  const verifyAndDeliver = async () => {
    if (otp.length !== 6) {
      alert('OTP must be 6 digits');
      return;
    }

    setLoading(true);
    try {
      await axios.post(`${API}/delivery/verify-otp`, {
        order_id: selectedOrder.id,
        otp: otp
      });
      alert('Order delivered successfully!');
      setOtpDialogOpen(false);
      fetchOrders();
      fetchSummary();
    } catch (error) {
      alert(error.response?.data?.detail || 'Invalid OTP');
    } finally {
      setLoading(false);
    }
  };

  const getStatusColor = (status) => {
    const colors = {
      ready: 'bg-blue-100 text-blue-800',
      picked_up: 'bg-purple-100 text-purple-800',
      reached: 'bg-orange-100 text-orange-800',
      delivered: 'bg-green-500 text-white'
    };
    return colors[status] || 'bg-gray-100 text-gray-800';
  };

  return (
    <LayoutWithSidebar>
      <div className="space-y-6">
        <div className="flex justify-between items-center">
          <h1 className="text-2xl font-bold">Delivery Dashboard</h1>
          <Button onClick={fetchOrders} variant="outline">
            Refresh
          </Button>
        </div>

        {/* Summary Cards */}
        {summary && (
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <Card>
              <CardHeader className="pb-3">
                <CardTitle className="text-sm font-medium">Ready for Pickup</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-blue-600">{summary.ready}</div>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="pb-3">
                <CardTitle className="text-sm font-medium">Picked Up</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-purple-600">{summary.picked_up}</div>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="pb-3">
                <CardTitle className="text-sm font-medium">Reached</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-orange-600">{summary.reached}</div>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="pb-3">
                <CardTitle className="text-sm font-medium">Delivered Today</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-green-600">{summary.delivered_today}</div>
              </CardContent>
            </Card>
          </div>
        )}

        {/* Orders Table */}
        <Card>
          <CardHeader>
            <CardTitle>Delivery Orders ({orders.length})</CardTitle>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Order #</TableHead>
                  <TableHead>Customer</TableHead>
                  <TableHead>Delivery Address</TableHead>
                  <TableHead>Delivery Date/Time</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {orders.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={6} className="text-center text-gray-500">
                      No delivery orders found
                    </TableCell>
                  </TableRow>
                ) : (
                  orders.map(order => (
                    <TableRow key={order.id}>
                      <TableCell className="font-medium">{order.order_number}</TableCell>
                      <TableCell>
                        <div className="text-sm">
                          <div>{order.customer_info?.name}</div>
                          <div className="text-gray-500">{order.customer_info?.phone}</div>
                        </div>
                      </TableCell>
                      <TableCell className="max-w-xs">
                        <div className="text-sm">
                          {order.delivery_address}
                          {order.delivery_city && `, ${order.delivery_city}`}
                        </div>
                      </TableCell>
                      <TableCell>
                        <div className="text-sm">
                          <div>{order.delivery_date}</div>
                          <div className="text-gray-500">{order.delivery_time}</div>
                        </div>
                      </TableCell>
                      <TableCell>
                        <Badge className={getStatusColor(order.status)}>
                          {order.status}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        <div className="flex gap-2">
                          {order.status === 'ready' && (
                            <Button
                              size="sm"
                              onClick={() => updateOrderStatus(order.id, 'picked_up')}
                              disabled={loading}
                            >
                              <Truck className="h-4 w-4 mr-1" />
                              Pick Up
                            </Button>
                          )}
                          {order.status === 'picked_up' && (
                            <Button
                              size="sm"
                              onClick={() => updateOrderStatus(order.id, 'reached')}
                              disabled={loading}
                            >
                              <MapPin className="h-4 w-4 mr-1" />
                              Reached
                            </Button>
                          )}
                          {order.status === 'reached' && (
                            <Button
                              size="sm"
                              onClick={() => openOtpDialog(order)}
                              disabled={loading}
                              className="bg-green-600 hover:bg-green-700"
                            >
                              <CheckCircle className="h-4 w-4 mr-1" />
                              Deliver (OTP)
                            </Button>
                          )}
                          {order.status === 'delivered' && (
                            <Badge className="bg-green-500 text-white">
                              <CheckCircle className="h-3 w-3 mr-1" />
                              Delivered
                            </Badge>
                          )}
                        </div>
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </CardContent>
        </Card>

        {/* OTP Verification Dialog */}
        {selectedOrder && (
          <Dialog open={otpDialogOpen} onOpenChange={setOtpDialogOpen}>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Verify OTP - Order #{selectedOrder.order_number}</DialogTitle>
                <DialogDescription>
                  Ask customer for 6-digit OTP to confirm delivery
                </DialogDescription>
              </DialogHeader>
              <div className="space-y-4 py-4">
                <div>
                  <Label>Customer: {selectedOrder.customer_info?.name}</Label>
                  <p className="text-sm text-gray-500">{selectedOrder.customer_info?.phone}</p>
                </div>
                <div>
                  <Label htmlFor="otp">Enter OTP</Label>
                  <Input
                    id="otp"
                    type="text"
                    maxLength={6}
                    value={otp}
                    onChange={(e) => setOtp(e.target.value.replace(/\D/g, ''))}
                    placeholder="Enter 6-digit OTP"
                    className="text-center text-2xl tracking-widest"
                  />
                </div>
                <Button 
                  onClick={verifyAndDeliver} 
                  className="w-full bg-green-600 hover:bg-green-700"
                  disabled={otp.length !== 6 || loading}
                >
                  {loading ? 'Verifying...' : 'Verify & Mark Delivered'}
                </Button>
              </div>
            </DialogContent>
          </Dialog>
        )}
      </div>
    </LayoutWithSidebar>
  );
};

export default DeliveryDashboard;