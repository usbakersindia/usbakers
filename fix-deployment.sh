#!/bin/bash

# Quick Fix Script for US Bakers Deployment
# This fixes the emergentintegrations installation issue

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}[INFO]${NC} Fixing backend dependencies..."

# Install emergentintegrations with private index
cd /home/usbakers/usbakers-crm/backend
source venv/bin/activate

echo -e "${BLUE}[INFO]${NC} Installing emergentintegrations from private repository..."
pip install emergentintegrations --extra-index-url https://d33sy5i8bnduwe.cloudfront.net/simple/

echo -e "${BLUE}[INFO]${NC} Installing remaining dependencies..."
pip install -r requirements.txt

echo -e "${GREEN}[SUCCESS]${NC} All dependencies installed"

# Ensure .env file exists
if [ ! -f /home/usbakers/usbakers-crm/backend/.env ]; then
    echo -e "${BLUE}[INFO]${NC} Creating .env file..."
    cat > /home/usbakers/usbakers-crm/backend/.env << 'EOF'
MONGO_URL=mongodb://localhost:27017/usbakers
DB_NAME=usbakers
SECRET_KEY=change-this-secret-key-in-production
BACKEND_URL=http://187.77.188.41
EOF
    chown usbakers:usbakers /home/usbakers/usbakers-crm/backend/.env
    echo -e "${GREEN}[SUCCESS]${NC} .env file created"
fi

# Seed database
echo -e "${BLUE}[INFO]${NC} Seeding database with test data..."
cd /home/usbakers/usbakers-crm/backend
source venv/bin/activate
python utils/seed_fresh_data.py

echo -e "${GREEN}[SUCCESS]${NC} Database seeded"

# Start backend service
echo -e "${BLUE}[INFO]${NC} Starting backend service..."
supervisorctl restart usbakers-backend

sleep 3

# Check status
echo ""
echo -e "${BLUE}[INFO]${NC} Checking service status..."
supervisorctl status usbakers-backend

echo ""
echo -e "${GREEN}[SUCCESS]${NC} Fix complete!"
echo ""
echo "🌐 Your site should now be accessible at: http://187.77.188.41"
echo ""
echo "🔑 Login with:"
echo "   Email: admin@usbakers.com"
echo "   Password: admin123"
echo ""
echo "📋 Check logs:"
echo "   tail -f /home/usbakers/logs/backend.log"
