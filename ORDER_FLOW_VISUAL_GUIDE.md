# Order Flow - Visual Guide

## 📊 Complete Order Lifecycle

```
┌─────────────────────────────────────────────────────────────────┐
│                        NEW ORDER FORM                            │
│  • Auto-fetch outlet from logged-in user                        │
│  • Order Taken By dropdown (sales persons)                      │
│  • Delivery: Yes/No                                             │
│    - If Yes: Show zones for that outlet                         │
│    - Total = Cake Amount + Delivery Charge                      │
│  • Two buttons: [Punch Order] [Hold Order]                      │
└─────────────────────────────────────────────────────────────────┘
                        │                    │
                        │                    │
            ┌───────────┴──────────┐    ┌───┴──────────┐
            │  PUNCH ORDER         │    │  HOLD ORDER  │
            │  (All fields         │    │  (Optional   │
            │   mandatory)         │    │   fields)    │
            └───────────┬──────────┘    └───┬──────────┘
                        │                    │
                        ▼                    ▼
            ┌─────────────────────┐   ┌──────────────────┐
            │  PENDING ORDERS     │   │   HOLD ORDERS    │
            │  lifecycle_status:  │   │   lifecycle_status│
            │  "pending_payment"  │   │   "hold"         │
            │                     │   │                  │
            │  Waiting for 20%+   │   │  Can release by  │
            │  payment from       │   │  completing info │
            │  PetPooja           │   │                  │
            └─────────┬───────────┘   └────────┬─────────┘
                      │                         │
                      │  Payment ≥ 20%          │  [Release]
                      │  (PetPooja auto-sync)   │  Button clicked
                      │                         │
                      ▼                         ▼
                                    ┌────────────────────────┐
                                    │  Check if paid ≥ 20%?  │
                                    └────┬───────────────┬───┘
                                         │               │
                                    Yes  │               │  No
                                         │               │
                      ┌──────────────────┘               └────────────┐
                      ▼                                               ▼
            ┌─────────────────────┐                      ┌────────────────────┐
            │  MANAGE ORDERS      │                      │  Back to           │
            │  lifecycle_status:  │                      │  PENDING ORDERS    │
            │  "active"           │                      └────────────────────┘
            │                     │
            │  • Confirm          │
            │  • Mark Ready       │
            │  • Assign Delivery  │
            │  • Track            │
            └─────────┬───────────┘
                      │
                      │  Status changes
                      ▼
            ┌─────────────────────┐
            │  COMPLETED/         │
            │  DELIVERED          │
            │  lifecycle_status:  │
            │  "completed"        │
            └─────────────────────┘
```

---

## 🔄 Payment Flow (PetPooja Integration)

```
┌────────────────────────────────────────────────────────────────┐
│                    PETPOOJA POS SYSTEM                          │
│  • Customer pays (cash/card/UPI)                               │
│  • Bill created with order_number in comment                   │
└────────────────┬───────────────────────────────────────────────┘
                 │
                 │  Webhook POST
                 │  /api/petpooja/payment-webhook
                 ▼
┌────────────────────────────────────────────────────────────────┐
│              US BAKERS BACKEND                                  │
│  1. Find order by order_number                                 │
│  2. Record payment in payments collection                      │
│  3. Update order.paid_amount                                   │
│  4. Calculate payment percentage                               │
│  5. Get minimum_payment_percentage from settings (default 20%) │
│  6. IF percentage ≥ minimum:                                   │
│     • Move order to "active" (Manage Orders)                   │
│     • Set status = "confirmed"                                 │
│  7. ELSE:                                                       │
│     • Keep in "pending_payment" (Pending Orders)               │
└────────────────────────────────────────────────────────────────┘
```

---

## 👥 Sales Person Management

```
┌────────────────────────────────────────────────────────────────┐
│                   SUPER ADMIN                                   │
│  • Create sales persons per outlet                             │
│  • Name, Phone, Outlet                                         │
│  • Deactivate sales persons                                    │
└────────────────┬───────────────────────────────────────────────┘
                 │
                 │  Saved to database
                 ▼
┌────────────────────────────────────────────────────────────────┐
│              SALES_PERSONS COLLECTION                           │
│  { id, name, phone, outlet_id, is_active }                     │
└────────────────┬───────────────────────────────────────────────┘
                 │
                 │  Used in dropdown
                 ▼
┌────────────────────────────────────────────────────────────────┐
│              NEW ORDER FORM                                     │
│  "Order Taken By" dropdown:                                    │
│  • Shows all active sales persons for user's outlet            │
│  • Saved in order.order_taken_by                               │
│  • Used for incentive calculation                              │
└────────────────────────────────────────────────────────────────┘
```

---

## ⚙️ System Settings

```
┌────────────────────────────────────────────────────────────────┐
│                   SUPER ADMIN SETTINGS                          │
│                                                                 │
│  Minimum Payment Percentage for Order Confirmation             │
│  ┌────────────────────┐                                        │
│  │       20%          │  [Update]                              │
│  └────────────────────┘                                        │
│                                                                 │
│  Default: 20%                                                  │
│  Range: 0-100%                                                 │
│  Use Case: Set threshold for auto-moving orders from           │
│            pending to manage after PetPooja payment            │
└────────────────────────────────────────────────────────────────┘
```

---

## 📱 Frontend Components Map

```
Sidebar
├── Dashboard
├── New Order ──────────► NewOrder.js (UPDATED)
│                         • Auto-fetch outlet
│                         • Sales person dropdown
│                         • Conditional zones
│                         • Two buttons
│
├── Pending Orders ─────► PendingOrders.js (NEW)
│                         • Show pending orders
│                         • Payment status
│                         • Auto-refresh
│
├── Hold Orders ────────► HoldOrders.js (UPDATED)
│                         • Release button
│                         • Complete fields modal
│
├── Manage Orders ──────► ManageOrders.js (MINOR UPDATE)
│                         • Show only active
│                         • Payment badge
│
├── Sales Persons ──────► SalesPersonManagement.js (NEW)
│   (Super Admin)         • CRUD operations
│                         • Outlet filter
│
└── Settings
    ├── System Settings ─► SystemSettings.js (NEW)
    │   (Super Admin)      • Payment threshold
    │
    └── PetPooja ──────────► PetPoojaSettings.js (EXISTING)
                            • Webhook URLs
```

---

## 🎯 Key Features Summary

### 1. **Sales Persons (Not Login Users)**
- Managed by Super Admin
- Just names for dropdown
- Linked to specific outlet
- Used in "Order Taken By" field

### 2. **Configurable Payment Threshold**
- Super Admin can change from default 20%
- Used by PetPooja webhook
- Determines when pending → active

### 3. **Two Order Types**

**PUNCH ORDER:**
- All fields mandatory (customer, cake, delivery if needed)
- Goes to Pending Orders
- Waits for PetPooja payment
- Auto-moves to Manage Orders when threshold met

**HOLD ORDER:**
- All fields optional
- Goes to Hold Orders
- Can be released later by completing info
- Release logic:
  - If paid ≥ threshold → Manage Orders
  - If not → Pending Orders

### 4. **Automatic Order Movement**
When PetPooja payment webhook received:
1. Find order by order_number
2. Calculate payment percentage
3. If ≥ threshold AND lifecycle_status = "pending_payment":
   - Move to "active" (Manage Orders)
   - Set status = "confirmed"

---

## 🔐 Permissions

**Super Admin:**
- ✅ Manage sales persons
- ✅ Update payment threshold
- ✅ View all outlets' orders

**Outlet Admin/Staff:**
- ✅ Create orders (auto-filtered by their outlet)
- ✅ See only their outlet's sales persons
- ✅ See only their outlet's zones
- ✅ Release hold orders
- ❌ Cannot change system settings

---

## 📝 Implementation Priority

**High Priority (Critical Path):**
1. ✅ Sales persons endpoints (DONE)
2. ✅ System settings endpoints (DONE)
3. 🔄 Update order creation (NEXT)
4. 🔄 PetPooja payment webhook update (NEXT)
5. 🔄 Pending orders endpoint (NEXT)

**Medium Priority (User Experience):**
6. 🔄 NewOrder.js updates
7. 🔄 PendingOrders.js creation
8. 🔄 HoldOrders.js release feature
9. 🔄 SalesPersonManagement.js

**Low Priority (Nice to Have):**
10. 🔄 SystemSettings.js
11. 🔄 Payment percentage badges

---

## ❓ Questions for Review

1. **Is the order flow correct?**
   - Punch → Pending → (20% paid) → Manage
   - Hold → Hold → (release) → Pending or Manage

2. **Should released hold orders with 0% payment still go to Pending?**
   - Current logic: Yes, if paid < threshold
   - Alternative: Require some payment to release?

3. **Sales person mandatory for all orders?**
   - Current: Yes, field is required
   - Alternative: Make optional?

4. **Should Pending Orders page be accessible to all roles or just admins?**
   - Current: All users with permission
   - Reasoning: Outlet staff needs to see pending orders

5. **Auto-refresh interval for Pending Orders page?**
   - Suggested: 30 seconds
   - Too frequent? Too slow?

---

**Ready to implement? Any changes needed?** 🚀
