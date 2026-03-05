#!/bin/bash

# Quick Fix Script for US Bakers - Corrected Version
# Run this on your Hostinger VPS as root

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}US Bakers CRM - Backend Fix${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Go to backend directory
cd /home/usbakers/usbakers-crm/backend

echo -e "${BLUE}[1/7]${NC} Activating virtual environment..."
source venv/bin/activate

echo -e "${BLUE}[2/7]${NC} Installing emergentintegrations (without version constraint)..."
pip install emergentintegrations --extra-index-url https://d33sy5i8bnduwe.cloudfront.net/simple/

echo -e "${BLUE}[3/7]${NC} Installing all other dependencies..."
# Install everything except emergentintegrations
pip install $(grep -v "emergentintegrations" requirements.txt | grep -v "^#" | grep -v "^$")

echo -e "${GREEN}[SUCCESS]${NC} All dependencies installed"

# Create .env file
echo -e "${BLUE}[4/7]${NC} Creating .env file..."
if [ ! -f .env ]; then
    cat > .env << 'EOF'
MONGO_URL=mongodb://localhost:27017/usbakers
DB_NAME=usbakers
SECRET_KEY=us-bakers-secret-key-change-in-production-2024
BACKEND_URL=http://187.77.188.41
EOF
    chown usbakers:usbakers .env
    echo -e "${GREEN}[SUCCESS]${NC} .env file created"
else
    echo -e "${YELLOW}[INFO]${NC} .env file already exists"
fi

# Seed database
echo -e "${BLUE}[5/7]${NC} Seeding database with test data..."
python utils/seed_fresh_data.py
echo -e "${GREEN}[SUCCESS]${NC} Database seeded"

# Create supervisor config if it doesn't exist
echo -e "${BLUE}[6/7]${NC} Configuring supervisor..."
if [ ! -f /etc/supervisor/conf.d/usbakers-backend.conf ]; then
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
    
    # Create logs directory
    mkdir -p /home/usbakers/logs
    chown -R usbakers:usbakers /home/usbakers/logs
    
    supervisorctl reread
    supervisorctl update
    echo -e "${GREEN}[SUCCESS]${NC} Supervisor configured"
else
    echo -e "${YELLOW}[INFO]${NC} Supervisor config already exists"
fi

# Start backend
echo -e "${BLUE}[7/7]${NC} Starting backend service..."
supervisorctl restart usbakers-backend || supervisorctl start usbakers-backend

sleep 3

# Check status
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Service Status:${NC}"
echo -e "${BLUE}========================================${NC}"
supervisorctl status usbakers-backend

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Fix Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "🌐 Your site: http://187.77.188.41"
echo ""
echo "🔑 Login:"
echo "   Email: admin@usbakers.com"
echo "   Password: admin123"
echo ""
echo "📋 Useful commands:"
echo "   Check logs: tail -f /home/usbakers/logs/backend.log"
echo "   Check status: supervisorctl status usbakers-backend"
echo "   Restart: supervisorctl restart usbakers-backend"
echo ""
