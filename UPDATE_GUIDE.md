# 🚀 VPS Update Instructions for US Bakers CRM

## Quick Update Guide

This guide will help you update your live Hostinger VPS application with all the new features.

---

## ✅ Prerequisites

Before running the update script, ensure:

1. ✔️ You're logged into your Hostinger VPS via SSH
2. ✔️ Your project is connected to GitHub
3. ✔️ You have sudo privileges
4. ✔️ Backend and Frontend services are managed by Supervisor

---

## 📦 What This Update Includes

- ✨ **Advanced Order Flow**: Punch vs Hold orders with Pending lifecycle
- 👥 **Sales Person Management**: Manage non-user sales staff
- 📊 **Excel Exports**: Download reports and orders as Excel files
- 💳 **PetPooja Payment Sync**: Automated payment threshold validation
- 🐛 **Critical Bug Fixes**: Factory login, bcrypt errors, permission crashes
- 📝 **Comprehensive Seed Data**: Test users, outlets, orders, and sales persons

---

## 🎯 Update Steps

### Step 1: Navigate to Your Project Directory

```bash
cd /path/to/your/usbakers-project
```

*(Replace `/path/to/your/usbakers-project` with your actual project path)*

### Step 2: Make the Update Script Executable

```bash
chmod +x update-vps.sh
```

### Step 3: Run the Update Script

```bash
./update-vps.sh
```

The script will automatically:
1. ✅ Pull latest code from GitHub
2. ✅ Install backend dependencies
3. ✅ Install frontend dependencies (yarn)
4. ✅ Build the frontend
5. ✅ Run seed data script
6. ✅ Restart backend and frontend services
7. ✅ Display service status

---

## 🧪 Test Credentials (Added by Seed Script)

After the update, you can test with these accounts:

| Role | Email | Password | Outlet |
|------|-------|----------|--------|
| **Super Admin** | admin@usbakers.com | admin123 | All |
| **Dhangu Road Admin** | satyam@usbakers.com | satyam123 | Dhangu Road |
| **Railway Road Admin** | sushant@usbakers.com | sushant123 | Railway Road |
| **Factory Admin** | factory@usbakers.com | factory123 | Factory |

---

## 🔍 Verify the Update

### 1. Check Application Status

```bash
sudo supervisorctl status
```

Both `backend` and `frontend` should show `RUNNING`.

### 2. Access Your Application

Visit your domain in a browser and verify:

- ✅ Login works with test credentials
- ✅ New "Pending Orders" menu appears in sidebar
- ✅ New "Hold Orders" menu appears
- ✅ New "Sales Persons" menu (for Super Admin)
- ✅ "Settings" menu is hidden for non-Super Admin users
- ✅ Excel export buttons work on Reports and Manage Orders

### 3. Test New Order Flow

1. Login as `satyam@usbakers.com` (Dhangu Road Admin)
2. Go to "New Order"
3. Notice the new "Punch Order" and "Hold Order" buttons
4. Create a test order and verify it appears in "Pending Orders"

---

## 🆘 Troubleshooting

### If services fail to start:

```bash
# Check backend logs
sudo tail -n 50 /var/log/supervisor/backend.err.log

# Check frontend logs
sudo tail -n 50 /var/log/supervisor/frontend.err.log
```

### If you need to restart services manually:

```bash
sudo supervisorctl restart backend
sudo supervisorctl restart frontend
```

### If MongoDB connection fails:

Ensure MongoDB is running:
```bash
sudo systemctl status mongod
sudo systemctl start mongod  # if not running
```

---

## 🔗 PetPooja Webhook Configuration

After update, configure your PetPooja webhook:

1. Login as Super Admin
2. Go to **Settings** → **PetPooja Settings**
3. Copy the webhook URL displayed
4. Add this URL to your PetPooja dashboard for payment notifications

---

## 🎉 What's Next?

After successful update and testing:

- **Phase 2**: Notifications system and activity logs
- **Phase 3**: PDF generation and advanced filters
- **Future**: Inventory management and incentive system

---

## 📞 Need Help?

If you encounter any issues during the update, note down:
- Error messages from the script
- Service logs (backend/frontend)
- Screenshot of any UI errors

---

**Last Updated**: December 2025  
**Version**: 2.0 (Advanced Order Flow)
