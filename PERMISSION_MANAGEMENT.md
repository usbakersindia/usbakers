# US Bakers CRM - Granular Permission Management System

## 🎯 Overview

The system now includes a comprehensive granular permission management system that allows Super Admins to configure default permissions for each role. When creating new users, permissions are automatically applied based on their role.

---

## ✨ Features

### 1. Permission Presets for Roles
- Super Admin can configure default permissions for each role
- Permissions are organized into categories:
  - **Orders**: Create, view, edit, delete orders, mark as ready
  - **Order Fields**: Edit specific order fields (customer info, flavour, size, dates, etc.)
  - **Payments**: Record payments, view payments, process refunds  
  - **Management**: Manage outlets, zones, users, view reports, settings
  - **Delivery**: Assign delivery, view orders, mark as delivered

### 2. Auto-Apply on User Creation
- When creating a new user with a specific role, the system automatically applies that role's preset permissions
- No need to manually select permissions for each new user
- Permissions can still be customized for individual users if needed

### 3. Apply to Existing Users
- Bulk apply permissions to all existing users with a specific role
- Useful when updating role permissions and want to apply changes retroactively

---

## 📋 Available Permissions

### Orders
- `can_create_order` - Create new orders
- `can_view_orders` - View orders
- `can_edit_orders` - Edit orders
- `can_delete_orders` - Delete orders
- `can_mark_ready` - Mark orders as ready

### Order Fields  
- `can_edit_customer_info` - Edit customer information
- `can_edit_flavour` - Edit cake flavour
- `can_edit_size` - Edit cake size
- `can_edit_delivery_date` - Edit delivery date
- `can_edit_delivery_time` - Edit delivery time
- `can_edit_total_amount` - Edit total amount
- `can_edit_special_instructions` - Edit special instructions
- `can_edit_cake_image` - Edit cake image
- `can_edit_name_on_cake` - Edit name on cake

### Payments
- `can_record_payment` - Record payments
- `can_view_payments` - View payments
- `can_refund` - Process refunds

### Management
- `can_manage_outlets` - Manage outlets
- `can_manage_zones` - Manage delivery zones
- `can_manage_users` - Manage users
- `can_view_reports` - View reports
- `can_manage_settings` - Manage settings

### Delivery
- `can_assign_delivery` - Assign delivery partners
- `can_view_delivery_orders` - View delivery orders
- `can_mark_delivered` - Mark orders as delivered

---

## 🎭 Default Role Permissions

### Super Admin (Full Access)
- All permissions enabled

### Outlet Admin
- Create, view, edit orders
- Edit most order fields
- Record and view payments
- View reports
- Assign deliveries

### Order Manager
- Create, view, edit orders
- Edit order fields (except amount)
- View payments

### Kitchen
- View orders
- Mark orders as ready

### Delivery
- View delivery orders
- Mark orders as delivered

### Accounts
- View orders
- Record, view payments
- Process refunds
- View reports

---

## 🔧 How to Use

### For Super Admin:

#### 1. Access Permission Management
- Login as Super Admin
- Go to Dashboard
- Click "Permission Management" (new link added)

#### 2. Configure Role Permissions
- Select a role from the left sidebar
- Check/uncheck permissions for that role
- Click "Save Changes"

#### 3. Apply to Existing Users (Optional)
- After saving, click "Apply to Existing Users"
- This will update all existing users with that role to have the new permissions

#### 4. Create New User
- Go to User Management
- Create a new user
- Select their role
- Permissions are automatically applied based on that role's configuration
- You can customize individual permissions if needed

---

## 🔌 API Endpoints

### Get Available Permissions
```http
GET /api/permissions/available
Authorization: Bearer {token}
```

Returns all available permissions and roles.

### Get All Role Permissions
```http
GET /api/permissions/roles
Authorization: Bearer {token}
```

Returns configured permissions for all roles.

### Get Specific Role Permissions
```http
GET /api/permissions/roles/{role}
Authorization: Bearer {token}
```

### Update Role Permissions
```http
POST /api/permissions/roles
Authorization: Bearer {token}
Content-Type: application/json

{
  "role": "outlet_admin",
  "permissions": ["can_create_order", "can_view_orders", ...]
}
```

### Apply to Existing Users
```http
POST /api/permissions/apply-to-existing-users/{role}
Authorization: Bearer {token}
```

---

## 🎨 UI Components

### Permission Management Page
- **Location**: `/permissions`
- **Access**: Super Admin only
- **Features**:
  - Role selector sidebar
  - Permission checklist organized by category
  - Save button
  - Apply to existing users button
  - Real-time permission count for each role

---

## 💾 Database Collections

### role_permissions
Stores permission templates for each role:
```javascript
{
  "role": "outlet_admin",
  "permissions": ["can_create_order", "can_view_orders", ...],
  "description": "Manage outlet operations",
  "updated_at": "2024-03-05T10:30:00Z",
  "updated_by": "user_id"
}
```

### users
Updated with permissions field:
```javascript
{
  "id": "user_id",
  "email": "user@example.com",
  "role": "outlet_admin",
  "permissions": ["can_create_order", "can_view_orders", ...],
  ...
}
```

---

## 🚀 Deployment

### Files Added/Modified:

**Backend:**
- `server.py` - Added permission management endpoints
  - `/api/permissions/available`
  - `/api/permissions/roles`
  - `/api/permissions/roles/{role}`
  - `POST /api/permissions/roles`
  - `POST /api/permissions/apply-to-existing-users/{role}`
- Updated `create_user()` to auto-apply role permissions

**Frontend:**
- `pages/PermissionManagement.js` - New permission management UI
- `App.js` - Added `/permissions` route
- `Login.js` - Fixed role-based redirect
- `AuthContext.js` - Return user data on login

---

## ✅ Testing Checklist

- [ ] Super Admin can access Permission Management page
- [ ] Can view all available permissions
- [ ] Can update permissions for a role
- [ ] Permissions save successfully
- [ ] New user creation auto-applies role permissions
- [ ] Can apply permissions to existing users
- [ ] Permission counts update correctly
- [ ] Non-super admin users cannot access the page

---

## 🎯 Benefits

1. **Consistency**: All users with the same role have consistent permissions
2. **Efficiency**: No need to manually set permissions for each new user
3. **Flexibility**: Can still customize individual user permissions
4. **Scalability**: Easy to manage permissions as the organization grows
5. **Security**: Granular control over what each role can do
6. **Maintenance**: Easy to update permissions for an entire role

---

## 📝 Notes

- Permissions are stored as a list of strings in the user document
- If no custom permissions are provided during user creation, role defaults are automatically applied
- Super Admin always has all permissions
- Permission changes take effect immediately
- Backend routes should check user permissions (not just roles) for fine-grained access control

---

## 🔜 Future Enhancements

- UI to show which permission controls which feature
- Permission groups/bundles
- Temporary permissions (time-limited)
- Permission audit log
- Permission inheritance (roles inherit from other roles)
