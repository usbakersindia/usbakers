#!/bin/bash

# US Bakers CRM - Complete Fresh OS Installation Script
# Run this on a fresh Ubuntu 20.04/22.04 VPS
# Usage: sudo bash fresh-install.sh

set -e  # Exit on error

echo "=========================================="
echo "  US Bakers CRM - Fresh OS Setup"
echo "  This will install everything needed"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use: sudo bash fresh-install.sh)"
    exit 1
fi

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}This script will install:${NC}"
echo "  - MongoDB 7.0"
echo "  - Node.js 20 + Yarn"
echo "  - Python 3.11"
echo "  - Nginx"
echo "  - Supervisor"
echo "  - Git & essential tools"
echo ""
read -p "Continue? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# ===================================
# STEP 1: Update System
# ===================================
echo ""
echo -e "${GREEN}Step 1/8: Updating system packages...${NC}"
apt update
apt upgrade -y
echo "✓ System updated"

# ===================================
# STEP 2: Install Essential Tools
# ===================================
echo ""
echo -e "${GREEN}Step 2/8: Installing essential tools...${NC}"
apt install -y git curl wget software-properties-common build-essential \
    gnupg apt-transport-https ca-certificates net-tools supervisor
echo "✓ Essential tools installed"

# ===================================
# STEP 3: Install MongoDB 7.0
# ===================================
echo ""
echo -e "${GREEN}Step 3/8: Installing MongoDB...${NC}"

# Import MongoDB GPG key
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor

# Add MongoDB repository
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
   tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Install MongoDB
apt update
apt install -y mongodb-org

# Start and enable MongoDB
systemctl daemon-reload
systemctl start mongod
systemctl enable mongod

# Verify MongoDB
if systemctl is-active --quiet mongod; then
    echo "✓ MongoDB installed and running"
else
    echo "✗ MongoDB installation failed"
    exit 1
fi

# ===================================
# STEP 4: Install Node.js 20 & Yarn
# ===================================
echo ""
echo -e "${GREEN}Step 4/8: Installing Node.js & Yarn...${NC}"

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

# Install Yarn
npm install -g yarn

# Verify
NODE_VERSION=$(node --version)
YARN_VERSION=$(yarn --version)
echo "✓ Node.js $NODE_VERSION installed"
echo "✓ Yarn $YARN_VERSION installed"

# ===================================
# STEP 5: Install Python 3.11
# ===================================
echo ""
echo -e "${GREEN}Step 5/8: Installing Python...${NC}"

apt install -y python3.11 python3.11-venv python3-pip python3.11-dev

# Verify
PYTHON_VERSION=$(python3 --version)
echo "✓ $PYTHON_VERSION installed"

# ===================================
# STEP 6: Install Nginx
# ===================================
echo ""
echo -e "${GREEN}Step 6/8: Installing Nginx...${NC}"

apt install -y nginx

# Start and enable Nginx
systemctl start nginx
systemctl enable nginx

echo "✓ Nginx installed and running"

# ===================================
# STEP 7: Create Application User
# ===================================
echo ""
echo -e "${GREEN}Step 7/8: Creating application user...${NC}"

# Check if user exists
if id "usbakers" &>/dev/null; then
    echo "✓ User 'usbakers' already exists"
else
    useradd -m -s /bin/bash usbakers
    echo "✓ User 'usbakers' created"
fi

# ===================================
# STEP 8: Configure Firewall (Optional)
# ===================================
echo ""
echo -e "${GREEN}Step 8/8: Configuring firewall...${NC}"

# Install UFW if not present
apt install -y ufw

# Configure firewall
ufw --force enable
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw allow 80/tcp
ufw allow 443/tcp

echo "✓ Firewall configured"

# ===================================
# SUMMARY
# ===================================
echo ""
echo "=========================================="
echo -e "${GREEN}✓ System Setup Complete!${NC}"
echo "=========================================="
echo ""
echo "Installed Components:"
echo "  ✓ MongoDB: $(mongod --version | head -1)"
echo "  ✓ Node.js: $NODE_VERSION"
echo "  ✓ Yarn: $YARN_VERSION"
echo "  ✓ Python: $PYTHON_VERSION"
echo "  ✓ Nginx: $(nginx -v 2>&1)"
echo "  ✓ Supervisor: $(supervisord --version)"
echo ""
echo "Service Status:"
systemctl is-active --quiet mongod && echo "  ✓ MongoDB: Running" || echo "  ✗ MongoDB: Stopped"
systemctl is-active --quiet nginx && echo "  ✓ Nginx: Running" || echo "  ✗ Nginx: Stopped"
echo ""
echo "=========================================="
echo "📋 NEXT STEPS:"
echo "=========================================="
echo ""
echo "1. Switch to usbakers user:"
echo "   su - usbakers"
echo ""
echo "2. Clone your repository:"
echo "   git clone https://github.com/usbakersindia/usbakers.git usbakers-crm"
echo "   cd usbakers-crm"
echo ""
echo "3. Exit back to root:"
echo "   exit"
echo ""
echo "4. Run the application setup:"
echo "   cd /home/usbakers/usbakers-crm"
echo "   chmod +x setup-fresh.sh"
echo "   sudo ./setup-fresh.sh"
echo ""
echo "🎉 Happy Deploying!"
echo ""
