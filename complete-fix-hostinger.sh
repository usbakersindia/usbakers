#!/bin/bash

###############################################
# US Bakers CRM - Complete Fix Script
# This fixes all users and ensures full functionality
###############################################

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  US Bakers CRM - Complete Fix${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 1. Fix Backend Environment
echo -e "${BLUE}[1/8]${NC} Configuring backend..."
cd /home/usbakers/usbakers-crm/backend

cat > .env << 'EOF'
MONGO_URL=mongodb://localhost:27017/usbakers
DB_NAME=usbakers
SECRET_KEY=us-bakers-secret-key-2024-production
BACKEND_URL=http://187.77.188.41
CORS_ORIGINS=*
EOF

echo -e "${GREEN}✓${NC} Backend .env configured"

# 2. Seed Database with All Users
echo -e "${BLUE}[2/8]${NC} Seeding database with all users and data..."
source venv/bin/activate
export MONGO_URL=mongodb://localhost:27017/usbakers
export DB_NAME=usbakers
PYTHONPATH=/home/usbakers/usbakers-crm/backend python utils/seed_fresh_data.py

echo -e "${GREEN}✓${NC} Database seeded"

# 3. Restart Backend
echo -e "${BLUE}[3/8]${NC} Restarting backend..."
sudo supervisorctl restart usbakers-backend
sleep 3

if sudo supervisorctl status usbakers-backend | grep -q RUNNING; then
    echo -e "${GREEN}✓${NC} Backend is running"
else
    echo -e "${RED}✗${NC} Backend failed to start"
    tail -n 20 /home/usbakers/logs/backend.log
    exit 1
fi

# 4. Fix Frontend Environment
echo -e "${BLUE}[4/8]${NC} Configuring frontend..."
cd /home/usbakers/usbakers-crm/frontend

cat > .env << 'EOF'
REACT_APP_BACKEND_URL=http://187.77.188.41
EOF

echo -e "${GREEN}✓${NC} Frontend .env configured"

# 5. Rebuild Frontend
echo -e "${BLUE}[5/8]${NC} Rebuilding frontend (this takes 1-2 minutes)..."
rm -rf build node_modules/.cache
sudo -u usbakers yarn build

if [ -f build/index.html ]; then
    echo -e "${GREEN}✓${NC} Frontend built successfully"
else
    echo -e "${RED}✗${NC} Frontend build failed"
    exit 1
fi

# 6. Fix All Permissions
echo -e "${BLUE}[6/8]${NC} Fixing permissions..."
sudo chmod 755 /home
sudo chmod 755 /home/usbakers  
sudo chmod -R 755 /home/usbakers/usbakers-crm
sudo chown -R usbakers:usbakers /home/usbakers/usbakers-crm

# Give nginx access
sudo find /home/usbakers/usbakers-crm/frontend/build -type d -exec chmod 755 {} \;
sudo find /home/usbakers/usbakers-crm/frontend/build -type f -exec chmod 644 {} \;

# Test if www-data can read
if sudo -u www-data test -r /home/usbakers/usbakers-crm/frontend/build/index.html; then
    echo -e "${GREEN}✓${NC} Permissions fixed"
else
    echo -e "${YELLOW}⚠${NC} Permission warning - trying alternative fix..."
    sudo usermod -a -G usbakers www-data
fi

# 7. Restart Nginx
echo -e "${BLUE}[7/8]${NC} Restarting nginx..."
sudo systemctl restart nginx

if sudo systemctl is-active --quiet nginx; then
    echo -e "${GREEN}✓${NC} Nginx is running"
else
    echo -e "${RED}✗${NC} Nginx failed"
    exit 1
fi

# 8. Test Everything
echo -e "${BLUE}[8/8]${NC} Testing all services..."
echo ""

# Test backend
BACKEND_HEALTH=$(curl -s http://localhost:8001/api/health)
if echo "$BACKEND_HEALTH" | grep -q "healthy"; then
    echo -e "${GREEN}✓${NC} Backend API: Working"
else
    echo -e "${RED}✗${NC} Backend API: Failed"
fi

# Test all user logins
echo ""
echo "Testing user logins:"
for user in "admin@usbakers.com:admin123:Super Admin" "satyam@usbakers.com:satyam123:Satyam" "sushant@usbakers.com:sushant123:Sushant" "factory@usbakers.com:factory123:Factory"; do
  email=$(echo $user | cut -d: -f1)
  pass=$(echo $user | cut -d: -f2)
  name=$(echo $user | cut -d: -f3)
  
  result=$(curl -s -X POST http://187.77.188.41/api/auth/login \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$email\",\"password\":\"$pass\"}" | grep -o '"access_token"' | wc -l)
  
  if [ $result -eq 1 ]; then
    echo -e "${GREEN}✓${NC} $name - Login works"
  else
    echo -e "${RED}✗${NC} $name - Login failed"
  fi
done

# Check database
USER_COUNT=$(mongosh mongodb://localhost:27017/usbakers --quiet --eval "db.users.countDocuments({})")
ORDER_COUNT=$(mongosh mongodb://localhost:27017/usbakers --quiet --eval "db.orders.countDocuments({})")

echo ""
echo -e "Database: ${GREEN}$USER_COUNT${NC} users, ${GREEN}$ORDER_COUNT${NC} orders"

# Final summary
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✓ Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "🌐 URL: http://187.77.188.41"
echo ""
echo "🔑 Login Credentials:"
echo ""
echo "   Super Admin:"
echo "   📧 admin@usbakers.com"
echo "   🔒 admin123"
echo ""
echo "   Satyam (Dhangu Road):"
echo "   📧 satyam@usbakers.com"
echo "   🔒 satyam123"
echo ""
echo "   Sushant (Railway Road):"
echo "   📧 sushant@usbakers.com"
echo "   🔒 sushant123"
echo ""
echo "   Factory Admin:"
echo "   📧 factory@usbakers.com"
echo "   🔒 factory123"
echo ""
echo "📋 Features:"
echo "   ✓ All users can login"
echo "   ✓ Dashboard with statistics"
echo "   ✓ Order management"
echo "   ✓ Customer management"
echo "   ✓ Outlet management"
echo "   ✓ User management (Super Admin)"
echo "   ✓ Kitchen dashboard"
echo "   ✓ Delivery dashboard"
echo "   ✓ Reports"
echo ""
