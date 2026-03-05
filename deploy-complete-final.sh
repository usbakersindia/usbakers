#!/bin/bash

#############################################################
# US Bakers CRM - Complete Deployment with All Latest Features
# Including: Permission Management, Role-based Access, All Users
#############################################################

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  US Bakers CRM - Final Deployment${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 1. Backend Configuration
echo -e "${BLUE}[1/9]${NC} Configuring backend..."
cd /home/usbakers/usbakers-crm/backend

cat > .env << 'EOF'
MONGO_URL=mongodb://localhost:27017/usbakers
DB_NAME=usbakers
SECRET_KEY=us-bakers-production-secret-2024
BACKEND_URL=http://187.77.188.41
CORS_ORIGINS=*
EOF

echo -e "${GREEN}✓${NC} Backend configured"

# 2. Seed Database
echo -e "${BLUE}[2/9]${NC} Seeding database with all users and data..."
source venv/bin/activate
export MONGO_URL=mongodb://localhost:27017/usbakers
export DB_NAME=usbakers
PYTHONPATH=/home/usbakers/usbakers-crm/backend python utils/seed_fresh_data.py

echo -e "${GREEN}✓${NC} Database seeded"

# 3. Initialize Default Role Permissions
echo -e "${BLUE}[3/9]${NC} Initializing default permissions for all roles..."

# This will be done automatically by the backend on first API call
# But we can verify by restarting backend

# 4. Restart Backend
echo -e "${BLUE}[4/9]${NC} Restarting backend..."
sudo supervisorctl restart usbakers-backend
sleep 3

if sudo supervisorctl status usbakers-backend | grep -q RUNNING; then
    echo -e "${GREEN}✓${NC} Backend running"
else
    echo -e "${YELLOW}⚠${NC} Backend not running, checking logs..."
    tail -n 20 /home/usbakers/logs/backend.log
fi

# 5. Frontend Configuration
echo -e "${BLUE}[5/9]${NC} Configuring frontend..."
cd /home/usbakers/usbakers-crm/frontend

cat > .env << 'EOF'
REACT_APP_BACKEND_URL=http://187.77.188.41
EOF

echo -e "${GREEN}✓${NC} Frontend configured"

# 6. Build Frontend
echo -e "${BLUE}[6/9]${NC} Building frontend (2-3 minutes)..."
rm -rf build node_modules/.cache
sudo -u usbakers yarn build

if [ -f build/index.html ]; then
    echo -e "${GREEN}✓${NC} Frontend built"
else
    echo -e "${YELLOW}⚠${NC} Frontend build may have issues"
fi

# 7. Fix Permissions
echo -e "${BLUE}[7/9]${NC} Fixing file permissions..."
sudo chmod 755 /home /home/usbakers /home/usbakers/usbakers-crm /home/usbakers/usbakers-crm/frontend
sudo chmod -R 755 /home/usbakers/usbakers-crm/frontend/build
sudo find /home/usbakers/usbakers-crm/frontend/build -type f -exec chmod 644 {} \;
sudo chmod -R 755 /home/usbakers/usbakers-crm/uploads

echo -e "${GREEN}✓${NC} Permissions fixed"

# 8. Restart Nginx
echo -e "${BLUE}[8/9]${NC} Restarting nginx..."
sudo systemctl restart nginx
echo -e "${GREEN}✓${NC} Nginx restarted"

# 9. Final Testing
echo -e "${BLUE}[9/9]${NC} Testing all services..."
sleep 2

echo ""
echo "Backend Health:"
curl -s http://localhost:8001/api/health && echo ""

echo ""
echo "Testing User Logins:"
for user in "admin@usbakers.com:admin123:Super Admin" "satyam@usbakers.com:satyam123:Satyam" "sushant@usbakers.com:sushant123:Sushant" "factory@usbakers.com:factory123:Factory"; do
  email=$(echo $user | cut -d: -f1)
  pass=$(echo $user | cut -d: -f2)
  name=$(echo $user | cut -d: -f3)
  
  if curl -s -X POST http://187.77.188.41/api/auth/login \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$email\",\"password\":\"$pass\"}" | grep -q "access_token"; then
    echo -e "${GREEN}✓${NC} $name login works"
  else
    echo -e "${YELLOW}✗${NC} $name login failed"
  fi
done

# Database Stats
USER_COUNT=$(mongosh mongodb://localhost:27017/usbakers --quiet --eval "db.users.countDocuments({})")
ORDER_COUNT=$(mongosh mongodb://localhost:27017/usbakers --quiet --eval "db.orders.countDocuments({})")

echo ""
echo "Database: ${USER_COUNT} users, ${ORDER_COUNT} orders"

# Final Summary
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "🌐 Application URL: http://187.77.188.41"
echo ""
echo "🔑 Login Credentials:"
echo ""
echo "   Super Admin (Full Access):"
echo "   📧 admin@usbakers.com"
echo "   🔒 admin123"
echo ""
echo "   Satyam - Dhangu Road (Outlet Admin):"
echo "   📧 satyam@usbakers.com"
echo "   🔒 satyam123"
echo ""
echo "   Sushant - Railway Road (Outlet Admin):"
echo "   📧 sushant@usbakers.com"
echo "   🔒 sushant123"
echo ""
echo "   Factory Admin (Kitchen):"
echo "   📧 factory@usbakers.com"
echo "   🔒 factory123"
echo ""
echo "✨ NEW FEATURES:"
echo "   ✓ Granular Permission Management"
echo "   ✓ Role-based default permissions"
echo "   ✓ Auto-apply permissions on user creation"
echo "   ✓ Permission Management page (/permissions)"
echo "   ✓ All users can login without access denied"
echo "   ✓ Role-based dashboard redirection"
echo ""
echo "📋 Super Admin Can:"
echo "   • Manage all users, outlets, zones"
echo "   • Configure role permissions in /permissions"
echo "   • Create orders and manage operations"
echo "   • View all reports and analytics"
echo ""
echo "📋 Outlet Admins Can:"
echo "   • View dashboard with outlet stats"
echo "   • Create and manage orders"
echo "   • Manage customers"
echo "   • View reports for their outlet"
echo ""
echo "🔧 Useful Commands:"
echo "   Check status: sudo supervisorctl status"
echo "   View logs: tail -f /home/usbakers/logs/backend.log"
echo "   Restart backend: sudo supervisorctl restart usbakers-backend"
echo "   Restart nginx: sudo systemctl restart nginx"
echo ""
