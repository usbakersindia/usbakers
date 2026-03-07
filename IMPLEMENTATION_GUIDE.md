# Order Flow Enhancement - Implementation Guide

## Summary of Changes

### Backend Changes Completed:
1. ✅ Added `OrderLifecycleStatus` enum
2. ✅ Added `SalesPerson` model and endpoints
3. ✅ Added `SystemSettings` model and endpoints  
4. ✅ Added `/api/sales-persons` endpoints (create, get, delete)
5. ✅ Added `/api/system-settings` endpoints (get, update)
6. ✅ Updated Order model with `lifecycle_status` and `is_punch_order`

### Backend Changes Remaining:

#### 1. Update Order Creation Endpoint (`/api/orders` POST)
Location: Line ~1071 in server.py

```python
@api_router.post("/orders")
async def create_order(
    order_data: OrderCreate,
    is_punch_order: bool = False,  # Query param
    current_user: User = Depends(get_current_user)
):
    # Calculate delivery charge
    delivery_charge = 0.0
    if order_data.needs_delivery and order_data.zone_id:
        zone = await db.zones.find_one({"id": order_data.zone_id}, {"_id": 0})
        if zone:
            delivery_charge = zone['delivery_charge']
    
    # Total = cake amount + delivery
    total_amount = order_data.total_amount + delivery_charge
    
    # Determine lifecycle status
    if is_punch_order:
        lifecycle_status = "pending_payment"
        status = OrderStatus.PENDING
    else:
        lifecycle_status = "hold"
        status = OrderStatus.ON_HOLD
    
    order = Order(
        ...existing fields...,
        total_amount=total_amount,
        pending_amount=total_amount,
        lifecycle_status=lifecycle_status,
        status=status,
        is_punch_order=is_punch_order,
        is_hold=not is_punch_order
    )
    
    # Save and return
```

#### 2. Add Pending Orders Endpoint
```python
@api_router.get("/orders/pending")
async def get_pending_orders(
    outlet_id: Optional[str] = None,
    current_user: User = Depends(get_current_user)
):
    """Get punch orders waiting for payment"""
    query = {"lifecycle_status": "pending_payment", "is_deleted": False}
    
    if current_user.role != UserRole.SUPER_ADMIN and current_user.outlet_id:
        query["outlet_id"] = current_user.outlet_id
    elif outlet_id:
        query["outlet_id"] = outlet_id
    
    orders = await db.orders.find(query, {"_id": 0}).to_list(1000)
    
    # Convert date fields
    for order in orders:
        if isinstance(order.get('created_at'), str):
            order['created_at'] = datetime.fromisoformat(order['created_at'])
        if isinstance(order.get('updated_at'), str):
            order['updated_at'] = datetime.fromisoformat(order['updated_at'])
    
    return orders
```

#### 3. Add Release Hold Order Endpoint
```python
@api_router.post("/orders/{order_id}/release")
async def release_hold_order(
    order_id: str,
    order_updates: Dict[str, Any],  # Updated order data
    current_user: User = Depends(get_current_user)
):
    """Release a hold order by completing required info"""
    order = await db.orders.find_one({"id": order_id}, {"_id": 0})
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    if order.get('lifecycle_status') != 'hold':
        raise HTTPException(status_code=400, detail="Order is not on hold")
    
    # Update order with completed info
    update_data = order_updates.copy()
    
    # Determine new lifecycle status
    # If still needs payment, go to pending_payment
    # Otherwise go to active
    paid_amount = update_data.get('paid_amount', order.get('paid_amount', 0))
    total_amount = order['total_amount']
    
    if paid_amount < total_amount:
        update_data['lifecycle_status'] = 'pending_payment'
        update_data['status'] = 'pending'
    else:
        update_data['lifecycle_status'] = 'active'
        update_data['status'] = 'confirmed'
    
    update_data['is_hold'] = False
    update_data['updated_at'] = datetime.now(timezone.utc).isoformat()
    
    await db.orders.update_one({"id": order_id}, {"$set": update_data})
    
    return {"message": "Order released successfully", "lifecycle_status": update_data['lifecycle_status']}
```

#### 4. Update PetPooja Payment Webhook
Location: Line ~1740 (petpooja/payment-webhook)

```python
@api_router.post("/petpooja/payment-webhook")
async def petpooja_payment_webhook(request_data: Dict[str, Any]):
    """Handle PetPooja payment notifications"""
    ...existing code...
    
    # After recording payment
    current_paid = order.get('paid_amount', 0)
    new_paid = current_paid + amount
    pending = order['total_amount'] - new_paid
    
    # Get minimum payment threshold from settings
    settings = await db.system_settings.find_one({"id": "system_settings"}, {"_id": 0})
    min_percentage = settings.get('minimum_payment_percentage', 20.0) if settings else 20.0
    
    payment_percentage = (new_paid / order['total_amount']) * 100
    
    # Check if order should move from pending_payment to active
    new_lifecycle_status = order.get('lifecycle_status')
    new_status = order.get('status')
    
    if order.get('lifecycle_status') == 'pending_payment' and payment_percentage >= min_percentage:
        new_lifecycle_status = 'active'
        new_status = 'confirmed'
        logger.info(f"Order {order_id} moved to active (payment: {payment_percentage:.1f}%)")
    
    await db.orders.update_one(
        {"id": order_id},
        {"$set": {
            "paid_amount": new_paid,
            "pending_amount": pending,
            "lifecycle_status": new_lifecycle_status,
            "status": new_status,
            "is_hold": False,
            "payment_synced_from_petpooja": True,
            "updated_at": datetime.now(timezone.utc).isoformat()
        },
         "$push": {"petpooja_bill_numbers": bill_number}}
    )
    
    return {...}
```

#### 5. Update Manage Orders Endpoint
Change query to show only active orders:
```python
@api_router.get("/orders/manage")
async def get_manage_orders(...):
    query = {"lifecycle_status": "active", "is_deleted": False}
    ...
```

## Frontend Changes Required

### 1. New Component: SalesPersonManagement.js
- List all sales persons
- Add new sales person
- Delete sales person
- Filter by outlet

### 2. New Component: SystemSettings.js  
- Show current minimum payment percentage
- Allow super admin to update it
- Save to `/api/system-settings`

### 3. Update NewOrder.js
Changes needed:
- Auto-fetch outlet_id from current_user.outlet_id
- Add "Order Taken By" dropdown (fetch from `/api/sales-persons`)
- Show zones only if delivery = yes (filter by outlet)
- Calculate total = cake amount + delivery charge
- Two submit buttons:
  - "Punch Order" (almost all fields mandatory)
  - "Hold Order" (all fields optional)
- Send `is_punch_order` query param

### 4. Update HoldOrders.js
- Add "Release Order" button for each order
- Modal to complete missing fields
- Call `/api/orders/{id}/release` with updated data

### 5. New Component: PendingOrders.js
- Fetch from `/api/orders/pending`
- Show payment status (paid/total, percentage)
- Show threshold from `/api/system-settings`
- Highlight orders close to threshold
- Auto-refresh every 30 seconds

### 6. Update ManageOrders.js
- No filter change needed (backend already filters by lifecycle_status)
- Show payment percentage badge

### 7. Update Sidebar.js
- Add "Pending Orders" link (for roles with permission)
- Add "Sales Persons" link (Super Admin only)
- Add to System Settings page the payment threshold setting

## Database Migrations

No migrations needed - MongoDB will create collections on first insert:
- `sales_persons`
- `system_settings`

Existing orders will work fine - missing fields will be null/default.

## Testing Checklist

1. [ ] Create sales person
2. [ ] Create punch order → check it appears in pending
3. [ ] Simulate PetPooja payment < 20% → order stays in pending
4. [ ] Simulate PetPooja payment >= 20% → order moves to manage
5. [ ] Create hold order → appears in hold orders
6. [ ] Release hold order with full payment → goes to manage
7. [ ] Release hold order with partial payment → goes to pending
8. [ ] Change minimum payment % in settings → test threshold
9. [ ] Test outlet filtering for zones/sales persons
10. [ ] Test auto-fetch outlet_id in new order form

## API Summary

### New Endpoints:
- POST `/api/sales-persons` - Create sales person
- GET `/api/sales-persons?outlet_id=xxx` - Get sales persons
- DELETE `/api/sales-persons/{id}` - Delete sales person
- GET `/api/system-settings` - Get settings
- PATCH `/api/system-settings` - Update settings
- GET `/api/orders/pending` - Get pending orders
- POST `/api/orders/{id}/release` - Release hold order

### Modified Endpoints:
- POST `/api/orders?is_punch_order=true/false` - Create order
- POST `/api/petpooja/payment-webhook` - Auto-move orders
- GET `/api/orders/manage` - Show only active orders
