# US Bakers CRM - Feature Implementation Plan

## 🎯 Features to Implement

### 1. PetPooja Payment Auto-Sync ⚡
- **Status**: To Implement
- **Details**:
  - Remove manual payment recording for non-super-admin
  - Auto-sync from PetPooja every 10 minutes
  - Webhook support for real-time sync
  - Super Admin can still manually add/edit payments

### 2. Hide Settings Menu 🔒
- **Status**: Simple
- **Details**:
  - Settings menu only visible to Super Admin
  - Non-admin users don't see: User Management, Outlets, Zones, Settings

### 3. Internal Notifications (Zomato-style) 🔔
- **Status**: To Implement
- **Details**:
  - In-app notification bell icon with count badge
  - Browser push notifications
  - Sound alerts for new notifications
  - **Notification triggers**:
    - New order created → Alert Factory
    - Order marked ready by Factory → Alert Outlet Admin
    - Order ready for delivery → Alert Delivery Person
    - Payment received → Alert Outlet
    - Order cancelled → Alert all relevant parties
    - Order edited → Alert relevant parties

### 4. Excel Export for All Reports 📊
- **Status**: To Implement
- **Details**:
  - Payment reports → Excel
  - Delivery reports → Excel
  - Order reports → Excel
  - Daily/Weekly/Monthly summaries → Excel
  - Custom date range exports

### 5. Activity Logs for Super Admin 📝
- **Status**: To Implement
- **Details**:
  - Log all user actions:
    - Login/Logout
    - Order creation/editing/deletion
    - Payment records
    - Status changes
    - User management actions
    - Settings changes
  - Searchable and filterable
  - Export logs to Excel

### 6. Enhanced Outlet Admin Role 👤
- **Status**: Enhance Existing
- **Details**:
  - Can do everything for their outlet
  - Generate reports for their outlet only
  - Cannot see Factory dashboard
  - Cannot manage users
  - Full order management for their outlet

### 7. Order PDF Generation 📄
- **Status**: To Implement
- **Details**:
  - **Who**: Super Admin + Factory
  - **Format**: One A4 per order
  - **Content**:
    - Order number, date, customer details
    - Cake specifications (flavour, size, weight)
    - All uploaded photos (cake design, reference images)
    - Delivery information
    - Special instructions
    - Payment details
    - Barcode/QR for order tracking
  - **Batch generation**: Select multiple orders, get combined PDF
  - **Filters**: By date, outlet, status

### 8. Comprehensive Filters Everywhere 🔍
- **Status**: To Implement
- **Details**:
  - **Order filters**:
    - Date range (from-to)
    - Outlet
    - Status (New, In Progress, Ready, Delivered, Cancelled)
    - Payment status (Paid, Pending, Partial)
    - Delivery date
    - Customer name
    - Order amount range
  - **Payment filters**:
    - Date range
    - Outlet
    - Payment method
    - Amount range
  - **Delivery filters**:
    - Date range
    - Delivery person
    - Status
    - Zone
  - **Report filters**:
    - Date range (Today, Yesterday, Last 7 days, Last 30 days, Custom)
    - Outlet
    - Category (Orders, Payments, Deliveries)

---

## 📋 Implementation Order

### Week 1: Backend Foundation
1. ✅ Database schemas for notifications and logs
2. ✅ Notification API endpoints
3. ✅ Activity logging system
4. ✅ Enhanced filtering on existing APIs
5. ✅ Excel export utilities

### Week 2: PDF & PetPooja
1. ✅ PDF generation service
2. ✅ PetPooja integration enhancement
3. ✅ Payment sync scheduler
4. ✅ Webhook handlers

### Week 3: Frontend Components
1. ✅ Notification bell component
2. ✅ Activity logs page
3. ✅ Excel export buttons
4. ✅ PDF generation UI
5. ✅ Advanced filter components

### Week 4: Real-time & Polish
1. ✅ WebSocket for notifications
2. ✅ Browser push notifications
3. ✅ Sound alerts
4. ✅ Testing all flows
5. ✅ UI/UX polish

---

## 🗄️ New Database Collections

### notifications
```javascript
{
  id: "notif_uuid",
  user_id: "user_id",
  type: "new_order" | "order_ready" | "ready_for_delivery" | "payment_received",
  title: "New Order #ORD001",
  message: "New order created for Railway Road outlet",
  order_id: "order_id",
  read: false,
  created_at: "2024-03-05T10:00:00Z"
}
```

### activity_logs
```javascript
{
  id: "log_uuid",
  user_id: "user_id",
  user_email: "user@example.com",
  action: "order_created" | "order_edited" | "payment_recorded" | "login",
  entity_type: "order" | "payment" | "user",
  entity_id: "entity_id",
  changes: {}, // what changed
  ip_address: "192.168.1.1",
  user_agent: "Chrome/120.0.0.0",
  timestamp: "2024-03-05T10:00:00Z"
}
```

---

## 🔌 New API Endpoints

### Notifications
- `GET /api/notifications` - Get user notifications
- `POST /api/notifications/{id}/read` - Mark as read
- `POST /api/notifications/read-all` - Mark all as read
- `GET /api/notifications/unread-count` - Get unread count

### Activity Logs
- `GET /api/logs` - Get all logs (Super Admin only)
- `GET /api/logs/export` - Export logs to Excel

### Excel Export
- `GET /api/reports/payment/export` - Export payment report
- `GET /api/reports/delivery/export` - Export delivery report
- `GET /api/reports/orders/export` - Export orders report

### PDF Generation
- `POST /api/orders/generate-pdf` - Generate PDF for selected orders
- `GET /api/orders/{id}/pdf` - Get PDF for single order

---

## 🎨 UI Components to Create

1. **NotificationBell.jsx** - Bell icon with badge
2. **NotificationPanel.jsx** - Dropdown panel with notifications
3. **ActivityLogs.jsx** - Activity logs page
4. **ExportButton.jsx** - Reusable export button
5. **PDFGenerator.jsx** - PDF generation modal
6. **AdvancedFilters.jsx** - Reusable filter component
7. **DateRangePicker.jsx** - Date range selector

---

## 🔔 Notification Flow Example

```
1. User creates new order
   ↓
2. Backend saves order
   ↓
3. Backend creates notification for Factory users
   ↓
4. WebSocket broadcasts notification
   ↓
5. Factory user's browser shows:
   - Bell icon badge updates (1 new)
   - Browser push notification
   - Sound alert plays
   ↓
6. Factory user clicks bell
   ↓
7. Sees: "New Order #ORD001 for Railway Road"
   ↓
8. Clicks notification → Navigates to order details
```

---

## 🧪 Testing Checklist

- [ ] All notification types working
- [ ] Excel exports downloading correctly
- [ ] PDF generation with all details and images
- [ ] Filters working on all pages
- [ ] Activity logs capturing all actions
- [ ] PetPooja sync working
- [ ] Settings hidden for non-super-admin
- [ ] Outlet admin can only see their outlet data
- [ ] Real-time notifications working
- [ ] Sound alerts playing

---

## 📦 Dependencies to Add

**Backend:**
- `openpyxl` or `xlsxwriter` - Excel generation
- `reportlab` or `weasyprint` - PDF generation
- `Pillow` - Image handling for PDFs
- `python-socketio` - WebSocket support

**Frontend:**
- `xlsx` or `exceljs` - Excel download (if client-side)
- `react-to-print` or `jspdf` - PDF preview
- `socket.io-client` - WebSocket client
- `react-notifications-component` - Notification UI
- `react-datepicker` - Date range picker

---

## 🚀 Deployment Notes

1. Setup WebSocket server for real-time notifications
2. Configure PetPooja webhook URL in their dashboard
3. Setup cron job for payment sync (every 10 mins)
4. Ensure PDF generation has access to fonts and images
5. Configure push notification service worker
6. Test notification delivery across all roles
7. Setup activity log retention policy (keep 90 days)

---

**Status**: Ready to implement
**Estimated Time**: 2-3 weeks for complete implementation
**Priority Order**: Notifications → Filters → Excel → PDF → Logs → PetPooja
