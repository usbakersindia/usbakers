#!/bin/bash

# Complete Backend Setup Script for US Bakers
# Run on Hostinger VPS as root

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   US Bakers CRM - Backend Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 1. Go to backend directory
echo -e "${BLUE}[1/8]${NC} Navigating to backend directory..."
cd /home/usbakers/usbakers-crm/backend

# 2. Activate virtual environment
echo -e "${BLUE}[2/8]${NC} Activating virtual environment..."
source venv/bin/activate

# 3. Install emergentintegrations first
echo -e "${BLUE}[3/8]${NC} Installing emergentintegrations..."
pip install emergentintegrations --extra-index-url https://d33sy5i8bnduwe.cloudfront.net/simple/ --quiet

# 4. Install other dependencies
echo -e "${BLUE}[4/8]${NC} Installing other dependencies (this may take a minute)..."
grep -v "emergentintegrations" requirements.txt > /tmp/requirements_temp.txt
pip install -r /tmp/requirements_temp.txt --quiet

echo -e "${GREEN}✓${NC} All dependencies installed"

# 5. Create .env file
echo -e "${BLUE}[5/8]${NC} Creating .env file..."
cat > .env << 'EOF'
MONGO_URL=mongodb://localhost:27017/usbakers
DB_NAME=usbakers
SECRET_KEY=us-bakers-secret-key-2024-change-in-production
BACKEND_URL=http://187.77.188.41
EOF
chown usbakers:usbakers .env
echo -e "${GREEN}✓${NC} .env file created"

# 6. Fix seed script for production
echo -e "${BLUE}[6/8]${NC} Updating seed script..."
# The seed script should already be updated in the repo, but let's make sure
if grep -q "sys.path.append('/app/backend')" utils/seed_fresh_data.py; then
    sed -i "s|sys.path.append('/app/backend')|backend_dir = Path(__file__).resolve().parent.parent\nsys.path.insert(0, str(backend_dir))|g" utils/seed_fresh_data.py
fi

# Add dotenv import if missing
if ! grep -q "from dotenv import load_dotenv" utils/seed_fresh_data.py; then
    sed -i '/from pathlib import Path/a from dotenv import load_dotenv' utils/seed_fresh_data.py
    sed -i '/sys.path.insert(0, str(backend_dir))/a \n# Load environment variables from .env file\nload_dotenv(backend_dir / '"'"'.env'"'"')' utils/seed_fresh_data.py
fi

echo -e "${GREEN}✓${NC} Seed script updated"

# 7. Seed database
echo -e "${BLUE}[7/8]${NC} Seeding database with test data..."
python utils/seed_fresh_data.py

echo -e "${GREEN}✓${NC} Database seeded successfully"

# 8. Configure and start supervisor
echo -e "${BLUE}[8/8]${NC} Configuring supervisor..."

# Create logs directory
mkdir -p /home/usbakers/logs
chown -R usbakers:usbakers /home/usbakers/logs

# Create supervisor config
cat > /etc/supervisor/conf.d/usbakers-backend.conf << 'EOF'
[program:usbakers-backend]
directory=/home/usbakers/usbakers-crm/backend
command=/home/usbakers/usbakers-crm/backend/venv/bin/uvicorn server:app --host 0.0.0.0 --port 8001 --workers 1
user=usbakers
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/home/usbakers/logs/backend.log
stderr_logfile=/home/usbakers/logs/backend-error.log
environment=PATH="/home/usbakers/usbakers-crm/backend/venv/bin"
EOF

# Reload supervisor
supervisorctl reread
supervisorctl update

# Start backend (or restart if already running)
supervisorctl restart usbakers-backend 2>/dev/null || supervisorctl start usbakers-backend

echo -e "${GREEN}✓${NC} Supervisor configured and backend started"

# Wait for backend to start
sleep 4

# Check status
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Service Status${NC}"
echo -e "${BLUE}========================================${NC}"
supervisorctl status usbakers-backend

# Test API
echo ""
echo -e "${BLUE}Testing API...${NC}"
if curl -s http://localhost:8001/api/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Backend API is responding"
else
    echo -e "${YELLOW}⚠${NC} Backend API not responding yet (may need a moment)"
fi

# Success message
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   ✓ Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "🌐 Access your application:"
echo "   URL: http://187.77.188.41"
echo ""
echo "🔑 Login credentials:"
echo "   Email: admin@usbakers.com"
echo "   Password: admin123"
echo ""
echo "   Satyam (Dhangu Road):"
echo "   Email: satyam@usbakers.com"
echo "   Password: satyam123"
echo ""
echo "   Sushant (Railway Road):"
echo "   Email: sushant@usbakers.com"
echo "   Password: sushant123"
echo ""
echo "📋 Useful commands:"
echo "   View logs: tail -f /home/usbakers/logs/backend.log"
echo "   Check status: supervisorctl status usbakers-backend"
echo "   Restart backend: supervisorctl restart usbakers-backend"
echo "   Check MongoDB: systemctl status mongod"
echo ""
echo -e "${YELLOW}Note:${NC} If site doesn't load, wait 10 seconds and refresh."
echo ""
